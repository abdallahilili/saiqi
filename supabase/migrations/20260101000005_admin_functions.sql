-- =============================================================================
-- SAIQI — 05 : fonctions réservées aux administrateurs (contrôle par admin_role)
--   super_admin : tout
--   validator   : validation des chauffeurs / documents / statut des chauffeurs
--   support     : réservations, recharges, plaintes, clients, annonces
-- =============================================================================

create or replace function public.require_admin_role(variadic p_roles public.admin_role[])
returns void
language plpgsql stable security definer
set search_path = public
as $$
begin
  if auth.uid() is null then
    perform public.raise_error('not_authenticated');
  end if;
  if not public.has_admin_role(variadic p_roles) then
    perform public.raise_error('admin_forbidden');
  end if;
end $$;

-- ---------------------------------------------------------------------------
-- Validation des dossiers chauffeurs
-- ---------------------------------------------------------------------------
create or replace function public.admin_review_driver(p_driver_id uuid, p_approve boolean, p_reason text default null)
returns public.drivers
language plpgsql security definer
set search_path = public
as $$
declare
  v_driver public.drivers;
begin
  perform public.require_admin_role('super_admin', 'validator');

  select * into v_driver from public.drivers where id = p_driver_id for update;
  if not found then
    perform public.raise_error('driver_not_found');
  end if;
  if v_driver.status <> 'pending' then
    perform public.raise_error('invalid_driver_status');
  end if;

  if p_approve then
    update public.driver_documents
       set status = 'approved', reviewed_by = auth.uid(), reviewed_at = now(), rejection_reason = null
     where driver_id = p_driver_id and status = 'pending';
    update public.drivers set status = 'approved', rejection_reason = null
     where id = p_driver_id returning * into v_driver;
    perform public.notify(v_driver.profile_id, 'driver_approved', '{}'::jsonb, jsonb_build_object('screen', 'home'));
  else
    if nullif(btrim(p_reason), '') is null then
      perform public.raise_error('reason_required');
    end if;
    update public.drivers set status = 'rejected', rejection_reason = btrim(p_reason)
     where id = p_driver_id returning * into v_driver;
    perform public.notify(v_driver.profile_id, 'driver_rejected',
      jsonb_build_object('reason', btrim(p_reason)), jsonb_build_object('screen', 'application'));
  end if;

  perform public.log_audit(case when p_approve then 'approve_driver' else 'reject_driver' end,
    'drivers', p_driver_id, jsonb_build_object('reason', p_reason));
  return v_driver;
end $$;

create or replace function public.admin_review_document(p_document_id uuid, p_approve boolean, p_reason text default null)
returns public.driver_documents
language plpgsql security definer
set search_path = public
as $$
declare
  v_doc    public.driver_documents;
  v_driver public.drivers;
begin
  perform public.require_admin_role('super_admin', 'validator');

  select * into v_doc from public.driver_documents where id = p_document_id for update;
  if not found then
    perform public.raise_error('document_not_found');
  end if;
  if not p_approve and nullif(btrim(p_reason), '') is null then
    perform public.raise_error('reason_required');
  end if;

  update public.driver_documents
     set status = case when p_approve then 'approved'::public.document_status else 'rejected'::public.document_status end,
         rejection_reason = case when p_approve then null else btrim(p_reason) end,
         reviewed_by = auth.uid(), reviewed_at = now()
   where id = p_document_id returning * into v_doc;

  if not p_approve then
    select * into v_driver from public.drivers where id = v_doc.driver_id;
    perform public.notify(v_driver.profile_id, 'document_rejected',
      jsonb_build_object('type', v_doc.type::text, 'reason', btrim(p_reason)),
      jsonb_build_object('screen', 'application'));
  end if;
  perform public.log_audit('review_document', 'driver_documents', p_document_id,
    jsonb_build_object('approve', p_approve, 'reason', p_reason, 'type', v_doc.type));
  return v_doc;
end $$;

-- Suspension / réactivation d'un chauffeur déjà validé
create or replace function public.admin_set_driver_status(p_driver_id uuid, p_status public.driver_status, p_reason text default null)
returns public.drivers
language plpgsql security definer
set search_path = public
as $$
declare
  v_driver public.drivers;
