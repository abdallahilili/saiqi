-- =============================================================================
-- SAIQI — 04 : logique métier sensible (commission, wallet, réservations)
-- Toute la logique financière vit ici (SECURITY DEFINER, search_path figé).
-- Les erreurs métier sont des exceptions P0001 dont le MESSAGE est un code stable.
-- =============================================================================

-- ---------------------------------------------------------------------------
-- Paramètres et commission
-- ---------------------------------------------------------------------------
create or replace function public.get_setting_numeric(p_key text, p_default numeric)
returns numeric
language sql stable security definer
set search_path = public
as $$
  select coalesce((select (s.value #>> '{}')::numeric from public.app_settings s where s.key = p_key), p_default);
$$;

-- Priorité : service+ville > service > ville > défaut (app_settings.default_commission_rate)
create or replace function public.resolve_commission_rate(p_service_type_id uuid, p_city_id uuid)
returns numeric
language plpgsql stable security definer
set search_path = public
as $$
declare
  r numeric;
begin
  select cr.rate into r from public.commission_rates cr
   where cr.service_type_id = p_service_type_id and cr.city_id = p_city_id;
  if found then return r; end if;

  select cr.rate into r from public.commission_rates cr
   where cr.service_type_id = p_service_type_id and cr.city_id is null;
  if found then return r; end if;

  select cr.rate into r from public.commission_rates cr
   where cr.service_type_id is null and cr.city_id = p_city_id;
  if found then return r; end if;

  return public.get_setting_numeric('default_commission_rate', 0.10);
end $$;

-- Commission en MRU entiers (arrondi à l'entier le plus proche)
create or replace function public.compute_commission(p_price int, p_rate numeric)
returns int
language sql immutable
set search_path = public
as $$
  select round(greatest(p_price, 0)::numeric * p_rate)::int;
$$;

-- ---------------------------------------------------------------------------
-- Aides internes
-- ---------------------------------------------------------------------------
-- Annule la commission déduite d'une réservation (restitution sur le wallet). Appelée avec la réservation déjà verrouillée.
create or replace function public.refund_commission_for_booking(p_booking_id uuid, p_note text default null)
returns int
language plpgsql security definer
set search_path = public
as $$
declare
  v_comm   public.commissions;
  v_wallet public.wallets;
begin
  select * into v_comm from public.commissions
   where booking_id = p_booking_id and status = 'deducted' for update;
  if not found then
    return 0;
  end if;

  select * into v_wallet from public.wallets where driver_id = v_comm.driver_id for update;
  update public.wallets set balance = balance + v_comm.amount where id = v_wallet.id returning * into v_wallet;

  if v_comm.amount > 0 then
    insert into public.wallet_transactions (wallet_id, type, amount, balance_after, booking_id, note, created_by)
    values (v_wallet.id, 'refund', v_comm.amount, v_wallet.balance, p_booking_id, p_note, auth.uid());
  end if;
  update public.commissions set status = 'refunded' where id = v_comm.id;
  return v_comm.amount;
end $$;

create or replace function public.booking_timeout_interval()
returns interval
language sql stable security definer
set search_path = public
as $$
  select make_interval(mins => greatest(1, public.get_setting_numeric('response_timeout_minutes', 10)::int));
$$;

-- ---------------------------------------------------------------------------
-- Création d'une réservation par un client (canal app)
-- ---------------------------------------------------------------------------
create or replace function public.create_booking(
  p_driver_id       uuid,
  p_service_type_id uuid,
  p_city_id         uuid,
  p_pickup_text     text,
  p_dropoff_text    text,
  p_scheduled_at    timestamptz,
  p_passengers      int default 1,
  p_notes           text default null
)
returns public.bookings
language plpgsql security definer
set search_path = public
as $$
declare
  v_uid     uuid := auth.uid();
  v_client  public.profiles;
  v_driver  public.drivers;
  v_dprof   public.profiles;
  v_service public.driver_services;
  v_seats   int;
  v_booking public.bookings;
begin
  if v_uid is null then
    perform public.raise_error('not_authenticated');
  end if;
  select * into v_client from public.profiles where id = v_uid and role = 'client' and status = 'active';
  if not found then
    perform public.raise_error('not_client');
  end if;

  select * into v_driver from public.drivers where id = p_driver_id;
  if not found or v_driver.status <> 'approved' then
    perform public.raise_error('driver_not_available');
  end if;
  select * into v_dprof from public.profiles where id = v_driver.profile_id;
  if v_dprof.status <> 'active' or not v_driver.is_available then
    perform public.raise_error('driver_not_available');
  end if;

  select * into v_service from public.driver_services ds
   where ds.driver_id = p_driver_id and ds.service_type_id = p_service_type_id and ds.is_active
     and p_city_id = any (ds.city_ids);
  if not found then
    perform public.raise_error('service_not_offered');
  end if;

  if not exists (select 1 from public.service_types where id = p_service_type_id and is_active)
     or not exists (select 1 from public.cities where id = p_city_id and is_active) then
    perform public.raise_error('invalid_service_or_city');
  end if;

  if nullif(btrim(p_pickup_text), '') is null then
    perform public.raise_error('pickup_required');
  end if;
  if p_scheduled_at is null or p_scheduled_at < now() - interval '5 minutes' then
    perform public.raise_error('invalid_schedule');
  end if;
  if coalesce(p_passengers, 0) < 1 then
    perform public.raise_error('invalid_passengers');
  end if;
  select seats into v_seats from public.vehicles where driver_id = p_driver_id;
  if v_seats is not null and p_passengers > v_seats then
    perform public.raise_error('too_many_passengers');
  end if;

  if (select count(*) from public.bookings where client_id = v_uid and status = 'pending') >= 10 then
    perform public.raise_error('too_many_pending');
  end if;

  insert into public.bookings (
    client_id, client_name, client_phone, driver_id, service_type_id, city_id,
    pickup_text, dropoff_text, scheduled_at, passengers, notes, price, status,
    channel, created_by_type, created_by, expires_at)
  values (
    v_uid, coalesce(v_client.full_name, v_client.phone), v_client.phone, p_driver_id, p_service_type_id, p_city_id,
    btrim(p_pickup_text), nullif(btrim(p_dropoff_text), ''), p_scheduled_at, p_passengers, nullif(btrim(p_notes), ''),
    v_service.price, 'pending', 'app', 'client', v_uid, now() + public.booking_timeout_interval())
  returning * into v_booking;

  insert into public.booking_offers (booking_id, driver_id) values (v_booking.id, p_driver_id);

  perform public.notify(v_driver.profile_id, 'booking_requested',
    jsonb_build_object('client', v_booking.client_name, 'price', v_booking.price::text),
    jsonb_build_object('booking_id', v_booking.id, 'screen', 'request'));

  return v_booking;
end $$;

-- ---------------------------------------------------------------------------
-- Acceptation (atomique) : le premier chauffeur qui accepte l'obtient
-- ---------------------------------------------------------------------------
create or replace function public.accept_booking(p_booking_id uuid)
returns public.bookings
language plpgsql security definer
set search_path = public
as $$
declare
  v_uid        uuid := auth.uid();
  v_driver     public.drivers;
  v_booking    public.bookings;
  v_offer      public.booking_offers;
  v_wallet     public.wallets;
  v_rate       numeric;
  v_commission int;
  v_low        numeric;
begin
  if v_uid is null then
    perform public.raise_error('not_authenticated');
  end if;

  select d.* into v_driver
    from public.drivers d join public.profiles p on p.id = d.profile_id
   where d.profile_id = v_uid and p.role = 'driver' and p.status = 'active';
  if not found or v_driver.status <> 'approved' then
    perform public.raise_error('driver_not_approved');
  end if;

  -- 1) verrou de la réservation : sérialise les acceptations concurrentes
  select * into v_booking from public.bookings where id = p_booking_id for update;
  if not found then
    perform public.raise_error('booking_not_found');
  end if;
  if v_booking.status <> 'pending' then
    perform public.raise_error('booking_not_available');
  end if;
  if v_booking.expires_at is not null and v_booking.expires_at <= now() then
    perform public.raise_error('booking_expired');
  end if;

  -- 2) offre du chauffeur
  select * into v_offer from public.booking_offers
   where booking_id = p_booking_id and driver_id = v_driver.id for update;
  if not found or v_offer.status <> 'pending' then
    perform public.raise_error('offer_not_available');
  end if;

  -- 3) verrou du wallet puis contrôle du solde
  select * into v_wallet from public.wallets where driver_id = v_driver.id for update;
  if not found then
    perform public.raise_error('wallet_not_found');
  end if;
  v_rate := public.resolve_commission_rate(v_booking.service_type_id, v_booking.city_id);
  v_commission := public.compute_commission(v_booking.price, v_rate);
  if v_wallet.balance < v_commission then
    perform public.raise_error('insufficient_balance',
      format('required=%s;balance=%s', v_commission, v_wallet.balance));
  end if;

  -- 4) débit + traçabilité
  update public.wallets set balance = balance - v_commission where id = v_wallet.id returning * into v_wallet;
  if v_commission > 0 then
    insert into public.wallet_transactions (wallet_id, type, amount, balance_after, booking_id, created_by)
    values (v_wallet.id, 'commission', -v_commission, v_wallet.balance, p_booking_id, v_uid);
  end if;
  insert into public.commissions (booking_id, driver_id, rate, amount, status)
  values (p_booking_id, v_driver.id, v_rate, v_commission, 'deducted');

  -- 5) offres : la mienne acceptée, les autres expirées
  update public.booking_offers set status = 'accepted' where id = v_offer.id;
  update public.booking_offers set status = 'expired'
   where booking_id = p_booking_id and id <> v_offer.id and status = 'pending';

  -- 6) réservation
  update public.bookings
     set status = 'accepted', driver_id = v_driver.id, accepted_at = now()
   where id = p_booking_id returning * into v_booking;

  -- 7) notifications
  perform public.notify(v_booking.client_id, 'booking_accepted',
    jsonb_build_object('price', v_booking.price::text),
    jsonb_build_object('booking_id', v_booking.id, 'screen', 'booking'));
  if v_booking.created_by_type = 'admin' then
    perform public.notify(v_booking.created_by, 'booking_accepted_admin',
      jsonb_build_object('client', v_booking.client_name),
      jsonb_build_object('booking_id', v_booking.id, 'screen', 'booking'));
  end if;
  v_low := public.get_setting_numeric('low_balance_threshold', 100);
  if v_wallet.balance < v_low then
    perform public.notify(v_driver.profile_id, 'wallet_low',
      jsonb_build_object('balance', v_wallet.balance::text),
      jsonb_build_object('screen', 'wallet'));
  end if;

  return v_booking;
