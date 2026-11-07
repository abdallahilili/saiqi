-- pgTAP : parcours admin (validation, recharge, ajustement, rôles), course, annulation chauffeur, avis
begin;
create extension if not exists pgtap with schema extensions;
select plan(24);

create function pg_temp.mk_user(p_id uuid, p_phone text, p_role text) returns void language sql as $$
  insert into auth.users (instance_id, id, aud, role, email, raw_user_meta_data)
  values ('00000000-0000-0000-0000-000000000000', p_id, 'authenticated', 'authenticated',
          regexp_replace(p_phone, '[^0-9]', '', 'g') || '@saiqi.app',
          jsonb_build_object('phone', p_phone, 'role', p_role, 'full_name', 'Test ' || p_phone));
$$;

select pg_temp.mk_user('66666666-6666-4666-8666-666666666661', '+22236666661', 'client');
select pg_temp.mk_user('66666666-6666-4666-8666-666666666662', '+22222666662', 'driver');   -- approuvé
select pg_temp.mk_user('66666666-6666-4666-8666-666666666663', '+22222666663', 'driver');   -- en attente
select pg_temp.mk_user('66666666-6666-4666-8666-666666666664', '+22220666664', 'client');   -- futur super_admin
select pg_temp.mk_user('66666666-6666-4666-8666-666666666665', '+22220666665', 'client');   -- futur validator
select pg_temp.mk_user('66666666-6666-4666-8666-666666666666', '+22220666666', 'client');   -- futur support
update public.profiles set role = 'admin', admin_role = 'super_admin' where id = '66666666-6666-4666-8666-666666666664';
update public.profiles set role = 'admin', admin_role = 'validator'   where id = '66666666-6666-4666-8666-666666666665';
update public.profiles set role = 'admin', admin_role = 'support'     where id = '66666666-6666-4666-8666-666666666666';

update public.drivers set status = 'approved', is_available = true,
       city_id = (select id from public.cities where name_fr = 'Nouakchott')
 where profile_id = '66666666-6666-4666-8666-666666666662';
update public.drivers set status = 'pending' where profile_id = '66666666-6666-4666-8666-666666666663';

create temp table t_ctx as
select d.profile_id, d.id as driver_id from public.drivers d
 where d.profile_id in ('66666666-6666-4666-8666-666666666662', '66666666-6666-4666-8666-666666666663');
grant select on t_ctx to authenticated;
update public.wallets set balance = 300 where driver_id = (select driver_id from t_ctx where profile_id = '66666666-6666-4666-8666-666666666662');

insert into public.driver_services (driver_id, service_type_id, city_ids, price)
select driver_id, st.id, array[c.id], 1000
  from t_ctx, public.service_types st, public.cities c
 where st.name_fr = 'Taxi' and c.name_fr = 'Nouakchott' and profile_id = '66666666-6666-4666-8666-666666666662';

-- ================= ADMINS : contrôle par rôle ==============================
select set_config('request.jwt.claims', '{"sub":"66666666-6666-4666-8666-666666666665","role":"authenticated"}', true);  -- validator
set local role authenticated;
select throws_ok($$ select public.admin_adjust_wallet((select driver_id from t_ctx where profile_id = '66666666-6666-4666-8666-666666666662'), 50, 'bonus') $$,
  'P0001', 'admin_forbidden', 'validator : ajustement de wallet interdit');
select throws_ok($$ select public.admin_review_driver((select driver_id from t_ctx where profile_id = '66666666-6666-4666-8666-666666666663'), false, null) $$,
  'P0001', 'reason_required', 'refus d''un dossier : motif obligatoire');
select lives_ok($$ select public.admin_review_driver((select driver_id from t_ctx where profile_id = '66666666-6666-4666-8666-666666666663'), true, null) $$,
  'validator : approuve le dossier en attente');
reset role;
select is((select status::text from public.drivers where profile_id = '66666666-6666-4666-8666-666666666663'), 'approved', 'dossier approuvé');
select is((select count(*)::int from public.wallets w join public.drivers d on d.id = w.driver_id
            where d.profile_id = '66666666-6666-4666-8666-666666666663'), 1, 'wallet créé à l''approbation par l''admin');

select set_config('request.jwt.claims', '{"sub":"66666666-6666-4666-8666-666666666664","role":"authenticated"}', true);  -- super_admin
set local role authenticated;
select lives_ok($$ select public.admin_adjust_wallet((select driver_id from t_ctx where profile_id = '66666666-6666-4666-8666-666666666662'), 50, 'geste commercial') $$,
  'super_admin : ajustement +50');
