-- =============================================================================
-- SAIQI — 03 : helpers de rôle, création de profil, triggers, notifications
-- =============================================================================

-- ---------------------------------------------------------------------------
-- Helpers de rôle (SECURITY DEFINER : évitent la récursion RLS sur profiles)
-- ---------------------------------------------------------------------------
create or replace function public.is_admin()
returns boolean
language sql stable security definer
set search_path = public
as $$
  select exists (
    select 1 from public.profiles p
    where p.id = auth.uid() and p.role = 'admin' and p.status = 'active'
  );
$$;

create or replace function public.has_admin_role(variadic p_roles public.admin_role[])
returns boolean
language sql stable security definer
set search_path = public
as $$
  select exists (
    select 1 from public.profiles p
    where p.id = auth.uid() and p.role = 'admin' and p.status = 'active'
      and p.admin_role = any (p_roles)
  );
$$;

create or replace function public.is_driver()
returns boolean
language sql stable security definer
set search_path = public
as $$
  select exists (
    select 1 from public.profiles p
    where p.id = auth.uid() and p.role = 'driver' and p.status = 'active'
  );
$$;

create or replace function public.is_client()
returns boolean
language sql stable security definer
set search_path = public
as $$
  select exists (
    select 1 from public.profiles p
    where p.id = auth.uid() and p.role = 'client' and p.status = 'active'
  );
$$;

-- drivers.id du chauffeur connecté (NULL si l'utilisateur n'est pas chauffeur)
create or replace function public.current_driver_id()
returns uuid
language sql stable security definer
set search_path = public
as $$
  select d.id from public.drivers d where d.profile_id = auth.uid();
$$;

-- Erreur métier : le MESSAGE est un code stable lu par les apps (l10n côté client).
create or replace function public.raise_error(p_code text, p_detail text default null)
returns void
language plpgsql
set search_path = public
as $$
begin
  if p_detail is null then
    raise exception '%', p_code using errcode = 'P0001';
  end if;
  raise exception '%', p_code using errcode = 'P0001', detail = p_detail;
end $$;

-- ---------------------------------------------------------------------------
-- Création du profil à l'inscription (auth.users -> profiles [+ drivers])
-- ---------------------------------------------------------------------------
create or replace function public.handle_new_user()
returns trigger
language plpgsql security definer
set search_path = public
as $$
declare
  v_meta  jsonb := coalesce(new.raw_user_meta_data, '{}'::jsonb);
  v_phone text;
  v_role  public.user_role;
  v_lang  text;
begin
  v_phone := public.normalize_phone(coalesce(nullif(v_meta ->> 'phone', ''), split_part(coalesce(new.email, ''), '@', 1)));
  if v_phone is null then
    perform public.raise_error('invalid_phone');
  end if;

  -- Jamais admin à l'inscription : seuls 'client' et 'driver' sont acceptés.
  v_role := case when v_meta ->> 'role' = 'driver' then 'driver'::public.user_role else 'client'::public.user_role end;
  v_lang := case when v_meta ->> 'language' = 'fr' then 'fr' else 'ar' end;

  if exists (select 1 from public.profiles where phone = v_phone) then
    perform public.raise_error('phone_already_registered');
  end if;

  insert into public.profiles (id, role, full_name, phone, language)
  values (new.id, v_role, nullif(btrim(v_meta ->> 'full_name'), ''), v_phone, v_lang);

  if v_role = 'driver' then
    insert into public.drivers (profile_id) values (new.id);
  end if;
  return new;
end $$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ---------------------------------------------------------------------------
-- Notifications localisées (ar/fr) + audit
-- ---------------------------------------------------------------------------
create or replace function public.notify(
  p_user   uuid,
  p_key    text,
  p_params jsonb default '{}'::jsonb,
  p_data   jsonb default '{}'::jsonb
)
returns void
language plpgsql security definer
set search_path = public
as $$
declare
  v_lang  text;
  v_title text;
  v_body  text;
  r       record;
begin
  if p_user is null then
    return;
  end if;
  select coalesce(language, 'ar') into v_lang from public.profiles where id = p_user;
  if not found then
    return;
  end if;

  select t.title, t.body into v_title, v_body
  from public.notification_templates t where t.key = p_key and t.lang = v_lang;
  if not found then
    select t.title, t.body into v_title, v_body
    from public.notification_templates t where t.key = p_key and t.lang = 'ar';
  end if;
  if v_title is null then
    return;
  end if;

  for r in select e.key as k, e.value as v from jsonb_each_text(coalesce(p_params, '{}'::jsonb)) e loop
    v_title := replace(v_title, '{' || r.k || '}', coalesce(r.v, ''));
    v_body  := replace(v_body,  '{' || r.k || '}', coalesce(r.v, ''));
  end loop;

  insert into public.notifications (user_id, title, body, data)
  values (p_user, v_title, v_body, coalesce(p_data, '{}'::jsonb) || jsonb_build_object('key', p_key));
end $$;

-- Notification libre (annonces admin)
create or replace function public.notify_raw(p_user uuid, p_title text, p_body text, p_data jsonb default '{}'::jsonb)
returns void
language sql security definer
set search_path = public
as $$
  insert into public.notifications (user_id, title, body, data)
  values (p_user, p_title, p_body, coalesce(p_data, '{}'::jsonb));
$$;