end $$;

-- ---------------------------------------------------------------------------
-- Refus d'une demande par un chauffeur
-- ---------------------------------------------------------------------------
create or replace function public.reject_booking(p_booking_id uuid)
returns void
language plpgsql security definer
set search_path = public
as $$
declare
  v_driver  public.drivers;
  v_booking public.bookings;
  v_offer   public.booking_offers;
begin
  select * into v_driver from public.drivers where profile_id = auth.uid() and status = 'approved';
  if not found then
    perform public.raise_error('driver_not_approved');
  end if;

  select * into v_booking from public.bookings where id = p_booking_id for update;
  if not found then
    perform public.raise_error('booking_not_found');
  end if;
  if v_booking.status <> 'pending' then
    perform public.raise_error('booking_not_available');
  end if;

  select * into v_offer from public.booking_offers
   where booking_id = p_booking_id and driver_id = v_driver.id for update;
  if not found or v_offer.status <> 'pending' then
    perform public.raise_error('offer_not_available');
  end if;

  update public.booking_offers set status = 'declined' where id = v_offer.id;

  if not exists (select 1 from public.booking_offers where booking_id = p_booking_id and status = 'pending') then
    update public.bookings set status = 'rejected' where id = p_booking_id returning * into v_booking;
    perform public.notify(v_booking.client_id, 'booking_rejected', '{}'::jsonb,
      jsonb_build_object('booking_id', v_booking.id, 'screen', 'booking'));
    if v_booking.created_by_type = 'admin' then
      perform public.notify(v_booking.created_by, 'booking_rejected_admin',
        jsonb_build_object('client', v_booking.client_name),
        jsonb_build_object('booking_id', v_booking.id, 'screen', 'booking'));
    end if;
  end if;
