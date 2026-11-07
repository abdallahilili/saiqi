-- =============================================================================
-- SAIQI — seed LOCAL uniquement (supabase db reset)
-- Tous les comptes de seed ont le mot de passe  Test1234!  — NE JAMAIS charger en production.
-- Le premier super admin du projet distant se crée avec scripts/create-super-admin.mjs.
--
--   Admins   : +22220000001 super_admin | +22220000002 validator | +22220000003 support
--   Clients  : +22236000001 Mohamed     | +22236000002 Fatimetou
--   Chauffeurs approuvés : +22222000001 … +22222000005  (le n°5 a un solde de 0)
-- Les réservations sont créées en appelant les VRAIES fonctions métier (create_booking,
-- accept_booking, …) : le seed vérifie donc aussi la cohérence du wallet et des commissions.
-- =============================================================================

-- Données de référence (déjà créées par les migrations ; ré-assertées ici, idempotent)
insert into public.app_settings (key, value) values
  ('default_commission_rate', '0.10'::jsonb), ('response_timeout_minutes', '10'::jsonb),
  ('low_balance_threshold', '100'::jsonb)
on conflict (key) do nothing;

-- ---------------------------------------------------------------------------
-- Helpers temporaires (supprimés à la fin de la session)
-- ---------------------------------------------------------------------------
create or replace function pg_temp.seed_user(
  p_id uuid, p_phone text, p_role text, p_name text, p_lang text default 'ar')
returns void language plpgsql as $$
declare
  v_digits text := regexp_replace(p_phone, '[^0-9]', '', 'g');
  v_email  text := v_digits || '@saiqi.app';
begin
  if exists (select 1 from auth.users where id = p_id) then
    return;
  end if;
  insert into auth.users (
    instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at,
    confirmation_token, recovery_token, email_change_token_new, email_change,
    email_change_token_current, phone_change, phone_change_token, reauthentication_token)
  values (
    '00000000-0000-0000-0000-000000000000', p_id, 'authenticated', 'authenticated', v_email,
    extensions.crypt('Test1234!', extensions.gen_salt('bf')), now(),
    '{"provider":"email","providers":["email"]}'::jsonb,
    jsonb_build_object('phone', p_phone, 'role', p_role, 'full_name', p_name, 'language', p_lang),
    now(), now(), '', '', '', '', '', '', '', '');
  insert into auth.identities (id, provider_id, user_id, identity_data, provider, last_sign_in_at, created_at, updated_at)
  values (gen_random_uuid(), p_id::text, p_id,
          jsonb_build_object('sub', p_id::text, 'email', v_email, 'email_verified', true, 'phone_verified', false),
          'email', now(), now(), now());
end $$;

-- Se faire passer pour un utilisateur (auth.uid()) le temps de la session de seed
create or replace function pg_temp.act_as(p_id uuid) returns void language sql as $$
  select set_config('request.jwt.claims', json_build_object('sub', p_id, 'role', 'authenticated')::text, false);
$$;

create or replace function pg_temp.city(p_fr text) returns uuid language sql as $$
  select id from public.cities where name_fr = p_fr;
$$;
create or replace function pg_temp.svc(p_fr text) returns uuid language sql as $$
  select id from public.service_types where name_fr = p_fr;
$$;

-- Recharge validée directement (écriture serveur) : topup + transaction cohérentes
create or replace function pg_temp.seed_topup(p_driver uuid, p_amount int, p_admin uuid, p_method text default 'bankily')
returns void language plpgsql as $$
declare
  v_wallet public.wallets;
  v_req    uuid;
begin
  insert into public.topup_requests (driver_id, amount, method, reference, status, reviewed_by, reviewed_at, review_note)
  values (p_driver, p_amount, p_method, 'SEED-' || substr(gen_random_uuid()::text, 1, 6), 'approved', p_admin, now(), 'seed')
  returning id into v_req;
  update public.wallets set balance = balance + p_amount where driver_id = p_driver returning * into v_wallet;
  insert into public.wallet_transactions (wallet_id, type, amount, balance_after, topup_request_id, note, created_by)
  values (v_wallet.id, 'topup', p_amount, v_wallet.balance, v_req, 'seed', p_admin);
end $$;