create or replace function public.notify_admins(
  p_key    text,
  p_params jsonb default '{}'::jsonb,
  p_data   jsonb default '{}'::jsonb,
  p_roles  public.admin_role[] default array['super_admin', 'support']::public.admin_role[]
)
returns void
language plpgsql security definer
set search_path = public
as $$
declare
  r record;
begin
  for r in
    select id from public.profiles
    where role = 'admin' and status = 'active' and admin_role = any (p_roles)
  loop
    perform public.notify(r.id, p_key, p_params, p_data);
  end loop;
end $$;

create or replace function public.log_audit(
  p_action    text,
  p_entity    text,
  p_entity_id uuid,
  p_payload   jsonb default '{}'::jsonb
)
returns void
language sql security definer
set search_path = public
as $$
  insert into public.audit_logs (actor_id, action, entity, entity_id, payload)
  values (auth.uid(), p_action, p_entity, p_entity_id, coalesce(p_payload, '{}'::jsonb));
$$;

-- Trigger d'audit générique pour les écritures directes des super admins (catalogues, taux, paramètres)
create or replace function public.audit_row_change()
returns trigger
language plpgsql security definer
set search_path = public
as $$
declare
  v_row jsonb;
begin
  v_row := case when tg_op = 'DELETE' then to_jsonb(old) else to_jsonb(new) end;
  insert into public.audit_logs (actor_id, action, entity, entity_id, payload)
  values (auth.uid(), lower(tg_op), tg_table_name, (v_row ->> 'id')::uuid,
          case when tg_op = 'UPDATE' then jsonb_build_object('old', to_jsonb(old), 'new', to_jsonb(new))
               else v_row end);
  return case when tg_op = 'DELETE' then old else new end;
end $$;

do $$
declare
  t text;
begin
  foreach t in array array['cities', 'service_types', 'commission_rates', 'app_settings'] loop
    execute format('drop trigger if exists audit_row_change on public.%I', t);
    execute format(
      'create trigger audit_row_change after insert or update or delete on public.%I
         for each row execute function public.audit_row_change()', t);
  end loop;
end $$;

-- ---------------------------------------------------------------------------
-- Portefeuille créé automatiquement à l'approbation d'un chauffeur
-- ---------------------------------------------------------------------------
create or replace function public.ensure_driver_wallet()
returns trigger
language plpgsql
set search_path = public
as $$
begin
  if new.status = 'approved' and new.approved_at is null then
    new.approved_at := now();
  end if;
  return new;
end $$;

-- BEFORE : renseigne approved_at ; AFTER : crée le wallet (la ligne drivers existe alors pour la FK)
create or replace function public.ensure_driver_wallet_after()
returns trigger
language plpgsql security definer
set search_path = public
as $$
begin
  if new.status = 'approved' then
    insert into public.wallets (driver_id) values (new.id) on conflict (driver_id) do nothing;
  end if;
  return new;
end $$;

drop trigger if exists drivers_approved_before on public.drivers;
create trigger drivers_approved_before
  before insert or update of status on public.drivers
  for each row execute function public.ensure_driver_wallet();

drop trigger if exists drivers_approved_after on public.drivers;
create trigger drivers_approved_after
  after insert or update of status on public.drivers
  for each row execute function public.ensure_driver_wallet_after();

-- Un chauffeur non approuvé ne peut pas être « disponible »
create or replace function public.drivers_enforce_availability()
returns trigger
language plpgsql
set search_path = public
as $$
begin
  if new.status <> 'approved' then
    new.is_available := false;
  end if;
  return new;
end $$;

drop trigger if exists drivers_enforce_availability on public.drivers;
create trigger drivers_enforce_availability
  before insert or update on public.drivers
  for each row execute function public.drivers_enforce_availability();

-- ---------------------------------------------------------------------------
-- Recalcul de la note moyenne (avis masqués exclus)
-- ---------------------------------------------------------------------------
create or replace function public.recompute_driver_rating(p_driver_id uuid)
returns void
language sql security definer
set search_path = public
as $$
  update public.drivers d
  set rating_avg = coalesce((select round(avg(r.rating)::numeric, 2) from public.reviews r
                             where r.driver_id = p_driver_id and not r.is_hidden), 0),
      rating_count = (select count(*) from public.reviews r
                      where r.driver_id = p_driver_id and not r.is_hidden)
  where d.id = p_driver_id;
$$;

create or replace function public.reviews_after_change()
returns trigger
language plpgsql security definer
set search_path = public
as $$
begin
  if tg_op = 'DELETE' then
    perform public.recompute_driver_rating(old.driver_id);
    return old;
  end if;
  perform public.recompute_driver_rating(new.driver_id);
  return new;
end $$;

drop trigger if exists reviews_recompute on public.reviews;
create trigger reviews_recompute
  after insert or update or delete on public.reviews
  for each row execute function public.reviews_after_change();

-- ---------------------------------------------------------------------------
-- Gel du wallet : mouvements uniquement via fonctions SQL ; transactions immuables
-- ---------------------------------------------------------------------------
create or replace function public.wallet_transactions_immutable()
returns trigger
language plpgsql
set search_path = public
as $$
begin
  raise exception 'wallet_transactions_are_immutable' using errcode = 'P0001';
end $$;

drop trigger if exists wallet_tx_no_update on public.wallet_transactions;
create trigger wallet_tx_no_update
  before update on public.wallet_transactions
  for each row execute function public.wallet_transactions_immutable();