end $$;

-- ---------------------------------------------------------------------------
-- Déroulement de la course : accepted -> en_route -> in_progress -> completed
-- ---------------------------------------------------------------------------
create or replace function public.update_booking_status(p_booking_id uuid, p_new_status public.booking_status)
returns public.bookings
language plpgsql security definer
set search_path = public
as $$
declare
  v_driver  public.drivers;
  v_booking public.bookings;
  v_key     text;
begin
  select * into v_driver from public.drivers where profile_id = auth.uid() and status = 'approved';
  if not found then
    perform public.raise_error('driver_not_approved');
  end if;

  select * into v_booking from public.bookings where id = p_booking_id for update;
  if not found then
    perform public.raise_error('booking_not_found');
  end if;
  if v_booking.driver_id is distinct from v_driver.id then
    perform public.raise_error('not_allowed');
  end if;

  if not (
       (v_booking.status = 'accepted'    and p_new_status = 'en_route')
    or (v_booking.status = 'en_route'    and p_new_status = 'in_progress')
    or (v_booking.status = 'in_progress' and p_new_status = 'completed')
  ) then
    perform public.raise_error('invalid_transition',
      format('from=%s;to=%s', v_booking.status, p_new_status));
  end if;

  update public.bookings
     set status = p_new_status,
         en_route_at  = case when p_new_status = 'en_route'    then now() else en_route_at end,
         started_at   = case when p_new_status = 'in_progress' then now() else started_at end,
         completed_at = case when p_new_status = 'completed'   then now() else completed_at end
   where id = p_booking_id returning * into v_booking;

  if p_new_status = 'completed' then
    update public.drivers set completed_count = completed_count + 1 where id = v_driver.id;
  end if;

  v_key := case p_new_status
             when 'en_route' then 'booking_en_route'
             when 'in_progress' then 'booking_in_progress'
             else 'booking_completed' end;
  perform public.notify(v_booking.client_id, v_key, '{}'::jsonb,
    jsonb_build_object('booking_id', v_booking.id, 'screen', 'booking'));
  return v_booking;
