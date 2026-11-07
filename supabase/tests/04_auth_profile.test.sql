-- pgTAP : inscription par numéro (profil créé par trigger), normalisation +222, rôles protégés
begin;
create extension if not exists pgtap with schema extensions;
select plan(18);

select is(public.normalize_phone('36123456'), '+22236123456', '8 chiffres -> +222');
select is(public.normalize_phone('+222 36 12 34 56'), '+22236123456', 'espaces et + ignorés');
select is(public.normalize_phone('0022236123456'), '+22236123456', 'préfixe 00222');
select is(public.normalize_phone('22236123456'), '+22236123456', 'préfixe 222');
select is(public.normalize_phone('22212345678'), '+22212345678', 'exemple du cahier des charges');
select is(public.normalize_phone('123'), null, 'numéro trop court -> NULL');
select is(public.normalize_phone('abc'), null, 'texte -> NULL');

create function pg_temp.mk_user(p_id uuid, p_email text, p_meta jsonb) returns void language sql as $$
  insert into auth.users (instance_id, id, aud, role, email, raw_user_meta_data)
  values ('00000000-0000-0000-0000-000000000000', p_id, 'authenticated', 'authenticated', p_email, p_meta);
$$;

select pg_temp.mk_user('55555555-5555-4555-8555-555555555551', '22236555551@saiqi.app',
  '{"phone":"+222 36 55 55 51","role":"client","full_name":"Client Test","language":"fr"}');
select is((select phone from public.profiles where id = '55555555-5555-4555-8555-555555555551'), '+22236555551', 'profil créé, numéro normalisé');
select is((select language from public.profiles where id = '55555555-5555-4555-8555-555555555551'), 'fr', 'langue enregistrée');

select pg_temp.mk_user('55555555-5555-4555-8555-555555555552', '22236555552@saiqi.app',
  '{"phone":"+22236555552","role":"admin","full_name":"Pirate"}');
select is((select role::text from public.profiles where id = '55555555-5555-4555-8555-555555555552'), 'client',
  'jamais admin à l''inscription (rôle admin demandé -> client)');
select is((select admin_role::text from public.profiles where id = '55555555-5555-4555-8555-555555555552'), null, 'aucun admin_role à l''inscription');

select pg_temp.mk_user('55555555-5555-4555-8555-555555555553', '22222555553@saiqi.app',
  '{"phone":"+22222555553","role":"driver","full_name":"Chauffeur Test"}');
select is((select status::text from public.drivers where profile_id = '55555555-5555-4555-8555-555555555553'), 'draft',
  'inscription chauffeur : dossier en brouillon créé');
select is((select count(*)::int from public.wallets w join public.drivers d on d.id = w.driver_id
            where d.profile_id = '55555555-5555-4555-8555-555555555553'), 0, 'pas de wallet avant l''approbation');

update public.drivers set is_available = true where profile_id = '55555555-5555-4555-8555-555555555553';
select is((select is_available from public.drivers where profile_id = '55555555-5555-4555-8555-555555555553'), false,
  'un chauffeur non approuvé ne peut pas être disponible');

update public.drivers set status = 'approved' where profile_id = '55555555-5555-4555-8555-555555555553';
select is((select balance from public.wallets w join public.drivers d on d.id = w.driver_id
            where d.profile_id = '55555555-5555-4555-8555-555555555553'), 0, 'wallet créé à l''approbation, solde 0');

select throws_ok($$ select pg_temp.mk_user('55555555-5555-4555-8555-555555555554', 'autre@saiqi.app', '{"phone":"+22236555551"}') $$,
  'P0001', 'phone_already_registered', 'numéro déjà utilisé -> refus');
select throws_ok($$ select pg_temp.mk_user('55555555-5555-4555-8555-555555555555', 'x@saiqi.app', '{"phone":"abc"}') $$,
  'P0001', 'invalid_phone', 'numéro invalide -> refus');
select throws_ok($$ update public.profiles set role = 'admin' where id = '55555555-5555-4555-8555-555555555551' $$,
  '23514', 'new row for relation "profiles" violates check constraint "profiles_admin_role_consistency"',
  'role=admin exige admin_role (contrainte)');

select * from finish();
rollback;