select throws_ok($$ select public.admin_adjust_wallet((select driver_id from t_ctx where profile_id = '66666666-6666-4666-8666-666666666662'), -1000, 'erreur') $$,
  'P0001', 'insufficient_balance', 'ajustement négatif au-delà du solde refusé');
reset role;
select is((select balance from public.wallets w where w.driver_id = (select driver_id from t_ctx where profile_id = '66666666-6666-4666-8666-666666666662')),
  350, 'solde 300 + 50');

-- ================= RECHARGE ================================================
select set_config('request.jwt.claims', '{"sub":"66666666-6666-4666-8666-666666666662","role":"authenticated"}', true);  -- chauffeur
set local role authenticated;
select throws_ok($$ select public.request_topup(10, 'bankily', 'ref', null) $$, 'P0001', 'amount_too_low', 'recharge sous le minimum refusée');
create temp table t_topup as select (public.request_topup(300, 'bankily', 'BK-1', null)).id as id;
grant select on t_topup to authenticated;
reset role;
select is((select status::text from public.topup_requests where id = (select id from t_topup)), 'pending', 'recharge en attente');
select is((select balance from public.wallets w where w.driver_id = (select driver_id from t_ctx where profile_id = '66666666-6666-4666-8666-666666666662')),
  350, 'le solde ne bouge pas avant validation');

select set_config('request.jwt.claims', '{"sub":"66666666-6666-4666-8666-666666666666","role":"authenticated"}', true);  -- support
set local role authenticated;
select lives_ok($$ select public.admin_review_topup((select id from t_topup), true, 'reçu OK') $$, 'support : valide la recharge');
select throws_ok($$ select public.admin_review_topup((select id from t_topup), true, null) $$, 'P0001', 'topup_already_reviewed', 'double validation refusée');
reset role;
select is((select balance from public.wallets w where w.driver_id = (select driver_id from t_ctx where profile_id = '66666666-6666-4666-8666-666666666662')),
  650, 'solde 350 + 300 après validation');

-- ================= COURSE + ANNULATION CHAUFFEUR + AVIS ======================
select set_config('request.jwt.claims', '{"sub":"66666666-6666-4666-8666-666666666661","role":"authenticated"}', true);  -- client
create temp table t_b as
select (public.create_booking((select driver_id from t_ctx where profile_id = '66666666-6666-4666-8666-666666666662'),
         (select id from public.service_types where name_fr = 'Taxi'), (select id from public.cities where name_fr = 'Nouakchott'),
         'A', 'B', now() + interval '1 hour', 1, null)).id as id, g as n
  from generate_series(1, 2) g;
grant select on t_b to authenticated;

select set_config('request.jwt.claims', '{"sub":"66666666-6666-4666-8666-666666666662","role":"authenticated"}', true);  -- chauffeur
set local role authenticated;
select lives_ok($$ select public.accept_booking((select id from t_b where n = 1)) $$, 'acceptation (commission 100)');
select throws_ok($$ select public.update_booking_status((select id from t_b where n = 1), 'completed') $$,
  'P0001', 'invalid_transition', 'transition accepted -> completed interdite');
select lives_ok($$ select public.update_booking_status((select id from t_b where n = 1), 'en_route') $$, 'en_route');
select lives_ok($$ select public.update_booking_status((select id from t_b where n = 1), 'in_progress') $$, 'in_progress');
select lives_ok($$ select public.update_booking_status((select id from t_b where n = 1), 'completed') $$, 'completed');
reset role;

select set_config('request.jwt.claims', '{"sub":"66666666-6666-4666-8666-666666666661","role":"authenticated"}', true);
set local role authenticated;
select lives_ok($$ select public.submit_review((select id from t_b where n = 1), 4, 'Bien') $$, 'avis sur course terminée');
select throws_ok($$ select public.submit_review((select id from t_b where n = 1), 5, 'Encore') $$, 'P0001', 'already_reviewed', 'un seul avis par réservation');
select throws_ok($$ select public.submit_review((select id from t_b where n = 2), 5, 'x') $$, 'P0001', 'booking_not_completed', 'avis impossible si non terminée');
reset role;
select is((select rating_avg from public.drivers where id = (select driver_id from t_ctx where profile_id = '66666666-6666-4666-8666-666666666662')),
  4.00::numeric, 'note moyenne recalculée');
select throws_ok($$ update public.wallet_transactions set amount = 1 where false or true $$,
  'P0001', 'wallet_transactions_are_immutable', 'transactions du wallet immuables');

select * from finish();
rollback;
