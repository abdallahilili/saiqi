-- =============================================================================
-- SAIQI — 09 : planification (pg_cron) et Realtime
-- =============================================================================

-- Expiration des demandes sans réponse : chaque minute (selon response_timeout_minutes).
do $$
begin
  if exists (select 1 from pg_extension where extname = 'pg_cron') then
    perform cron.schedule('saiqi-expire-pending-bookings', '* * * * *', 'select public.expire_pending_bookings()');
  end if;
end $$;

-- Realtime : suivi des réservations, offres, wallet, dossier chauffeur, notifications.
do $$
declare
  t text;
begin
  if exists (select 1 from pg_publication where pubname = 'supabase_realtime') then
    foreach t in array array[
      'bookings', 'booking_offers', 'wallets', 'wallet_transactions', 'drivers',
      'driver_documents', 'topup_requests', 'notifications', 'complaints'
    ] loop
      if not exists (
        select 1 from pg_publication_tables
         where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = t
      ) then
        execute format('alter publication supabase_realtime add table public.%I', t);
      end if;
    end loop;
  end if;
end $$;
