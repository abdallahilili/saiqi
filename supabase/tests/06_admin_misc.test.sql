-- pgTAP : réaffectation (restitution de commission), avertissement, annonce, lien client existant
begin;
create extension if not exists pgtap with schema extensions;
select plan(13);

create function pg_temp.mk_user(p_id uuid, p_phone text, p_role text) returns void language sql as $$
  insert into auth.users (instance_id, id, aud, role, email, raw_user_meta_data)
  values ('00000000-0000-0000-0000-000000000000', p_id, 'authenticated', 'authenticated',
          regexp_replace(p_phone, '[^0-9]', '', 'g') || '@saiqi.app',
          jsonb_build_object('phone', p_phone, 'role', p_role, 'full_name', 'Test ' || p_phone));
$$;

select pg_temp.mk_user('77777777-7777-4777-8777-777777777771', '+22236777771', 'client');
select pg_temp.mk_user('77777777-7777-4777-8777-777777777772', '+22222777772', 'driver');
select pg_temp.mk_user('77777777-7777-4777-8777-777777777773', '+22222777773', 'driver');
select pg_temp.mk_user('77777777-7777-4777-8777-777777777774', '+22220777774', 'client');
update public.profiles set role = 'admin', admin_role = 'super_admin' where id = '77777777-7777-4777-8777-777777777774';

update public.drivers set status = 'approved', is_available = true,
       city_id = (select id from public.cities where name_fr = 'Nouakchott')
 where profile_id in ('77777777-7777-4777-8777-777777777772', '77777777-7777-4777-8777-777777777773');

create temp table t_ctx as
select d.profile_id, d.id as driver_id, w.id as wallet_id
  from public.drivers d join public.wallets w on w.driver_id = d.id
 where d.profile_id in ('77777777-7777-4777-8777-777777777772', '77777777-7777-4777-8777-777777777773');
grant select on t_ctx to authenticated;
update public.wallets set balance = 500 where id in (select wallet_id from t_ctx);

-- l'admin crée une demande pour un numéro qui correspond à un client existant -> client_id lié
select set_config('request.jwt.claims', '{"sub":"77777777-7777-4777-8777-777777777774","role":"authenticated"}', true);
set local role authenticated;
create temp table t_b as
select (public.admin_create_booking('Client Existant', '+222 36 77 77 71',
         (select id from public.service_types where name_fr = 'Taxi'), (select id from public.cities where name_fr = 'Nouakchott'),
         'A', 'B', now() + interval '1 hour', 1, null, 1000, 'whatsapp',
         array[(select driver_id from t_ctx where profile_id = '77777777-7777-4777-8777-777777777772')])).id as id;
reset role;
grant select on t_b to authenticated;

select is((select client_id from public.bookings where id = (select id from t_b)), '77777777-7777-4777-8777-777777777771'::uuid,
  'le numéro d''un client inscrit est relié à son compte');
select is((select driver_id from public.bookings where id = (select id from t_b)),
  (select driver_id from t_ctx where profile_id = '77777777-7777-4777-8777-777777777772'), 'un seul chauffeur visé : driver_id renseigné');

-- le chauffeur 1 accepte (commission 100)
select set_config('request.jwt.claims', '{"sub":"77777777-7777-4777-8777-777777777772","role":"authenticated"}', true);
set local role authenticated;
select lives_ok($$ select public.accept_booking((select id from t_b)) $$, 'chauffeur 1 accepte');
reset role;
select is((select balance from public.wallets where id = (select wallet_id from t_ctx where profile_id = '77777777-7777-4777-8777-777777777772')), 400, 'commission 100 déduite');

-- l'admin réaffecte au chauffeur 2 : commission du chauffeur 1 restituée
select set_config('request.jwt.claims', '{"sub":"77777777-7777-4777-8777-777777777774","role":"authenticated"}', true);
set local role authenticated;
select lives_ok($$ select public.admin_reassign_booking((select id from t_b),
   array[(select driver_id from t_ctx where profile_id = '77777777-7777-4777-8777-777777777773')]) $$, 'réaffectation au chauffeur 2');
reset role;

select is((select balance from public.wallets where id = (select wallet_id from t_ctx where profile_id = '77777777-7777-4777-8777-777777777772')), 500,
  'réaffectation : commission du chauffeur 1 restituée');
select is((select status::text from public.bookings where id = (select id from t_b)), 'pending', 'la réservation repart en attente');
select is((select driver_id from public.bookings where id = (select id from t_b)),
  (select driver_id from t_ctx where profile_id = '77777777-7777-4777-8777-777777777773'), 'nouveau chauffeur visé');
select is((select balance from public.wallets where id = (select wallet_id from t_ctx where profile_id = '77777777-7777-4777-8777-777777777773')), 500,
  'le chauffeur 2 n''est débité qu''à son acceptation');

-- avertissement et annonce
select set_config('request.jwt.claims', '{"sub":"77777777-7777-4777-8777-777777777774","role":"authenticated"}', true);
set local role authenticated;
select lives_ok($$ select public.admin_warn_user('77777777-7777-4777-8777-777777777771', 'Merci de respecter les horaires.') $$, 'avertissement envoyé');
select lives_ok($$ select public.admin_send_announcement('clients', 'Maintenance', 'Service indisponible ce soir.') $$, 'annonce envoyée');
reset role;
select ok(exists (select 1 from public.notifications where user_id = '77777777-7777-4777-8777-777777777771' and body = 'Merci de respecter les horaires.'),
  'le client a reçu l''avertissement');

-- un client ne peut pas avertir
select set_config('request.jwt.claims', '{"sub":"77777777-7777-4777-8777-777777777771","role":"authenticated"}', true);
set local role authenticated;
select throws_ok($$ select public.admin_warn_user('77777777-7777-4777-8777-777777777772', 'x y z') $$, 'P0001', 'admin_forbidden', 'un client ne peut pas avertir');
reset role;

select * from finish();
rollback;