end $$;

-- ---------------------------------------------------------------------------
-- Annulation (client avant en_route, chauffeur, ou admin) + restitution de la commission
-- ---------------------------------------------------------------------------
create or replace function public.cancel_booking(p_booking_id uuid, p_reason text default null)
returns public.bookings
language plpgsql security definer
set search_path = public
as $$
declare
  v_uid      uuid := auth.uid();
  v_booking  public.bookings;
  v_dprofile uuid;
  v_actor    text;
  v_refunded int;
begin
  if v_uid is null then
    perform public.raise_error('not_authenticated');
  end if;

  select * into v_booking from public.bookings where id = p_booking_id for update;
  if not found then
    perform public.raise_error('booking_not_found');
  end if;
  if v_booking.status in ('completed', 'cancelled', 'rejected', 'expired') then
    perform public.raise_error('booking_not_cancellable');
  end if;

  select d.profile_id into v_dprofile from public.drivers d where d.id = v_booking.driver_id;

  if public.has_admin_role('super_admin', 'support') then
    v_actor := 'admin';
  elsif v_uid = v_booking.client_id then
    v_actor := 'client';
    if v_booking.status not in ('pending', 'accepted') then
      perform public.raise_error('cancel_not_allowed_after_en_route');
    end if;
  elsif v_dprofile is not null and v_uid = v_dprofile and v_booking.accepted_at is not null then
    v_actor := 'driver';
  else
    perform public.raise_error('not_allowed');
  end if;

  v_refunded := public.refund_commission_for_booking(
    p_booking_id, coalesce(nullif(btrim(p_reason), ''), 'cancel_' || v_actor));

  update public.booking_offers set status = 'expired' where booking_id = p_booking_id and status = 'pending';
  update public.bookings
     set status = 'cancelled', cancelled_by = v_uid, cancel_reason = nullif(btrim(p_reason), '')
   where id = p_booking_id returning * into v_booking;

  -- notifications aux autres parties
  if v_actor <> 'client' then
    perform public.notify(v_booking.client_id, 'booking_cancelled',
      jsonb_build_object('reason', coalesce(v_booking.cancel_reason, '-')),
      jsonb_build_object('booking_id', v_booking.id, 'screen', 'booking'));
  end if;
  if v_actor <> 'driver' and v_dprofile is not null then
    perform public.notify(v_dprofile, 'booking_cancelled',
      jsonb_build_object('reason', coalesce(v_booking.cancel_reason, '-')),
      jsonb_build_object('booking_id', v_booking.id, 'screen', 'booking'));
  end if;
  if v_booking.created_by_type = 'admin' and v_actor <> 'admin' then
    perform public.notify(v_booking.created_by, 'booking_cancelled_admin',
      jsonb_build_object('client', v_booking.client_name),
      jsonb_build_object('booking_id', v_booking.id, 'screen', 'booking'));
  end if;
  if v_actor = 'admin' then
    perform public.log_audit('cancel_booking', 'bookings', p_booking_id,
      jsonb_build_object('reason', v_booking.cancel_reason, 'refunded', v_refunded));
  end if;
  return v_booking;