begin
  perform public.require_admin_role('super_admin', 'validator');
  if p_status not in ('approved', 'suspended') then
    perform public.raise_error('invalid_driver_status');
  end if;

  select * into v_driver from public.drivers where id = p_driver_id for update;
  if not found then
    perform public.raise_error('driver_not_found');
  end if;
  if v_driver.status not in ('approved', 'suspended') then
    perform public.raise_error('invalid_driver_status');
  end if;
  if p_status = 'suspended' and nullif(btrim(p_reason), '') is null then
    perform public.raise_error('reason_required');
  end if;

  update public.drivers
     set status = p_status, is_available = case when p_status = 'suspended' then false else is_available end,
         rejection_reason = case when p_status = 'suspended' then btrim(p_reason) else null end
   where id = p_driver_id returning * into v_driver;

  perform public.notify(v_driver.profile_id,
    case when p_status = 'suspended' then 'driver_suspended' else 'driver_reinstated' end,
    jsonb_build_object('reason', coalesce(btrim(p_reason), '-')), jsonb_build_object('screen', 'home'));
  perform public.log_audit('set_driver_status', 'drivers', p_driver_id,
    jsonb_build_object('status', p_status, 'reason', p_reason));
  return v_driver;
end $$;

-- Suspension / blocage d'un compte (client, chauffeur ou admin)
create or replace function public.admin_set_account_status(p_profile_id uuid, p_status public.account_status, p_reason text default null)
returns public.profiles
language plpgsql security definer
set search_path = public
as $$
declare
  v_target public.profiles;
begin
  if auth.uid() is null then
    perform public.raise_error('not_authenticated');
  end if;
  if p_profile_id = auth.uid() then
    perform public.raise_error('cannot_modify_self');
  end if;

  select * into v_target from public.profiles where id = p_profile_id for update;
  if not found then
    perform public.raise_error('profile_not_found');
  end if;

  if v_target.role = 'admin' then
    perform public.require_admin_role('super_admin');
  elsif v_target.role = 'driver' then
    perform public.require_admin_role('super_admin', 'validator', 'support');
  else
    perform public.require_admin_role('super_admin', 'support');
  end if;

  update public.profiles set status = p_status where id = p_profile_id returning * into v_target;
  if p_status <> 'active' and v_target.role = 'driver' then
    update public.drivers set is_available = false where profile_id = p_profile_id;
  end if;

  perform public.notify(p_profile_id, 'account_status_changed',
    jsonb_build_object('status', p_status::text, 'reason', coalesce(btrim(p_reason), '-')), '{}'::jsonb);
  perform public.log_audit('set_account_status', 'profiles', p_profile_id,
    jsonb_build_object('status', p_status, 'reason', p_reason));
  return v_target;
end $$;

create or replace function public.admin_set_admin_role(p_profile_id uuid, p_admin_role public.admin_role)
returns public.profiles
language plpgsql security definer
set search_path = public
as $$
declare
  v_target public.profiles;
begin
  perform public.require_admin_role('super_admin');
  if p_profile_id = auth.uid() then
    perform public.raise_error('cannot_modify_self');
  end if;
  update public.profiles set admin_role = p_admin_role
   where id = p_profile_id and role = 'admin' returning * into v_target;
  if not found then
    perform public.raise_error('profile_not_found');
  end if;
  perform public.log_audit('set_admin_role', 'profiles', p_profile_id, jsonb_build_object('admin_role', p_admin_role));
  return v_target;
end $$;

-- ---------------------------------------------------------------------------
-- Portefeuilles
-- ---------------------------------------------------------------------------
create or replace function public.admin_review_topup(p_topup_id uuid, p_approve boolean, p_note text default null)
returns public.topup_requests
language plpgsql security definer
set search_path = public
as $$
declare
  v_req    public.topup_requests;
  v_wallet public.wallets;
  v_driver public.drivers;
begin
  perform public.require_admin_role('super_admin', 'support');

  select * into v_req from public.topup_requests where id = p_topup_id for update;
  if not found then
    perform public.raise_error('topup_not_found');
  end if;
  if v_req.status <> 'pending' then
    perform public.raise_error('topup_already_reviewed');
  end if;
  if not p_approve and nullif(btrim(p_note), '') is null then
    perform public.raise_error('reason_required');
  end if;

  select * into v_driver from public.drivers where id = v_req.driver_id;

  if p_approve then
    select * into v_wallet from public.wallets where driver_id = v_req.driver_id for update;
    if not found then
      perform public.raise_error('wallet_not_found');
    end if;
    update public.wallets set balance = balance + v_req.amount where id = v_wallet.id returning * into v_wallet;
    insert into public.wallet_transactions (wallet_id, type, amount, balance_after, topup_request_id, note, created_by)
    values (v_wallet.id, 'topup', v_req.amount, v_wallet.balance, v_req.id, nullif(btrim(p_note), ''), auth.uid());
  end if;

  update public.topup_requests
     set status = case when p_approve then 'approved'::public.topup_status else 'rejected'::public.topup_status end,
         review_note = nullif(btrim(p_note), ''), reviewed_by = auth.uid(), reviewed_at = now()
   where id = p_topup_id returning * into v_req;

  perform public.notify(v_driver.profile_id,
    case when p_approve then 'topup_approved' else 'topup_rejected' end,
    jsonb_build_object('amount', v_req.amount::text, 'reason', coalesce(btrim(p_note), '-')),
    jsonb_build_object('screen', 'wallet'));
  perform public.log_audit('review_topup', 'topup_requests', p_topup_id,
    jsonb_build_object('approve', p_approve, 'amount', v_req.amount, 'note', p_note));
  return v_req;
