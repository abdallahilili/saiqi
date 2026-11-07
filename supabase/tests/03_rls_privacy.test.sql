-- pgTAP : RLS, écritures interdites côté client et visibilité des téléphones
begin;
create extension if not exists pgtap with schema extensions;
select plan(24);

create function pg_temp.mk_user(p_id uuid, p_phone text, p_role text) returns void language sql as $$
  insert into auth.users (instance_id, id, aud, role, email, raw_user_meta_data)
  values ('00000000-0000-0000-0000-000000000000', p_id, 'authenticated', 'authenticated',
          regexp_replace(p_phone, '[^0-9]', '', 'g') || '@saiqi.app',
          jsonb_build_object('phone', p_phone, 'role', p_role, 'full_name', 'Test ' || p_phone));
$$;

select pg_temp.mk_user('44444444-4444-4444-8444-444444444441', '+22236444441', 'client');  -- client A
select pg_temp.mk_user('44444444-4444-4444-8444-444444444442', '+22236444442', 'client');  -- client B
select pg_temp.mk_user('44444444-4444-4444-8444-444444444443', '+22222444443', 'driver');  -- chauffeur 1
select pg_temp.mk_user('44444444-4444-4444-8444-444444444444', '+22222444444', 'driver');  -- chauffeur 2

update public.drivers set status = 'approved', is_available = true,
       city_id = (select id from public.cities where name_fr = 'Nouakchott')
 where profile_id in ('44444444-4444-4444-8444-444444444443', '44444444-4444-4444-8444-444444444444');

create temp table t_ctx as
select d.profile_id, d.id as driver_id, w.id as wallet_id
  from public.drivers d join public.wallets w on w.driver_id = d.id
 where d.profile_id in ('44444444-4444-4444-8444-444444444443', '44444444-4444-4444-8444-444444444444');
grant select on t_ctx to authenticated;
update public.wallets set balance = 500 where id in (select wallet_id from t_ctx);

insert into public.driver_services (driver_id, service_type_id, city_ids, price)
select driver_id, st.id, array[c.id], 400
  from t_ctx, public.service_types st, public.cities c where st.name_fr = 'Taxi' and c.name_fr = 'Nouakchott';

select set_config('request.jwt.claims', '{"sub":"44444444-4444-4444-8444-444444444441","role":"authenticated"}', true);
create temp table t_b as
select (public.create_booking(
         (select driver_id from t_ctx where profile_id = '44444444-4444-4444-8444-444444444443'),
         (select id from public.service_types where name_fr = 'Taxi'),
         (select id from public.cities where name_fr = 'Nouakchott'),
         'A', 'B', now() + interval '1 hour', 1, null)).id as id;
grant select on t_b to authenticated;

-- ======================= CLIENT A =========================================
set local role authenticated;
select is((select count(*)::int from public.wallets), 0, 'client : aucun wallet lisible');
select is((select count(*)::int from public.wallet_transactions), 0, 'client : aucune transaction lisible');
select throws_ok($$ update public.wallets set balance = 99999 $$, '42501', 'permission denied for table wallets',
  'client : écriture sur wallets interdite');
select throws_ok($$ insert into public.wallet_transactions (wallet_id, type, amount, balance_after) select wallet_id, 'topup', 100, 100 from t_ctx limit 1 $$,
  '42501', 'permission denied for table wallet_transactions', 'client : insertion de transaction interdite');
select throws_ok($$ insert into public.bookings (client_name, client_phone, service_type_id, city_id, pickup_text, scheduled_at, price)
                    select 'x', '+22236000000', id, id, 'x', now(), 0 from public.cities limit 1 $$,
  '42501', 'permission denied for table bookings', 'client : insertion directe de réservation interdite');
select is((select count(*)::int from public.bookings where id = (select id from t_b)), 1, 'client A lit sa réservation');
select is((select count(*)::int from public.profiles where id <> '44444444-4444-4444-8444-444444444441'), 0,
  'client : aucun autre profil (donc aucun autre téléphone) lisible');