end $$;

-- ---------------------------------------------------------------------------
-- Expiration automatique (pg_cron chaque minute)
-- ---------------------------------------------------------------------------
create or replace function public.expire_pending_bookings()
returns int
language plpgsql security definer
set search_path = public
as $$
declare
  r       record;
  v_b     public.bookings;
  v_count int := 0;
begin
  for r in
    select b.id from public.bookings b
     where b.status = 'pending' and b.expires_at is not null and b.expires_at <= now()
     order by b.expires_at
     for update skip locked
  loop
    update public.booking_offers set status = 'expired' where booking_id = r.id and status = 'pending';
    update public.bookings set status = 'expired' where id = r.id returning * into v_b;

    perform public.notify(v_b.client_id, 'booking_expired', '{}'::jsonb,
              jsonb_build_object('booking_id', v_b.id, 'screen', 'booking'));
    if v_b.created_by_type = 'admin' then
      perform public.notify(v_b.created_by, 'booking_expired_admin',
                jsonb_build_object('client', v_b.client_name),
                jsonb_build_object('booking_id', v_b.id, 'screen', 'booking'));
    end if;
    v_count := v_count + 1;
  end loop;
  return v_count;
end $$;

-- ---------------------------------------------------------------------------
-- Contact : téléphones visibles UNIQUEMENT après acceptation
-- ---------------------------------------------------------------------------
create or replace function public.get_booking_contact(p_booking_id uuid)
returns table (full_name text, phone text)
language plpgsql stable security definer
set search_path = public
as $$
declare
  v_uid      uuid := auth.uid();
  b          public.bookings;
  v_dprofile uuid;
begin
  select * into b from public.bookings where id = p_booking_id;
  if not found then
    perform public.raise_error('booking_not_found');
  end if;
  if b.status not in ('accepted', 'en_route', 'in_progress', 'completed') then
    perform public.raise_error('contact_not_available');
  end if;
  select d.profile_id into v_dprofile from public.drivers d where d.id = b.driver_id;

  if v_uid is not null and v_uid = b.client_id then
    return query select p.full_name, p.phone from public.profiles p where p.id = v_dprofile;
  elsif v_uid is not null and v_uid = v_dprofile then
    return query select b.client_name, b.client_phone;
  else
    perform public.raise_error('not_allowed');
  end if;
end $$;

-- Informations (sans téléphone) du chauffeur d'une réservation, pour le client concerné
create or replace function public.get_booking_driver(p_booking_id uuid)
returns table (
  driver_id uuid, full_name text, avatar_url text, rating_avg numeric, rating_count int,
  vehicle_brand text, vehicle_model text, vehicle_color text, vehicle_plate text, vehicle_photo text)
language plpgsql stable security definer
set search_path = public
as $$
declare
  b public.bookings;
