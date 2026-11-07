-- =============================================================================
-- SAIQI — 08 : Storage (buckets + policies par dossier <user_id>/...)
--   driver-documents : privé (chauffeur propriétaire + admins)
--   topup-proofs     : privé (chauffeur propriétaire + admins)
--   vehicle-photos   : lecture publique, écriture par le propriétaire
--   avatars          : lecture publique, écriture par le propriétaire
-- =============================================================================

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values
  ('driver-documents', 'driver-documents', false, 5242880, array['image/jpeg', 'image/png', 'image/webp']),
  ('topup-proofs',     'topup-proofs',     false, 5242880, array['image/jpeg', 'image/png', 'image/webp']),
  ('vehicle-photos',   'vehicle-photos',   true,  5242880, array['image/jpeg', 'image/png', 'image/webp']),
  ('avatars',          'avatars',          true,  2097152, array['image/jpeg', 'image/png', 'image/webp'])
on conflict (id) do update
  set public = excluded.public,
      file_size_limit = excluded.file_size_limit,
      allowed_mime_types = excluded.allowed_mime_types;

do $$
declare
  r record;
begin
  for r in select policyname from pg_policies where schemaname = 'storage' and tablename = 'objects' and policyname like 'saiqi\_%' loop
    execute format('drop policy if exists %I on storage.objects', r.policyname);
  end loop;
end $$;

-- Buckets privés : le propriétaire gère son dossier ; les admins lisent tout.
create policy saiqi_driver_documents_owner on storage.objects
  for all to authenticated
  using (bucket_id = 'driver-documents' and (storage.foldername(name))[1] = auth.uid()::text)
  with check (bucket_id = 'driver-documents' and (storage.foldername(name))[1] = auth.uid()::text);
create policy saiqi_driver_documents_admin_read on storage.objects
  for select to authenticated
  using (bucket_id = 'driver-documents' and public.is_admin());

create policy saiqi_topup_proofs_owner on storage.objects
  for all to authenticated
  using (bucket_id = 'topup-proofs' and (storage.foldername(name))[1] = auth.uid()::text)
  with check (bucket_id = 'topup-proofs' and (storage.foldername(name))[1] = auth.uid()::text);
create policy saiqi_topup_proofs_admin_read on storage.objects
  for select to authenticated
  using (bucket_id = 'topup-proofs' and public.is_admin());

-- Buckets publics : lecture pour tous, écriture dans son propre dossier.
create policy saiqi_vehicle_photos_read on storage.objects
  for select to anon, authenticated using (bucket_id = 'vehicle-photos');
create policy saiqi_vehicle_photos_owner on storage.objects
  for all to authenticated
  using (bucket_id = 'vehicle-photos' and (storage.foldername(name))[1] = auth.uid()::text)
  with check (bucket_id = 'vehicle-photos' and (storage.foldername(name))[1] = auth.uid()::text);

create policy saiqi_avatars_read on storage.objects
  for select to anon, authenticated using (bucket_id = 'avatars');
create policy saiqi_avatars_owner on storage.objects
  for all to authenticated
  using (bucket_id = 'avatars' and (storage.foldername(name))[1] = auth.uid()::text)
  with check (bucket_id = 'avatars' and (storage.foldername(name))[1] = auth.uid()::text);