select throws_ok($$ update public.profiles set role = 'admin' where id = '44444444-4444-4444-8444-444444444441' $$,
  '42501', 'permission denied for table profiles', 'client : ne peut pas se promouvoir admin');
select lives_ok($$ update public.profiles set full_name = 'Nouveau Nom' where id = '44444444-4444-4444-8444-444444444441' $$,
  'client : peut modifier son nom');
select throws_ok($$ select public.admin_adjust_wallet((select driver_id from t_ctx limit 1), 1000, 'triche') $$,
  'P0001', 'admin_forbidden', 'client : fonctions admin refusées');
select throws_ok($$ select public.get_booking_contact((select id from t_b)) $$,
  'P0001', 'contact_not_available', 'téléphone du chauffeur masqué avant acceptation');
reset role;

-- ======================= CLIENT B ==========================================
select set_config('request.jwt.claims', '{"sub":"44444444-4444-4444-8444-444444444442","role":"authenticated"}', true);
set local role authenticated;
select is((select count(*)::int from public.bookings where id = (select id from t_b)), 0, 'client B ne lit pas la réservation de A');
reset role;

-- ======================= CHAUFFEUR 1 (destinataire) ========================
select set_config('request.jwt.claims', '{"sub":"44444444-4444-4444-8444-444444444443","role":"authenticated"}', true);
set local role authenticated;
select is((select count(*)::int from public.bookings where id = (select id from t_b)), 0,
  'chauffeur : réservation non lisible dans la table avant acceptation (téléphone client protégé)');
select is((select count(*)::int from public.driver_incoming_requests where booking_id = (select id from t_b)), 1,
  'chauffeur : demande visible via la vue sans téléphone');
select throws_ok($$ select public.get_booking_contact((select id from t_b)) $$,
  'P0001', 'contact_not_available', 'téléphone du client masqué avant acceptation');
select is((select count(*)::int from public.wallets where id = (select wallet_id from t_ctx where profile_id = '44444444-4444-4444-8444-444444444444')), 0,
  'chauffeur 1 ne lit pas le wallet du chauffeur 2');
select lives_ok($$ select public.accept_booking((select id from t_b)) $$, 'chauffeur 1 accepte');
select is((select phone from public.get_booking_contact((select id from t_b))), '+22236444441',
  'après acceptation : le chauffeur reçoit le téléphone du client');
select is((select count(*)::int from public.bookings where id = (select id from t_b)), 1, 'après acceptation : réservation lisible');
reset role;

select is((select count(*)::int from information_schema.columns
            where table_schema = 'public' and table_name in ('driver_incoming_requests', 'public_drivers', 'public_driver_services', 'public_driver_reviews')
              and column_name like '%phone%'), 0, 'aucune vue publique n''expose de colonne téléphone');

select set_config('request.jwt.claims', '{"sub":"44444444-4444-4444-8444-444444444441","role":"authenticated"}', true);
set local role authenticated;
select is((select phone from public.get_booking_contact((select id from t_b))), '+22222444443',
  'après acceptation : le client reçoit le téléphone du chauffeur');
reset role;

-- ======================= TIERS ============================================
select set_config('request.jwt.claims', '{"sub":"44444444-4444-4444-8444-444444444442","role":"authenticated"}', true);
set local role authenticated;
select throws_ok($$ select public.get_booking_contact((select id from t_b)) $$,
  'P0001', 'not_allowed', 'un tiers ne peut jamais obtenir de téléphone');
reset role;

-- ======================= ANONYME ===========================================
set local role anon;
select throws_ok($$ select * from public.profiles $$, '42501', 'permission denied for table profiles', 'anonyme : profiles inaccessible');
select ok((select count(*) from public.public_drivers) >= 2, 'anonyme : chauffeurs approuvés visibles via public_drivers');
reset role;

select * from finish();
rollback;
