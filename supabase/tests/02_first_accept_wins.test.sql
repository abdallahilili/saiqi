-- pgTAP : demande créée par l'admin envoyée à 2 chauffeurs — le premier qui accepte l'obtient
begin;
create extension if not exists pgtap with schema extensions;
select plan(13);

create function pg_temp.mk_user(p_id uuid, p_phone text, p_role text) returns void language sql as $$
  insert into auth.users (instance_id, id, aud, role, email, raw_user_meta_data)
  values ('00000000-0000-0000-0000-000000000000', p_id, 'authenticated', 'authenticated',
          regexp_replace(p_phone, '[^0-9]', '', 'g') || '@saiqi.app',
          jsonb_build_object('phone', p_phone, 'role', p_role, 'full_name', 'Test ' || p_phone));
$$;

select pg_temp.mk_user('33333333-3333-4333-8333-333333333331', '+22222333331', 'driver');
select pg_temp.mk_user('33333333-3333-4333-8333-333333333332', '+22222333332', 'driver');
select pg_temp.mk_user('33333333-3333-4333-8333-333333333339', '+22220333339', 'client');
update public.profiles set role = 'admin', admin_role = 'support' where id = '33333333-3333-4333-8333-333333333339';

update public.drivers set status = 'approved', is_available = true
 where profile_id in ('33333333-3333-4333-8333-333333333331', '33333333-3333-4333-8333-333333333332');

create temp table t_ctx as
select d.profile_id, d.id as driver_id, w.id as wallet_id
  from public.drivers d join public.wallets w on w.driver_id = d.id
 where d.profile_id in ('33333333-3333-4333-8333-333333333331', '33333333-3333-4333-8333-333333333332');
grant select on t_ctx to authenticated;
update public.wallets set balance = 500 where id in (select wallet_id from t_ctx);

-- l'admin (support) crée la demande pour un client sans compte, envoyée aux 2 chauffeurs
select set_config('request.jwt.claims', '{"sub":"33333333-3333-4333-8333-333333333339","role":"authenticated"}', true);
set local role authenticated;
create temp table t_b as
select (public.admin_create_booking(
         'Client Téléphone', '22 33 44 55',
         (select id from public.service_types where name_fr = 'Taxi'),
         (select id from public.cities where name_fr = 'Nouakchott'),
         'Sebkha', 'Aéroport', now() + interval '2 hours', 2, 'Appel reçu', 1000, 'phone',
         (select array_agg(driver_id) from t_ctx))).id as id;
reset role;
grant select on t_b to authenticated;

select is((select status::text from public.bookings where id = (select id from t_b)), 'pending', 'demande admin créée en attente');
select is((select client_phone from public.bookings where id = (select id from t_b)), '+22222334455',
  'numéro du client hors application normalisé en +222');
select is((select count(*)::int from public.booking_offers where booking_id = (select id from t_b)), 2, '2 offres envoyées');
select is((select client_id from public.bookings where id = (select id from t_b)), null, 'client sans compte : client_id nul');

-- le chauffeur 1 accepte en premier
select set_config('request.jwt.claims', '{"sub":"33333333-3333-4333-8333-333333333331","role":"authenticated"}', true);
set local role authenticated;
select lives_ok($$ select public.accept_booking((select id from t_b)) $$, 'le chauffeur 1 accepte le premier');
reset role;

-- le chauffeur 2 arrive trop tard
select set_config('request.jwt.claims', '{"sub":"33333333-3333-4333-8333-333333333332","role":"authenticated"}', true);
set local role authenticated;
select throws_ok($$ select public.accept_booking((select id from t_b)) $$,
  'P0001', 'booking_not_available', 'le chauffeur 2 ne peut plus accepter');
select throws_ok($$ select public.reject_booking((select id from t_b)) $$,
  'P0001', 'booking_not_available', 'le chauffeur 2 ne peut plus refuser non plus');
reset role;

select is((select driver_id from public.bookings where id = (select id from t_b)),
  (select driver_id from t_ctx where profile_id = '33333333-3333-4333-8333-333333333331'), 'la réservation appartient au chauffeur 1');
select is((select status::text from public.booking_offers where booking_id = (select id from t_b)
            and driver_id = (select driver_id from t_ctx where profile_id = '33333333-3333-4333-8333-333333333332')),
  'expired', 'l''offre du chauffeur 2 est expirée');
select is((select balance from public.wallets where id = (select wallet_id from t_ctx where profile_id = '33333333-3333-4333-8333-333333333331')),
  400, 'chauffeur 1 : commission de 100 (10 %) déduite');
select is((select balance from public.wallets where id = (select wallet_id from t_ctx where profile_id = '33333333-3333-4333-8333-333333333332')),
  500, 'chauffeur 2 : solde intact');
select is((select count(*)::int from public.commissions where booking_id = (select id from t_b)), 1, 'une seule commission pour la réservation');

-- expiration automatique d'une demande sans réponse
select set_config('request.jwt.claims', '{"sub":"33333333-3333-4333-8333-333333333339","role":"authenticated"}', true);
create temp table t_b2 as
select (public.admin_create_booking('Client B', '+22244556677',
         (select id from public.service_types where name_fr = 'Taxi'), (select id from public.cities where name_fr = 'Nouakchott'),
         'A', 'B', now() + interval '1 hour', 1, null, 500, 'other',
         array[(select driver_id from t_ctx where profile_id = '33333333-3333-4333-8333-333333333332')])).id as id;
update public.bookings set expires_at = now() - interval '1 minute' where id = (select id from t_b2);
select public.expire_pending_bookings();
select is((select status::text from public.bookings where id = (select id from t_b2)), 'expired', 'demande sans réponse expirée par le planificateur');

select * from finish();
rollback;