end $$;

create or replace function public.admin_adjust_wallet(p_driver_id uuid, p_amount int, p_note text)
returns public.wallets
language plpgsql security definer
set search_path = public
as $$
declare
  v_wallet public.wallets;
  v_driver public.drivers;
begin
  perform public.require_admin_role('super_admin');
  if p_amount is null or p_amount = 0 then
    perform public.raise_error('invalid_amount');
  end if;
  if nullif(btrim(p_note), '') is null then
    perform public.raise_error('reason_required');
  end if;

  select * into v_driver from public.drivers where id = p_driver_id;
  if not found then
    perform public.raise_error('driver_not_found');
  end if;
  select * into v_wallet from public.wallets where driver_id = p_driver_id for update;
  if not found then
    perform public.raise_error('wallet_not_found');
  end if;
  if v_wallet.balance + p_amount < 0 then
    perform public.raise_error('insufficient_balance', format('required=%s;balance=%s', -p_amount, v_wallet.balance));
  end if;

  update public.wallets set balance = balance + p_amount where id = v_wallet.id returning * into v_wallet;
  insert into public.wallet_transactions (wallet_id, type, amount, balance_after, note, created_by)
  values (v_wallet.id, 'adjustment', p_amount, v_wallet.balance, btrim(p_note), auth.uid());

  perform public.notify(v_driver.profile_id, 'wallet_adjusted',
    jsonb_build_object('amount', p_amount::text, 'reason', btrim(p_note)), jsonb_build_object('screen', 'wallet'));
  perform public.log_audit('adjust_wallet', 'wallets', v_wallet.id,
    jsonb_build_object('driver_id', p_driver_id, 'amount', p_amount, 'note', p_note));
  return v_wallet;
end $$;

-- ---------------------------------------------------------------------------
-- Demandes créées par l'admin (clients hors application) — 1..n chauffeurs
-- ---------------------------------------------------------------------------
create or replace function public.admin_create_booking(
  p_client_name     text,
  p_client_phone    text,
  p_service_type_id uuid,
  p_city_id         uuid,
  p_pickup_text     text,
  p_dropoff_text    text,
  p_scheduled_at    timestamptz,
  p_passengers      int,
  p_notes           text,
  p_price           int,
  p_channel         public.booking_channel,
  p_driver_ids      uuid[]
)
returns public.bookings
language plpgsql security definer
set search_path = public
as $$
declare
  v_phone   text := public.normalize_phone(p_client_phone);
  v_client  uuid;
  v_booking public.bookings;
  v_driver  record;
  v_ids     uuid[];
