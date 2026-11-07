-- =============================================================================
-- SAIQI — 01 : extensions et types énumérés
-- =============================================================================

create extension if not exists pgcrypto with schema extensions;

-- pg_cron : disponible sur Supabase (local et distant). Garde conditionnelle pour
-- pouvoir valider les migrations sur un PostgreSQL nu (voir scripts/db-check).
do $$
begin
  if exists (select 1 from pg_available_extensions where name = 'pg_cron') then
    create extension if not exists pg_cron with schema pg_catalog;
  end if;
end $$;

-- ---------------------------------------------------------------------------
-- Enums (idempotents)
-- ---------------------------------------------------------------------------
do $$
begin
  if not exists (select 1 from pg_type where typname = 'user_role') then
    create type public.user_role as enum ('client', 'driver', 'admin');
  end if;
  if not exists (select 1 from pg_type where typname = 'admin_role') then
    create type public.admin_role as enum ('super_admin', 'validator', 'support');
  end if;
  if not exists (select 1 from pg_type where typname = 'account_status') then
    create type public.account_status as enum ('active', 'suspended', 'blocked');
  end if;
  if not exists (select 1 from pg_type where typname = 'driver_status') then
    create type public.driver_status as enum ('draft', 'pending', 'approved', 'rejected', 'suspended');
  end if;
  if not exists (select 1 from pg_type where typname = 'document_type') then
    create type public.document_type as enum ('id_card', 'driving_license', 'vehicle_registration', 'insurance', 'photo');
  end if;
  if not exists (select 1 from pg_type where typname = 'document_status') then
    create type public.document_status as enum ('pending', 'approved', 'rejected');
  end if;
  if not exists (select 1 from pg_type where typname = 'booking_status') then
    create type public.booking_status as enum
      ('pending', 'accepted', 'en_route', 'in_progress', 'completed', 'cancelled', 'rejected', 'expired');
  end if;
  if not exists (select 1 from pg_type where typname = 'booking_channel') then
    create type public.booking_channel as enum ('app', 'phone', 'whatsapp', 'other');
  end if;
  if not exists (select 1 from pg_type where typname = 'created_by_type') then
    create type public.created_by_type as enum ('client', 'admin');
  end if;
  if not exists (select 1 from pg_type where typname = 'wallet_tx_type') then
    create type public.wallet_tx_type as enum ('topup', 'commission', 'refund', 'adjustment');
  end if;
  if not exists (select 1 from pg_type where typname = 'topup_status') then
    create type public.topup_status as enum ('pending', 'approved', 'rejected');
  end if;
  if not exists (select 1 from pg_type where typname = 'commission_status') then
    create type public.commission_status as enum ('deducted', 'refunded');
  end if;
  if not exists (select 1 from pg_type where typname = 'complaint_status') then
    create type public.complaint_status as enum ('open', 'in_review', 'resolved', 'dismissed');
  end if;
  if not exists (select 1 from pg_type where typname = 'price_unit') then
    create type public.price_unit as enum ('per_trip', 'per_hour', 'per_day');
  end if;
  if not exists (select 1 from pg_type where typname = 'offer_status') then
    create type public.offer_status as enum ('pending', 'accepted', 'declined', 'expired');
  end if;
end $$;