-- ---------------------------------------------------------------------------
-- Comptes
-- ---------------------------------------------------------------------------
select pg_temp.seed_user('a0000000-0000-4000-8000-000000000001', '+22220000001', 'client', 'Admin SAIQI');
select pg_temp.seed_user('a0000000-0000-4000-8000-000000000002', '+22220000002', 'client', 'Validateur SAIQI');
select pg_temp.seed_user('a0000000-0000-4000-8000-000000000003', '+22220000003', 'client', 'Support SAIQI');
-- (le trigger d'inscription refuse « admin » : on promeut ensuite en écriture serveur, comme le fait le script de création de super admin)
update public.profiles set role = 'admin', admin_role = 'super_admin' where phone = '+22220000001';
update public.profiles set role = 'admin', admin_role = 'validator'   where phone = '+22220000002';
update public.profiles set role = 'admin', admin_role = 'support'     where phone = '+22220000003';

select pg_temp.seed_user('c0000000-0000-4000-8000-000000000001', '+22236000001', 'client', 'Mohamed Ould Ahmed');
select pg_temp.seed_user('c0000000-0000-4000-8000-000000000002', '+22236000002', 'client', 'Fatimetou Mint Sidi', 'fr');

select pg_temp.seed_user('d0000000-0000-4000-8000-000000000001', '+22222000001', 'driver', 'Sidi Ould Mohamed');
select pg_temp.seed_user('d0000000-0000-4000-8000-000000000002', '+22222000002', 'driver', 'Ahmed Salem Ould Baba');
select pg_temp.seed_user('d0000000-0000-4000-8000-000000000003', '+22222000003', 'driver', 'Cheikh Ould Brahim', 'fr');
select pg_temp.seed_user('d0000000-0000-4000-8000-000000000004', '+22222000004', 'driver', 'Moustapha Ould Dah');
select pg_temp.seed_user('d0000000-0000-4000-8000-000000000005', '+22222000005', 'driver', 'Oumar Diallo', 'fr');

-- ---------------------------------------------------------------------------
-- Chauffeurs : dossier approuvé, véhicule, services, disponibilités, wallet
-- ---------------------------------------------------------------------------
update public.drivers d set
  status = 'approved', is_available = true,
  city_id = x.city_id, bio = x.bio, years_experience = x.years
from (values
  ('d0000000-0000-4000-8000-000000000001'::uuid, pg_temp.city('Nouakchott'), 'Chauffeur professionnel, ponctuel et courtois. Je connais toute la ville.', 8),
  ('d0000000-0000-4000-8000-000000000002'::uuid, pg_temp.city('Nouakchott'), 'Spécialiste des trajets interurbains et du désert, véhicule 4×4 très bien entretenu.', 12),
  ('d0000000-0000-4000-8000-000000000003'::uuid, pg_temp.city('Nouadhibou'), 'Taxi à Nouadhibou depuis 5 ans, disponible jour et nuit.', 5),
  ('d0000000-0000-4000-8000-000000000004'::uuid, pg_temp.city('Kiffa'), 'Transport entre Kiffa, Atar et Nouakchott en toute sécurité.', 10),
  ('d0000000-0000-4000-8000-000000000005'::uuid, pg_temp.city('Rosso'), 'Minibus pour mariages, événements et transport du personnel.', 7)
) as x(profile_id, city_id, bio, years)
where d.profile_id = x.profile_id;

insert into public.vehicles (driver_id, vehicle_type, brand, model, year, color, seats, plate)
select d.id, v.vtype, v.brand, v.model, v.year, v.color, v.seats, v.plate
from public.drivers d
join (values
  ('d0000000-0000-4000-8000-000000000001'::uuid, 'sedan',   'Toyota',  'Corolla',    2018, 'Blanc',  4,  '1204 AB 00'),
  ('d0000000-0000-4000-8000-000000000002'::uuid, '4x4',     'Toyota',  'Land Cruiser', 2016, 'Gris', 7,  '5521 CD 00'),
  ('d0000000-0000-4000-8000-000000000003'::uuid, 'sedan',   'Hyundai', 'Accent',     2017, 'Jaune',  4,  '7710 EF 01'),
  ('d0000000-0000-4000-8000-000000000004'::uuid, 'suv',     'Toyota',  'Prado',      2019, 'Noir',   7,  '3302 GH 04'),
  ('d0000000-0000-4000-8000-000000000005'::uuid, 'minibus', 'Toyota',  'Hiace',      2015, 'Blanc',  15, '9918 IJ 03')
) as v(profile_id, vtype, brand, model, year, color, seats, plate) on v.profile_id = d.profile_id;

insert into public.driver_services (driver_id, service_type_id, city_ids, price, price_unit)
select d.id, pg_temp.svc(s.svc), array(select pg_temp.city(c) from unnest(s.cities) c), s.price, s.unit::public.price_unit
from public.drivers d
join (values
  ('d0000000-0000-4000-8000-000000000001'::uuid, 'Taxi',                   array['Nouakchott'], 150,   'per_trip'),
  ('d0000000-0000-4000-8000-000000000001'::uuid, 'Voiture privée',         array['Nouakchott'], 400,   'per_trip'),
  ('d0000000-0000-4000-8000-000000000001'::uuid, 'Chauffeur d''affaires',  array['Nouakchott'], 1500,  'per_day'),
  ('d0000000-0000-4000-8000-000000000002'::uuid, '4×4',                    array['Nouakchott','Atar'], 3000, 'per_day'),
  ('d0000000-0000-4000-8000-000000000002'::uuid, 'Interurbain',            array['Nouakchott','Rosso','Atar'], 5000, 'per_trip'),
  ('d0000000-0000-4000-8000-000000000003'::uuid, 'Taxi',                   array['Nouadhibou'], 120,   'per_trip'),
  ('d0000000-0000-4000-8000-000000000003'::uuid, 'Voiture privée',         array['Nouadhibou'], 350,   'per_trip'),
  ('d0000000-0000-4000-8000-000000000004'::uuid, '4×4',                    array['Kiffa','Atar'], 3500, 'per_day'),
  ('d0000000-0000-4000-8000-000000000004'::uuid, 'Interurbain',            array['Kiffa','Nouakchott'], 6000, 'per_trip'),
  ('d0000000-0000-4000-8000-000000000005'::uuid, 'Mariages / Événements',  array['Rosso','Nouakchott'], 2500, 'per_trip'),
  ('d0000000-0000-4000-8000-000000000005'::uuid, 'Transport du personnel', array['Rosso','Nouakchott'], 15000, 'per_day')
) as s(profile_id, svc, cities, price, unit) on s.profile_id = d.profile_id;

-- Disponibilités : lundi–samedi 07:00–22:00 pour tous
insert into public.driver_availability (driver_id, weekday, start_time, end_time)
select d.id, w, '07:00', '22:00' from public.drivers d, generate_series(1, 6) w where d.status = 'approved';

-- Portefeuilles (créés par le trigger d'approbation) : soldes de départ
select pg_temp.seed_topup((select id from public.drivers where profile_id = 'd0000000-0000-4000-8000-000000000001'), 500,  'a0000000-0000-4000-8000-000000000001');
select pg_temp.seed_topup((select id from public.drivers where profile_id = 'd0000000-0000-4000-8000-000000000002'), 1200, 'a0000000-0000-4000-8000-000000000001', 'masrvi');
select pg_temp.seed_topup((select id from public.drivers where profile_id = 'd0000000-0000-4000-8000-000000000003'), 300,  'a0000000-0000-4000-8000-000000000001');
select pg_temp.seed_topup((select id from public.drivers where profile_id = 'd0000000-0000-4000-8000-000000000004'), 800,  'a0000000-0000-4000-8000-000000000001', 'sedad');
-- chauffeur n°5 : solde 0 volontairement (démonstration du blocage d'acceptation)

-- Une recharge en attente (à valider côté admin)
insert into public.topup_requests (driver_id, amount, method, reference)
select id, 300, 'bankily', 'BK-98123' from public.drivers where profile_id = 'd0000000-0000-4000-8000-000000000005';

-- ---------------------------------------------------------------------------
-- Réservations : créées via les vraies fonctions, dans tous les statuts
-- ---------------------------------------------------------------------------
do $seed$
declare
  c1 uuid := 'c0000000-0000-4000-8000-000000000001';
  c2 uuid := 'c0000000-0000-4000-8000-000000000002';
  a1 uuid := 'a0000000-0000-4000-8000-000000000001';
  a3 uuid := 'a0000000-0000-4000-8000-000000000003';
  u1 uuid := 'd0000000-0000-4000-8000-000000000001';
  u2 uuid := 'd0000000-0000-4000-8000-000000000002';
  u3 uuid := 'd0000000-0000-4000-8000-000000000003';
  u4 uuid := 'd0000000-0000-4000-8000-000000000004';
  d1 uuid; d2 uuid; d3 uuid; d4 uuid; d5 uuid;
  nkc uuid := pg_temp.city('Nouakchott');
  ndb uuid := pg_temp.city('Nouadhibou');
  kif uuid := pg_temp.city('Kiffa');
  b public.bookings;
begin
  select id into d1 from public.drivers where profile_id = u1;
  select id into d2 from public.drivers where profile_id = u2;
  select id into d3 from public.drivers where profile_id = u3;
  select id into d4 from public.drivers where profile_id = u4;
  select id into d5 from public.drivers where profile_id = 'd0000000-0000-4000-8000-000000000005';

  -- 1) terminée + avis 5★ (Taxi, 150 MRU → commission 15)
  perform pg_temp.act_as(c1);
  b := public.create_booking(d1, pg_temp.svc('Taxi'), nkc, 'Aéroport Oumtounsy', 'Tevragh Zeina', now() + interval '2 hours', 2, 'Deux valises');
  perform pg_temp.act_as(u1); perform public.accept_booking(b.id);
  perform public.update_booking_status(b.id, 'en_route'); perform public.update_booking_status(b.id, 'in_progress');
  perform public.update_booking_status(b.id, 'completed');
  update public.bookings set scheduled_at = now() - interval '3 days' where id = b.id;
  perform pg_temp.act_as(c1); perform public.submit_review(b.id, 5, 'Chauffeur ponctuel et très aimable, je recommande.');

  -- 2) terminée + avis 4★ (Voiture privée 400 → commission 40)
  perform pg_temp.act_as(c2);
  b := public.create_booking(d1, pg_temp.svc('Voiture privée'), nkc, 'Ksar', 'Marché Capitale', now() + interval '1 hour', 3, null);
  perform pg_temp.act_as(u1); perform public.accept_booking(b.id);
  perform public.update_booking_status(b.id, 'en_route'); perform public.update_booking_status(b.id, 'in_progress');
  perform public.update_booking_status(b.id, 'completed');
  update public.bookings set scheduled_at = now() - interval '1 day' where id = b.id;
  perform pg_temp.act_as(c2); perform public.submit_review(b.id, 4, 'Très bon trajet, voiture propre.');

  -- 3) annulée par le client après acceptation → commission restituée
  perform pg_temp.act_as(c1);
  b := public.create_booking(d2, pg_temp.svc('4×4'), nkc, 'Nouakchott centre', 'Atar', now() + interval '2 days', 4, 'Sortie week-end');
  perform pg_temp.act_as(u2); perform public.accept_booking(b.id);
  perform pg_temp.act_as(c1); perform public.cancel_booking(b.id, 'Changement de programme');

  -- 4) en cours (Interurbain 5000 → commission 500)
  perform pg_temp.act_as(c2);
  b := public.create_booking(d2, pg_temp.svc('Interurbain'), nkc, 'Nouakchott', 'Rosso', now() + interval '30 minutes', 3, null);
  perform pg_temp.act_as(u2); perform public.accept_booking(b.id);
  perform public.update_booking_status(b.id, 'en_route'); perform public.update_booking_status(b.id, 'in_progress');

  -- 5) en route (Nouadhibou)
  perform pg_temp.act_as(c1);
  b := public.create_booking(d3, pg_temp.svc('Taxi'), ndb, 'Gare routière', 'Cansado', now() + interval '20 minutes', 1, null);
  perform pg_temp.act_as(u3); perform public.accept_booking(b.id); perform public.update_booking_status(b.id, 'en_route');

  -- 6) acceptée (course à venir)
  perform pg_temp.act_as(c2);
  b := public.create_booking(d1, pg_temp.svc('Chauffeur d''affaires'), nkc, 'Hôtel Mauricenter', 'Ministère des Finances', now() + interval '1 day', 1, 'Costume, discrétion');
  perform pg_temp.act_as(u1); perform public.accept_booking(b.id);

  -- 7) en attente (pas encore expirée)
  perform pg_temp.act_as(c1);
  b := public.create_booking(d4, pg_temp.svc('Interurbain'), kif, 'Kiffa centre', 'Nouakchott', now() + interval '1 day', 2, null);

  -- 8) refusée par le chauffeur
  perform pg_temp.act_as(c2);
  b := public.create_booking(d3, pg_temp.svc('Voiture privée'), ndb, 'Port de pêche', 'Nouadhibou ville', now() + interval '3 hours', 2, null);
  perform pg_temp.act_as(u3); perform public.reject_booking(b.id);

  -- 9) expirée (aucune réponse dans le délai)
  perform pg_temp.act_as(c1);
  b := public.create_booking(d1, pg_temp.svc('Taxi'), nkc, 'Carrefour Madrid', 'Arafat', now() + interval '4 hours', 1, null);
  update public.bookings set expires_at = now() - interval '5 minutes' where id = b.id;
  perform public.expire_pending_bookings();

  -- 10) demande créée par l'admin (support), client hors application, envoyée à 2 chauffeurs
  perform pg_temp.act_as(a3);
  b := public.admin_create_booking('Abdallahi Ould Sidi', '+22237000009', pg_temp.svc('Taxi'), nkc,
         'Clinique Nouakchott', 'Aéroport Oumtounsy', now() + interval '3 hours', 2, 'Client âgé, aider avec les bagages',
         200, 'whatsapp', array[d1, d2]);
  -- 11) demande admin envoyée à 2 chauffeurs : d4 accepte en premier, l'offre de d2 expire
  b := public.admin_create_booking('Société Sahara Mining', '+22245000010', pg_temp.svc('4×4'), kif,
         'Kiffa', 'Atar', now() + interval '2 days', 4, 'Mission de 2 jours', 3500, 'phone', array[d4, d2]);
  perform pg_temp.act_as(u4); perform public.accept_booking(b.id);

  -- Plainte et signalement
  perform pg_temp.act_as(c2);
  perform public.file_complaint((select id from public.bookings where client_id = c2 and status = 'completed' order by created_at limit 1),
    'Le chauffeur est arrivé avec 15 minutes de retard sans prévenir.');
end $seed$;