begin
  perform public.require_admin_role('super_admin', 'support');

  if v_phone is null then
    perform public.raise_error('invalid_phone');
  end if;
  if nullif(btrim(p_client_name), '') is null then
    perform public.raise_error('client_name_required');
  end if;
  if p_channel = 'app' then
    perform public.raise_error('invalid_channel');
  end if;
  if p_price is null or p_price <= 0 then
    perform public.raise_error('invalid_price');
  end if;
  if nullif(btrim(p_pickup_text), '') is null then
    perform public.raise_error('pickup_required');
  end if;
  if p_scheduled_at is null then
    perform public.raise_error('invalid_schedule');
  end if;
  if not exists (select 1 from public.service_types where id = p_service_type_id)
     or not exists (select 1 from public.cities where id = p_city_id) then
    perform public.raise_error('invalid_service_or_city');
  end if;

  select array_agg(distinct x) into v_ids from unnest(coalesce(p_driver_ids, '{}')) x;
  if v_ids is null or cardinality(v_ids) = 0 or cardinality(v_ids) > 20 then
    perform public.raise_error('drivers_required');
  end if;
  if (select count(*) from public.drivers d join public.profiles p on p.id = d.profile_id
       where d.id = any (v_ids) and d.status = 'approved' and p.status = 'active') <> cardinality(v_ids) then
    perform public.raise_error('driver_not_available');
  end if;

  select id into v_client from public.profiles where phone = v_phone and role = 'client';

  insert into public.bookings (
    client_id, client_name, client_phone, driver_id, service_type_id, city_id,
    pickup_text, dropoff_text, scheduled_at, passengers, notes, price, status,
    channel, created_by_type, created_by, expires_at)
  values (
    v_client, btrim(p_client_name), v_phone,
    case when cardinality(v_ids) = 1 then v_ids[1] end,
    p_service_type_id, p_city_id, btrim(p_pickup_text), nullif(btrim(p_dropoff_text), ''),
    p_scheduled_at, greatest(coalesce(p_passengers, 1), 1), nullif(btrim(p_notes), ''), p_price, 'pending',
    p_channel, 'admin', auth.uid(), now() + public.booking_timeout_interval())
  returning * into v_booking;

  insert into public.booking_offers (booking_id, driver_id)
  select v_booking.id, unnest(v_ids);

  for v_driver in select d.profile_id from public.drivers d where d.id = any (v_ids) loop
    perform public.notify(v_driver.profile_id, 'booking_requested',
      jsonb_build_object('client', v_booking.client_name, 'price', v_booking.price::text),
      jsonb_build_object('booking_id', v_booking.id, 'screen', 'request'));
  end loop;

  perform public.log_audit('create_booking', 'bookings', v_booking.id,
    jsonb_build_object('channel', p_channel, 'drivers', v_ids, 'price', p_price));
  return v_booking;
end $$;

-- Changement de chauffeur : la commission déjà déduite est restituée, de nouvelles offres sont envoyées
create or replace function public.admin_reassign_booking(p_booking_id uuid, p_driver_ids uuid[])
returns public.bookings
language plpgsql security definer
set search_path = public
as $$
declare
  v_booking public.bookings;
  v_old     uuid;
  v_ids     uuid[];
  v_driver  record;
begin
  perform public.require_admin_role('super_admin', 'support');

  select * into v_booking from public.bookings where id = p_booking_id for update;
  if not found then
    perform public.raise_error('booking_not_found');
  end if;
  if v_booking.status not in ('pending', 'accepted', 'en_route', 'expired', 'rejected') then
    perform public.raise_error('booking_not_reassignable');
  end if;

  select array_agg(distinct x) into v_ids from unnest(coalesce(p_driver_ids, '{}')) x;
  if v_ids is null or cardinality(v_ids) = 0 or cardinality(v_ids) > 20 then
    perform public.raise_error('drivers_required');
  end if;
  if (select count(*) from public.drivers d join public.profiles p on p.id = d.profile_id
       where d.id = any (v_ids) and d.status = 'approved' and p.status = 'active') <> cardinality(v_ids) then
    perform public.raise_error('driver_not_available');
  end if;

  select d.profile_id into v_old from public.drivers d where d.id = v_booking.driver_id and v_booking.accepted_at is not null;
  perform public.refund_commission_for_booking(p_booking_id, 'reassigned');

  -- repartir de zéro : anciennes offres expirées, nouvelles offres
  update public.booking_offers set status = 'expired'
   where booking_id = p_booking_id and status in ('pending', 'accepted');
  delete from public.booking_offers
   where booking_id = p_booking_id and driver_id = any (v_ids);
  insert into public.booking_offers (booking_id, driver_id)
  select p_booking_id, unnest(v_ids);

  update public.bookings
     set status = 'pending', accepted_at = null, en_route_at = null,
         driver_id = case when cardinality(v_ids) = 1 then v_ids[1] else null end,
         expires_at = now() + public.booking_timeout_interval()
   where id = p_booking_id returning * into v_booking;

  if v_old is not null then
    perform public.notify(v_old, 'booking_reassigned_away', '{}'::jsonb, jsonb_build_object('screen', 'home'));
  end if;
  for v_driver in select d.profile_id from public.drivers d where d.id = any (v_ids) loop
    perform public.notify(v_driver.profile_id, 'booking_requested',
      jsonb_build_object('client', v_booking.client_name, 'price', v_booking.price::text),
      jsonb_build_object('booking_id', v_booking.id, 'screen', 'request'));
  end loop;
  perform public.notify(v_booking.client_id, 'booking_reassigned', '{}'::jsonb,
    jsonb_build_object('booking_id', v_booking.id, 'screen', 'booking'));
  perform public.log_audit('reassign_booking', 'bookings', p_booking_id, jsonb_build_object('drivers', v_ids));
  return v_booking;