begin
  select * into b from public.bookings where id = p_booking_id;
  if not found or b.driver_id is null then
    return;
  end if;
  if not (auth.uid() = b.client_id or public.is_admin()) then
    perform public.raise_error('not_allowed');
  end if;
  return query
    select d.id, p.full_name, p.avatar_url, d.rating_avg, d.rating_count,
           v.brand, v.model, v.color,
           case when b.status in ('accepted', 'en_route', 'in_progress', 'completed') then v.plate end,
           v.photo_paths[1]
      from public.drivers d
      join public.profiles p on p.id = d.profile_id
      left join public.vehicles v on v.driver_id = d.id
     where d.id = b.driver_id;
end $$;

-- ---------------------------------------------------------------------------
-- Recharge du wallet (demande) — la validation est faite par un admin
-- ---------------------------------------------------------------------------
create or replace function public.request_topup(
  p_amount     int,
  p_method     text,
  p_reference  text default null,
  p_proof_path text default null
)
returns public.topup_requests
language plpgsql security definer
set search_path = public
as $$
declare
  v_driver public.drivers;
  v_min    int := public.get_setting_numeric('min_topup_amount', 100)::int;
  v_req    public.topup_requests;
begin
  select * into v_driver from public.drivers where profile_id = auth.uid() and status = 'approved';
  if not found then
    perform public.raise_error('driver_not_approved');
  end if;
  if p_amount is null or p_amount < v_min then
    perform public.raise_error('amount_too_low', format('min=%s', v_min));
  end if;
  if nullif(btrim(p_method), '') is null then
    perform public.raise_error('method_required');
  end if;
  if p_proof_path is not null and p_proof_path not like auth.uid()::text || '/%' then
    perform public.raise_error('invalid_path');
  end if;

  insert into public.topup_requests (driver_id, amount, method, reference, proof_path)
  values (v_driver.id, p_amount, btrim(p_method), nullif(btrim(p_reference), ''), p_proof_path)
  returning * into v_req;

  perform public.notify_admins('topup_requested',
    jsonb_build_object('amount', p_amount::text),
    jsonb_build_object('topup_id', v_req.id, 'screen', 'topup'));
  return v_req;
end $$;

-- ---------------------------------------------------------------------------
-- Avis (un seul par réservation, uniquement si completed)
-- ---------------------------------------------------------------------------
create or replace function public.submit_review(p_booking_id uuid, p_rating int, p_comment text default null)
returns public.reviews
language plpgsql security definer
set search_path = public
as $$
declare
  v_uid     uuid := auth.uid();
  v_booking public.bookings;
  v_review  public.reviews;
  v_dprof   uuid;
begin
  select * into v_booking from public.bookings where id = p_booking_id;
  if not found or v_booking.client_id is distinct from v_uid then
    perform public.raise_error('not_allowed');
  end if;
  if v_booking.status <> 'completed' then
    perform public.raise_error('booking_not_completed');
  end if;
  if p_rating is null or p_rating < 1 or p_rating > 5 then
    perform public.raise_error('invalid_rating');
  end if;
  if exists (select 1 from public.reviews where booking_id = p_booking_id) then
    perform public.raise_error('already_reviewed');
  end if;

  insert into public.reviews (booking_id, client_id, driver_id, rating, comment)
  values (p_booking_id, v_uid, v_booking.driver_id, p_rating, nullif(btrim(p_comment), ''))
  returning * into v_review;

  select profile_id into v_dprof from public.drivers where id = v_booking.driver_id;
  perform public.notify(v_dprof, 'new_review', jsonb_build_object('rating', p_rating::text),
    jsonb_build_object('booking_id', p_booking_id, 'screen', 'reviews'));
  return v_review;
end $$;

-- ---------------------------------------------------------------------------
-- Plaintes / signalements (liés ou non à une réservation)
-- ---------------------------------------------------------------------------
create or replace function public.file_complaint(p_booking_id uuid, p_text text)
returns public.complaints
language plpgsql security definer
set search_path = public
as $$
declare
  v_uid      uuid := auth.uid();
  v_booking  public.bookings;
  v_dprofile uuid;
  v_against  uuid;
  v_row      public.complaints;
