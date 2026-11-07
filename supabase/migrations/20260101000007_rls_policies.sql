-- =============================================================================
-- SAIQI — 07 : Row Level Security (policies explicites par table et par rôle)
-- Règle d'or : AUCUNE écriture client sur wallets / wallet_transactions / commissions /
-- bookings / booking_offers / topup_requests / driver_documents (RPC SECURITY DEFINER uniquement).
-- =============================================================================

do $$
declare
  r record;
begin
  -- on repart d'un état propre pour rester idempotent
  for r in select schemaname, tablename, policyname from pg_policies where schemaname = 'public' loop
    execute format('drop policy if exists %I on %I.%I', r.policyname, r.schemaname, r.tablename);
  end loop;
end $$;

-- profiles ------------------------------------------------------------------
create policy profiles_select_own on public.profiles
  for select to authenticated using (id = auth.uid());
create policy profiles_select_admin on public.profiles
  for select to authenticated using (public.is_admin());
create policy profiles_update_own on public.profiles
  for update to authenticated using (id = auth.uid()) with check (id = auth.uid());
-- (colonnes modifiables restreintes par GRANT : full_name, avatar_url, language, fcm_token)

-- catalogues ------------------------------------------------------------------
create policy cities_select on public.cities
  for select to anon, authenticated using (is_active or public.is_admin());
create policy cities_admin_write on public.cities
  for all to authenticated using (public.has_admin_role('super_admin')) with check (public.has_admin_role('super_admin'));

create policy service_types_select on public.service_types
  for select to anon, authenticated using (is_active or public.is_admin());
create policy service_types_admin_write on public.service_types
  for all to authenticated using (public.has_admin_role('super_admin')) with check (public.has_admin_role('super_admin'));

-- paramètres / commissions -----------------------------------------------------
create policy app_settings_select on public.app_settings
  for select to authenticated using (true);
create policy app_settings_admin_write on public.app_settings
  for all to authenticated using (public.has_admin_role('super_admin')) with check (public.has_admin_role('super_admin'));

create policy commission_rates_select on public.commission_rates
  for select to authenticated using (true);
create policy commission_rates_admin_write on public.commission_rates
  for all to authenticated using (public.has_admin_role('super_admin')) with check (public.has_admin_role('super_admin'));

-- chauffeurs --------------------------------------------------------------------
create policy drivers_select_own on public.drivers
  for select to authenticated using (profile_id = auth.uid());
create policy drivers_select_admin on public.drivers
  for select to authenticated using (public.is_admin());
create policy drivers_update_own on public.drivers
  for update to authenticated using (profile_id = auth.uid()) with check (profile_id = auth.uid());
-- (colonnes modifiables restreintes par GRANT : city_id, bio, years_experience)

create policy driver_documents_select_own on public.driver_documents
  for select to authenticated using (driver_id = public.current_driver_id());
create policy driver_documents_select_admin on public.driver_documents
  for select to authenticated using (public.is_admin());

create policy vehicles_select_own on public.vehicles
  for select to authenticated using (driver_id = public.current_driver_id());
create policy vehicles_select_admin on public.vehicles
  for select to authenticated using (public.is_admin());
create policy vehicles_write_own on public.vehicles
  for all to authenticated
  using (driver_id = public.current_driver_id()) with check (driver_id = public.current_driver_id());

create policy driver_services_select_own on public.driver_services
  for select to authenticated using (driver_id = public.current_driver_id());
create policy driver_services_select_admin on public.driver_services
  for select to authenticated using (public.is_admin());
create policy driver_services_write_own on public.driver_services
  for all to authenticated
  using (driver_id = public.current_driver_id()) with check (driver_id = public.current_driver_id());

create policy driver_availability_select_own on public.driver_availability
  for select to authenticated using (driver_id = public.current_driver_id());
create policy driver_availability_select_admin on public.driver_availability
  for select to authenticated using (public.is_admin());
create policy driver_availability_write_own on public.driver_availability
  for all to authenticated
  using (driver_id = public.current_driver_id()) with check (driver_id = public.current_driver_id());

-- finances : lecture seule ----------------------------------------------------
create policy wallets_select_own on public.wallets
  for select to authenticated using (driver_id = public.current_driver_id());
create policy wallets_select_admin on public.wallets
  for select to authenticated using (public.is_admin());

create policy wallet_transactions_select_own on public.wallet_transactions
  for select to authenticated
  using (wallet_id in (select w.id from public.wallets w where w.driver_id = public.current_driver_id()));
create policy wallet_transactions_select_admin on public.wallet_transactions
  for select to authenticated using (public.is_admin());

create policy commissions_select_own on public.commissions
  for select to authenticated using (driver_id = public.current_driver_id());
create policy commissions_select_admin on public.commissions
  for select to authenticated using (public.is_admin());

create policy topup_requests_select_own on public.topup_requests
  for select to authenticated using (driver_id = public.current_driver_id());
create policy topup_requests_select_admin on public.topup_requests
  for select to authenticated using (public.is_admin());

-- réservations -------------------------------------------------------------------
create policy bookings_select_client on public.bookings
  for select to authenticated using (client_id = auth.uid());
-- Le chauffeur ne lit la réservation (et donc le téléphone client) qu'APRÈS acceptation.
-- Avant : vue driver_incoming_requests (sans téléphone).
create policy bookings_select_driver on public.bookings
  for select to authenticated
  using (driver_id = public.current_driver_id() and accepted_at is not null);
create policy bookings_select_admin on public.bookings
  for select to authenticated using (public.is_admin());

create policy booking_offers_select_driver on public.booking_offers
  for select to authenticated using (driver_id = public.current_driver_id());
create policy booking_offers_select_admin on public.booking_offers
  for select to authenticated using (public.is_admin());

-- avis / favoris / plaintes / notifications ---------------------------------------
create policy reviews_select_client on public.reviews
  for select to authenticated using (client_id = auth.uid());
create policy reviews_select_driver on public.reviews
  for select to authenticated using (driver_id = public.current_driver_id() and not is_hidden);
create policy reviews_select_admin on public.reviews
  for select to authenticated using (public.is_admin());

create policy favorites_select_own on public.favorites
  for select to authenticated using (client_id = auth.uid());
create policy favorites_insert_own on public.favorites
  for insert to authenticated with check (client_id = auth.uid() and public.is_client());
create policy favorites_delete_own on public.favorites
  for delete to authenticated using (client_id = auth.uid());

create policy complaints_select_own on public.complaints
  for select to authenticated using (author_id = auth.uid());
create policy complaints_select_admin on public.complaints
  for select to authenticated using (public.is_admin());

create policy notifications_select_own on public.notifications
  for select to authenticated using (user_id = auth.uid());
create policy notifications_update_own on public.notifications
  for update to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy notifications_delete_own on public.notifications
  for delete to authenticated using (user_id = auth.uid());

create policy announcements_select_admin on public.announcements
  for select to authenticated using (public.has_admin_role('super_admin', 'support'));

create policy audit_logs_select_super_admin on public.audit_logs
  for select to authenticated using (public.has_admin_role('super_admin'));

-- notification_templates : RLS active, aucune policy => inaccessible aux clients de l'API.