end $$;

-- ---------------------------------------------------------------------------
-- Plaintes, avis, annonces
-- ---------------------------------------------------------------------------
create or replace function public.admin_handle_complaint(p_complaint_id uuid, p_status public.complaint_status, p_resolution text default null)
returns public.complaints
language plpgsql security definer
set search_path = public
as $$
declare
  v_row public.complaints;
begin
  perform public.require_admin_role('super_admin', 'support');
  update public.complaints
     set status = p_status, resolution = nullif(btrim(p_resolution), ''), handled_by = auth.uid()
   where id = p_complaint_id returning * into v_row;
  if not found then
    perform public.raise_error('complaint_not_found');
  end if;
  perform public.notify(v_row.author_id, 'complaint_updated',
    jsonb_build_object('status', p_status::text), jsonb_build_object('complaint_id', v_row.id, 'screen', 'complaint'));
  perform public.log_audit('handle_complaint', 'complaints', p_complaint_id,
    jsonb_build_object('status', p_status, 'resolution', p_resolution));
  return v_row;
end $$;

create or replace function public.admin_moderate_review(p_review_id uuid, p_hidden boolean)
returns public.reviews
language plpgsql security definer
set search_path = public
as $$
declare
  v_row public.reviews;
begin
  perform public.require_admin_role('super_admin', 'support');
  update public.reviews set is_hidden = p_hidden where id = p_review_id returning * into v_row;
  if not found then
    perform public.raise_error('review_not_found');
  end if;
  perform public.log_audit('moderate_review', 'reviews', p_review_id, jsonb_build_object('hidden', p_hidden));
  return v_row;
end $$;

create or replace function public.admin_send_announcement(p_audience text, p_title text, p_body text)
returns public.announcements
language plpgsql security definer
set search_path = public
as $$
declare
  v_ann   public.announcements;
  v_count int := 0;
  r       record;
begin
  perform public.require_admin_role('super_admin', 'support');
  if p_audience not in ('drivers', 'clients', 'all') then
    perform public.raise_error('invalid_audience');
  end if;
  if nullif(btrim(p_title), '') is null or nullif(btrim(p_body), '') is null then
    perform public.raise_error('text_required');
  end if;

  for r in
    select p.id from public.profiles p
     where p.status = 'active'
       and ((p_audience in ('drivers', 'all') and p.role = 'driver')
         or (p_audience in ('clients', 'all') and p.role = 'client'))
  loop
    perform public.notify_raw(r.id, btrim(p_title), btrim(p_body), jsonb_build_object('key', 'announcement', 'screen', 'inbox'));
    v_count := v_count + 1;
  end loop;

  insert into public.announcements (audience, title, body, recipients_count, created_by)
  values (p_audience, btrim(p_title), btrim(p_body), v_count, auth.uid())
  returning * into v_ann;
  perform public.log_audit('send_announcement', 'announcements', v_ann.id,
    jsonb_build_object('audience', p_audience, 'recipients', v_count));
  return v_ann;
end $$;

-- ---------------------------------------------------------------------------
-- Tableau de bord
-- ---------------------------------------------------------------------------
create or replace function public.admin_dashboard_stats()
returns jsonb
language plpgsql stable security definer
set search_path = public
as $$
begin
  perform public.require_admin_role('super_admin', 'validator', 'support');
  return jsonb_build_object(
    'pending_drivers', (select count(*) from public.drivers where status = 'pending'),
    'new_drivers_7d', (select count(*) from public.drivers where created_at >= now() - interval '7 days'),
    'approved_drivers', (select count(*) from public.drivers where status = 'approved'),
    'clients', (select count(*) from public.profiles where role = 'client'),
    'bookings_today', (select count(*) from public.bookings where created_at >= date_trunc('day', now())),
    'pending_bookings', (select count(*) from public.bookings where status = 'pending'),
    'commissions_today', coalesce((select sum(amount) from public.commissions
                                    where status = 'deducted' and created_at >= date_trunc('day', now())), 0),
    'commissions_total', coalesce((select sum(amount) from public.commissions where status = 'deducted'), 0),
    'open_complaints', (select count(*) from public.complaints where status in ('open', 'in_review')),
    'pending_topups', (select count(*) from public.topup_requests where status = 'pending')
  );
end $$;