begin
  if v_uid is null then
    perform public.raise_error('not_authenticated');
  end if;
  if p_text is null or char_length(btrim(p_text)) < 5 then
    perform public.raise_error('text_too_short');
  end if;

  if p_booking_id is not null then
    select * into v_booking from public.bookings where id = p_booking_id;
    if not found then
      perform public.raise_error('booking_not_found');
    end if;
    select d.profile_id into v_dprofile from public.drivers d where d.id = v_booking.driver_id;
    if v_uid = v_booking.client_id then
      v_against := v_dprofile;
    elsif v_uid = v_dprofile and v_booking.accepted_at is not null then
      v_against := v_booking.client_id;
    else
      perform public.raise_error('not_allowed');
    end if;
  end if;

  insert into public.complaints (booking_id, author_id, against_id, text)
  values (p_booking_id, v_uid, v_against, btrim(p_text))
  returning * into v_row;

  perform public.notify_admins('complaint_filed', '{}'::jsonb,
    jsonb_build_object('complaint_id', v_row.id, 'screen', 'complaint'));
  return v_row;
end $$;

-- ---------------------------------------------------------------------------
-- Côté chauffeur : documents, soumission du dossier, disponibilité, statistiques
-- ---------------------------------------------------------------------------
create or replace function public.save_driver_document(p_type public.document_type, p_file_path text)
returns public.driver_documents
language plpgsql security definer
set search_path = public
as $$
declare
  v_driver public.drivers;
  v_doc    public.driver_documents;
begin
  select * into v_driver from public.drivers where profile_id = auth.uid();
  if not found then
    perform public.raise_error('not_driver');
  end if;
  if p_file_path is null or p_file_path not like auth.uid()::text || '/%' then
    perform public.raise_error('invalid_path');
  end if;

  insert into public.driver_documents (driver_id, type, file_path, status)
  values (v_driver.id, p_type, p_file_path, 'pending')
  on conflict (driver_id, type) do update
    set file_path = excluded.file_path, status = 'pending',
        rejection_reason = null, reviewed_by = null, reviewed_at = null
  returning * into v_doc;
  return v_doc;
end $$;

create or replace function public.submit_driver_application()
returns public.drivers
language plpgsql security definer
set search_path = public
as $$
declare
  v_driver  public.drivers;
  v_profile public.profiles;
  v_missing text[] := '{}';
  t         public.document_type;
begin
  select * into v_driver from public.drivers where profile_id = auth.uid() for update;
  if not found then
    perform public.raise_error('not_driver');
  end if;
  if v_driver.status not in ('draft', 'rejected') then
    perform public.raise_error('invalid_driver_status');
  end if;
  select * into v_profile from public.profiles where id = auth.uid();

  if nullif(btrim(v_profile.full_name), '') is null then v_missing := v_missing || 'full_name'; end if;
  if v_driver.city_id is null then v_missing := v_missing || 'city'; end if;
  if not exists (select 1 from public.vehicles where driver_id = v_driver.id) then v_missing := v_missing || 'vehicle'; end if;
  if not exists (select 1 from public.driver_services where driver_id = v_driver.id and is_active) then
    v_missing := v_missing || 'services';
  end if;
  foreach t in array array['id_card', 'driving_license', 'vehicle_registration', 'photo']::public.document_type[] loop
    if not exists (select 1 from public.driver_documents
                    where driver_id = v_driver.id and type = t and status <> 'rejected') then
      v_missing := v_missing || ('doc:' || t::text);
    end if;
  end loop;

  if cardinality(v_missing) > 0 then
    perform public.raise_error('application_incomplete', 'missing=' || array_to_string(v_missing, ','));
  end if;

  update public.drivers
     set status = 'pending', submitted_at = now(), rejection_reason = null
   where id = v_driver.id returning * into v_driver;

  perform public.notify_admins('driver_submitted',
    jsonb_build_object('name', coalesce(v_profile.full_name, v_profile.phone)),
    jsonb_build_object('driver_id', v_driver.id, 'screen', 'driver'),
    array['super_admin', 'validator']::public.admin_role[]);
  return v_driver;
end $$;

create or replace function public.set_driver_availability(p_available boolean)
returns public.drivers
language plpgsql security definer
set search_path = public
as $$
declare
  v_driver public.drivers;
