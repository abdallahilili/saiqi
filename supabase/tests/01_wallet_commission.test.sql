-- pgTAP : portefeuille et commission
--   solde 300 -> 2 services (commission 150 chacun) -> 0 -> refus d'acceptation
--   restitution de la commission à l'annulation
-- Les tests sont indépendants du seed : toutes les requêtes filtrent sur les données créées ici.
begin;
create extension if not exists pgtap with schema extensions;
select plan(15);

-- ---- fixtures (rôle postgres) ---------------------------------------------
create function pg_temp.mk_user(p_id uuid, p_phone text, p_role text) returns void language sql as $$
  insert into auth.users (instance_id, id, aud, role, email, raw_user_meta_data)
  values ('00000000-0000-0000-0000-000000000000', p_id, 'authenticated', 'authenticated',
          regexp_replace(p_phone, '[^0-9]', '', 'g') || '@saiqi.app',
          jsonb_build_object('phone', p_phone, 'role', p_role, 'full_name', 'Test ' || p_phone));
$$;

select pg_temp.mk_user('11111111-1111-4111-8111-111111111111', '+22236111111', 'client');
select pg_temp.mk_user('22222222-2222-4222-8222-222222222222', '+22222111111', 'driver');

update public.drivers
   set status = 'approved', is_available = true, city_id = (select id from public.cities where name_fr = 'Nouakchott')
 where profile_id = '22222222-2222-4222-8222-222222222222';

create temp table t_ctx as
select d.id as driver_id, w.id as wallet_id
  from public.drivers d join public.wallets w on w.driver_id = d.id
 where d.profile_id = '22222222-2222-4222-8222-222222222222';
grant select on t_ctx to authenticated;

insert into public.driver_services (driver_id, service_type_id, city_ids, price, price_unit)
select (select driver_id from t_ctx), st.id, array[c.id], 1000, 'per_trip'
  from public.service_types st, public.cities c where st.name_fr = 'Taxi' and c.name_fr = 'Nouakchott';

-- taux service+ville = 15 % : 1000 MRU -> 150 MRU de commission
insert into public.commission_rates (rate, service_type_id, city_id)
select 0.15, st.id, c.id from public.service_types st, public.cities c where st.name_fr = 'Taxi' and c.name_fr = 'Nouakchott';

update public.wallets set balance = 300 where id = (select wallet_id from t_ctx);

-- 3 réservations créées par le client
select set_config('request.jwt.claims', '{"sub":"11111111-1111-4111-8111-111111111111","role":"authenticated"}', true);
create temp table t_b as
select (public.create_booking(
         (select driver_id from t_ctx),
         (select id from public.service_types where name_fr = 'Taxi'),
         (select id from public.cities where name_fr = 'Nouakchott'),
         'Départ ' || g, 'Arrivée ' || g, now() + interval '1 hour', 1, null)).id as id, g as n
  from generate_series(1, 3) g;
grant select on t_b to authenticated;

-- ---- scénario (rôle authenticated = comme depuis l'application) ------------
select set_config('request.jwt.claims', '{"sub":"22222222-2222-4222-8222-222222222222","role":"authenticated"}', true);
set local role authenticated;

select is(public.resolve_commission_rate(
            (select id from public.service_types where name_fr = 'Taxi'),
            (select id from public.cities where name_fr = 'Nouakchott')),
          0.15::numeric, 'taux service+ville prioritaire sur le défaut (10 %)');

select lives_ok($$ select public.accept_booking((select id from t_b where n = 1)) $$, 'service 1 accepté');
select is((select balance from public.wallets where id = (select wallet_id from t_ctx)), 150, 'solde 300 -> 150 après le service 1');

select lives_ok($$ select public.accept_booking((select id from t_b where n = 2)) $$, 'service 2 accepté');
select is((select balance from public.wallets where id = (select wallet_id from t_ctx)), 0, 'solde 150 -> 0 après le service 2');

select throws_ok($$ select public.accept_booking((select id from t_b where n = 3)) $$,
  'P0001', 'insufficient_balance', 'solde à 0 : acceptation refusée');

reset role;
select is((select status::text from public.bookings where id = (select id from t_b where n = 3)), 'pending',
  'la réservation refusée reste en attente (rien n''a été modifié)');
select is((select count(*)::int from public.commissions where driver_id = (select driver_id from t_ctx)), 2,
  'exactement 2 commissions enregistrées');
select is((select sum(amount)::int from public.commissions where driver_id = (select driver_id from t_ctx) and status = 'deducted'), 300,
  'commissions déduites = 300');
select is((select sum(amount)::int from public.wallet_transactions where wallet_id = (select wallet_id from t_ctx) and type = 'commission'), -300,
  'transactions de commission = -300 (cohérent avec le solde)');

-- ---- annulation : la commission est restituée ------------------------------
select set_config('request.jwt.claims', '{"sub":"11111111-1111-4111-8111-111111111111","role":"authenticated"}', true);
set local role authenticated;
select lives_ok($$ select public.cancel_booking((select id from t_b where n = 2), 'plus besoin') $$, 'le client annule avant en_route');
reset role;

select is((select balance from public.wallets where id = (select wallet_id from t_ctx)), 150, 'commission restituée : solde 0 -> 150');
select is((select status::text from public.commissions where booking_id = (select id from t_b where n = 2)),
  'refunded', 'commission marquée refunded');
select is((select amount from public.wallet_transactions
            where wallet_id = (select wallet_id from t_ctx) and type = 'refund'), 150, 'transaction refund de +150');
select is((select balance from public.wallets where id = (select wallet_id from t_ctx)),
  300 + (select sum(amount)::int from public.wallet_transactions where wallet_id = (select wallet_id from t_ctx)),
  'invariant : solde = solde initial + somme des transactions');

select * from finish();
rollback;
