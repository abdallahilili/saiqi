-- =============================================================================
-- SAIQI — 11 : privilèges (principe du moindre privilège) + contrôle final RLS
-- On repart de zéro pour anon/authenticated puis on accorde explicitement.
-- =============================================================================

grant usage on schema public to anon, authenticated, service_role;

revoke all on all tables    in schema public from anon, authenticated;
revoke all on all sequences in schema public from anon, authenticated;
revoke all on all functions in schema public from public, anon, authenticated;

-- Les futures fonctions ne sont pas exposées par défaut (il faut un GRANT explicite).
alter default privileges in schema public revoke execute on functions from public, anon, authenticated;

-- ---------------------------------------------------------------------------
-- Lecture (filtrée par RLS)
-- ---------------------------------------------------------------------------
grant select on
  public.profiles, public.cities, public.service_types, public.drivers, public.driver_documents,
  public.vehicles, public.driver_services, public.driver_availability, public.app_settings,
  public.commission_rates, public.wallets, public.wallet_transactions, public.commissions,
  public.topup_requests, public.bookings, public.booking_offers, public.reviews, public.favorites,
  public.complaints, public.notifications, public.announcements, public.audit_logs
to authenticated;

grant select on public.cities, public.service_types to anon;

grant select on public.public_drivers, public.public_driver_services, public.public_driver_reviews to anon, authenticated;
grant select on public.driver_incoming_requests to authenticated;

-- ---------------------------------------------------------------------------
-- Écritures directes autorisées (colonnes restreintes) — TOUT le reste passe par RPC
-- ---------------------------------------------------------------------------
grant update (full_name, avatar_url, language, fcm_token) on public.profiles to authenticated;
grant update (city_id, bio, years_experience) on public.drivers to authenticated;
grant insert, update, delete on public.vehicles, public.driver_services, public.driver_availability to authenticated;
grant insert, delete on public.favorites to authenticated;
grant update (read_at) on public.notifications to authenticated;
grant delete on public.notifications to authenticated;
-- Catalogues et taux : écriture réservée aux super_admin par la RLS
grant insert, update, delete on public.cities, public.service_types, public.commission_rates, public.app_settings to authenticated;

-- ---------------------------------------------------------------------------
-- Fonctions appelables par l'API (RPC)
-- ---------------------------------------------------------------------------
grant execute on function
  public.is_admin(), public.has_admin_role(public.admin_role[]), public.is_driver(), public.is_client(),
  public.current_driver_id()
to authenticated;
grant execute on function public.is_admin() to anon;

grant execute on function
  public.normalize_phone(text),
  public.resolve_commission_rate(uuid, uuid),
  public.compute_commission(int, numeric),
  public.create_booking(uuid, uuid, uuid, text, text, timestamptz, int, text),
  public.accept_booking(uuid),
  public.reject_booking(uuid),
  public.update_booking_status(uuid, public.booking_status),
  public.cancel_booking(uuid, text),
  public.get_booking_contact(uuid),
  public.get_booking_driver(uuid),
  public.request_topup(int, text, text, text),
  public.submit_review(uuid, int, text),
  public.file_complaint(uuid, text),
  public.save_driver_document(public.document_type, text),
  public.submit_driver_application(),
  public.set_driver_availability(boolean),
  public.driver_stats(),
  public.search_drivers(uuid, uuid, int, int, numeric, int, text, boolean, text, int, int),
  public.admin_review_driver(uuid, boolean, text),
  public.admin_review_document(uuid, boolean, text),
  public.admin_set_driver_status(uuid, public.driver_status, text),
  public.admin_set_account_status(uuid, public.account_status, text),
  public.admin_set_admin_role(uuid, public.admin_role),
  public.admin_review_topup(uuid, boolean, text),
  public.admin_adjust_wallet(uuid, int, text),
  public.admin_create_booking(text, text, uuid, uuid, text, text, timestamptz, int, text, int, public.booking_channel, uuid[]),
  public.admin_reassign_booking(uuid, uuid[]),
  public.admin_handle_complaint(uuid, public.complaint_status, text),
  public.admin_moderate_review(uuid, boolean),
  public.admin_send_announcement(text, text, text),
  public.admin_dashboard_stats()
to authenticated;

-- Le rôle service_role (Edge Functions, scripts serveur) garde tous les droits.
grant all on all tables    in schema public to service_role;
grant all on all sequences in schema public to service_role;
grant execute on all functions in schema public to service_role;

-- ---------------------------------------------------------------------------
-- Garde-fou : RLS obligatoire sur TOUTES les tables du schéma public
-- ---------------------------------------------------------------------------
do $$
declare
  r record;
begin
  for r in select tablename from pg_tables where schemaname = 'public' and not rowsecurity loop
    execute format('alter table public.%I enable row level security', r.tablename);
  end loop;
  if exists (select 1 from pg_tables where schemaname = 'public' and not rowsecurity) then
    raise exception 'RLS must be enabled on every public table';
  end if;
end $$;