begin
  select d.* into v_driver
    from public.drivers d join public.profiles p on p.id = d.profile_id
   where d.profile_id = auth.uid() and d.status = 'approved' and p.status = 'active' for update of d;
  if not found then
    perform public.raise_error('driver_not_approved');
  end if;
  update public.drivers set is_available = p_available where id = v_driver.id returning * into v_driver;
  return v_driver;
end $$;

create or replace function public.driver_stats()
returns jsonb
language plpgsql stable security definer
set search_path = public
as $$
declare
  v_driver public.drivers;
begin
  select * into v_driver from public.drivers where profile_id = auth.uid();
  if not found then
    perform public.raise_error('not_driver');
  end if;
  return jsonb_build_object(
    'completed_count', v_driver.completed_count,
    'rating_avg', v_driver.rating_avg,
    'rating_count', v_driver.rating_count,
    'revenue_gross', coalesce((select sum(b.price) from public.bookings b
                                where b.driver_id = v_driver.id and b.status = 'completed'), 0),
    'commissions_paid', coalesce((select sum(c.amount) from public.commissions c
                                   where c.driver_id = v_driver.id and c.status = 'deducted'), 0),
    'pending_requests', (select count(*) from public.booking_offers o
                          join public.bookings b on b.id = o.booking_id
                          where o.driver_id = v_driver.id and o.status = 'pending' and b.status = 'pending'),
    'upcoming_count', (select count(*) from public.bookings b
                        where b.driver_id = v_driver.id and b.status in ('accepted', 'en_route', 'in_progress'))
  );
end $$;

-- ---------------------------------------------------------------------------
-- Recherche de chauffeurs (liste côté client)
-- ---------------------------------------------------------------------------
create or replace function public.search_drivers(
  p_city_id         uuid default null,
  p_service_type_id uuid default null,
  p_min_price       int default null,
  p_max_price       int default null,
  p_min_rating      numeric default null,
  p_min_seats       int default null,
  p_vehicle_type    text default null,
  p_only_available  boolean default true,
  p_sort            text default 'rating',
  p_limit           int default 50,
  p_offset          int default 0
)
returns table (
  driver_id uuid, full_name text, avatar_url text, city_id uuid,
  rating_avg numeric, rating_count int, completed_count int, is_available boolean, years_experience int,
  vehicle_type text, vehicle_brand text, vehicle_model text, vehicle_year int, vehicle_color text,
  seats int, vehicle_photo text,
  service_type_id uuid, price int, price_unit public.price_unit)
language sql stable security definer
set search_path = public
as $$
  select d.id, p.full_name, p.avatar_url, d.city_id,
         d.rating_avg, d.rating_count, d.completed_count, d.is_available, d.years_experience,
         v.vehicle_type, v.brand, v.model, v.year, v.color,
         v.seats, v.photo_paths[1],
         s.service_type_id, s.price, s.price_unit
    from public.drivers d
    join public.profiles p on p.id = d.profile_id and p.status = 'active'
    left join public.vehicles v on v.driver_id = d.id
    join lateral (
      select ds.service_type_id, ds.price, ds.price_unit
        from public.driver_services ds
       where ds.driver_id = d.id and ds.is_active
         and (p_service_type_id is null or ds.service_type_id = p_service_type_id)
         and (p_city_id is null or p_city_id = any (ds.city_ids))
         and (p_min_price is null or ds.price >= p_min_price)
         and (p_max_price is null or ds.price <= p_max_price)
       order by ds.price
       limit 1
    ) s on true
   where d.status = 'approved'
     and (not coalesce(p_only_available, true) or d.is_available)
     and (p_min_rating is null or d.rating_avg >= p_min_rating)
     and (p_min_seats is null or v.seats >= p_min_seats)
     and (p_vehicle_type is null or v.vehicle_type = p_vehicle_type)
   order by
     case when p_sort = 'price_asc'  then s.price end asc,
     case when p_sort = 'price_desc' then s.price end desc,
     case when p_sort = 'trips'      then d.completed_count end desc,
     case when coalesce(p_sort, 'rating') not in ('price_asc', 'price_desc', 'trips') then d.rating_avg end desc,
     d.rating_count desc, d.id
   limit greatest(1, least(coalesce(p_limit, 50), 100))
  offset greatest(0, coalesce(p_offset, 0));
$$;
