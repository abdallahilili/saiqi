-- =============================================================================
-- SAIQI — 02 : tables du socle (profils, chauffeurs, catalogues, paramètres)
-- =============================================================================

-- ---------------------------------------------------------------------------
-- Helpers génériques
-- ---------------------------------------------------------------------------
create or replace function public.set_updated_at()
returns trigger
language plpgsql
set search_path = public
as $$
begin
  new.updated_at := now();
  return new;
end $$;

-- Normalise un numéro mauritanien vers +222XXXXXXXX (8 chiffres). Renvoie NULL si invalide.
create or replace function public.normalize_phone(p text)
returns text
language plpgsql
immutable
set search_path = public
as $$
declare
  d text;
begin
  if p is null then
    return null;
  end if;
  d := regexp_replace(p, '[^0-9]', '', 'g');
  if length(d) = 13 and d like '00222%' then
    d := substr(d, 6);
  elsif length(d) = 11 and d like '222%' then
    d := substr(d, 4);
  end if;
  if d ~ '^[0-9]{8}$' then
    return '+222' || d;
  end if;
  return null;
end $$;

-- ---------------------------------------------------------------------------
-- profiles (id = auth.users.id)
-- ---------------------------------------------------------------------------
create table if not exists public.profiles (
  id          uuid primary key references auth.users (id) on delete cascade,
  role        public.user_role not null default 'client',
  full_name   text,
  phone       text not null unique,
  avatar_url  text,
  language    text not null default 'ar' check (language in ('ar', 'fr')),
  status      public.account_status not null default 'active',
  admin_role  public.admin_role,
  fcm_token   text,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now(),
  constraint profiles_phone_format check (phone ~ '^\+222[0-9]{8}$'),
  constraint profiles_admin_role_consistency check ((role = 'admin') = (admin_role is not null))
);
create index if not exists profiles_role_idx on public.profiles (role);

-- ---------------------------------------------------------------------------
-- Catalogues
-- ---------------------------------------------------------------------------
create table if not exists public.cities (
  id         uuid primary key default gen_random_uuid(),
  name_ar    text not null,
  name_fr    text not null,
  is_active  boolean not null default true,
  sort_order int not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (name_fr)
);

create table if not exists public.service_types (
  id         uuid primary key default gen_random_uuid(),
  name_ar    text not null,
  name_fr    text not null,
  icon       text not null default 'directions_car',
  is_active  boolean not null default true,
  sort_order int not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (name_fr)
);

-- ---------------------------------------------------------------------------
-- Chauffeurs
-- ---------------------------------------------------------------------------
create table if not exists public.drivers (
  id               uuid primary key default gen_random_uuid(),
  profile_id       uuid not null unique references public.profiles (id) on delete cascade,
  city_id          uuid references public.cities (id),
  status           public.driver_status not null default 'draft',
  rejection_reason text,
  is_available     boolean not null default false,
  bio              text,
  years_experience int check (years_experience between 0 and 60),
  rating_avg       numeric(3, 2) not null default 0,
  rating_count     int not null default 0,
  completed_count  int not null default 0,
  submitted_at     timestamptz,
  approved_at      timestamptz,
  created_at       timestamptz not null default now(),
  updated_at       timestamptz not null default now()
);
create index if not exists drivers_status_idx on public.drivers (status);
create index if not exists drivers_city_idx on public.drivers (city_id);

create table if not exists public.driver_documents (
  id               uuid primary key default gen_random_uuid(),
  driver_id        uuid not null references public.drivers (id) on delete cascade,
  type             public.document_type not null,
  file_path        text not null,
  status           public.document_status not null default 'pending',
  rejection_reason text,
  reviewed_by      uuid references public.profiles (id) on delete set null,
  reviewed_at      timestamptz,
  created_at       timestamptz not null default now(),
  updated_at       timestamptz not null default now(),
  unique (driver_id, type)
);

create table if not exists public.vehicles (
  id            uuid primary key default gen_random_uuid(),
  driver_id     uuid not null unique references public.drivers (id) on delete cascade,
  vehicle_type  text not null default 'sedan'
                check (vehicle_type in ('sedan', 'suv', '4x4', 'van', 'minibus', 'bus', 'pickup')),
  brand         text not null,
  model         text not null,
  year          int check (year between 1980 and 2100),
  color         text,
  seats         int not null default 4 check (seats between 1 and 80),
  plate         text not null,
  photo_paths   text[] not null default '{}',
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now()
);

create table if not exists public.driver_services (
  id              uuid primary key default gen_random_uuid(),
  driver_id       uuid not null references public.drivers (id) on delete cascade,
  service_type_id uuid not null references public.service_types (id),
  city_ids        uuid[] not null default '{}',
  price           int not null check (price > 0),
  price_unit      public.price_unit not null default 'per_trip',
  is_active       boolean not null default true,
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now(),
  unique (driver_id, service_type_id)
);

-- weekday : ISO 1 (lundi) .. 7 (dimanche) — identique à DateTime.weekday de Dart.
create table if not exists public.driver_availability (
  id         uuid primary key default gen_random_uuid(),
  driver_id  uuid not null references public.drivers (id) on delete cascade,
  weekday    int not null check (weekday between 1 and 7),
  start_time time not null,
  end_time   time not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (start_time < end_time),
  unique (driver_id, weekday, start_time)
);

-- ---------------------------------------------------------------------------
-- Paramètres et commissions
-- ---------------------------------------------------------------------------
create table if not exists public.app_settings (
  id         uuid primary key default gen_random_uuid(),
  key        text not null unique,
  value      jsonb not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.commission_rates (
  id              uuid primary key default gen_random_uuid(),
  rate            numeric(5, 4) not null check (rate >= 0 and rate <= 1),
  service_type_id uuid references public.service_types (id) on delete cascade,
  city_id         uuid references public.cities (id) on delete cascade,
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now(),
  check (service_type_id is not null or city_id is not null),
  unique nulls not distinct (service_type_id, city_id)
);

-- ---------------------------------------------------------------------------
-- Portefeuille
-- ---------------------------------------------------------------------------
create table if not exists public.wallets (
  id         uuid primary key default gen_random_uuid(),
  driver_id  uuid not null unique references public.drivers (id) on delete cascade,
  balance    int not null default 0 check (balance >= 0),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.topup_requests (
  id          uuid primary key default gen_random_uuid(),
  driver_id   uuid not null references public.drivers (id) on delete cascade,
  amount      int not null check (amount > 0),
  method      text not null,
  reference   text,
  proof_path  text,
  status      public.topup_status not null default 'pending',
  review_note text,
  reviewed_by uuid references public.profiles (id) on delete set null,
  reviewed_at timestamptz,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);
create index if not exists topup_requests_status_idx on public.topup_requests (status, created_at desc);
create index if not exists topup_requests_driver_idx on public.topup_requests (driver_id, created_at desc);

-- ---------------------------------------------------------------------------
-- Réservations
-- ---------------------------------------------------------------------------
create table if not exists public.bookings (
  id              uuid primary key default gen_random_uuid(),
  client_id       uuid references public.profiles (id) on delete set null,
  client_name     text not null,
  client_phone    text not null,
  driver_id       uuid references public.drivers (id) on delete set null,
  service_type_id uuid not null references public.service_types (id),
  city_id         uuid not null references public.cities (id),
  pickup_text     text not null,
  dropoff_text    text,
  scheduled_at    timestamptz not null,
  passengers      int not null default 1 check (passengers between 1 and 80),
  notes           text,
  price           int not null check (price >= 0),
  status          public.booking_status not null default 'pending',
  channel         public.booking_channel not null default 'app',
  created_by_type public.created_by_type not null default 'client',
  created_by      uuid references public.profiles (id) on delete set null,
  cancelled_by    uuid references public.profiles (id) on delete set null,
  cancel_reason   text,
  accepted_at     timestamptz,
  en_route_at     timestamptz,
  started_at      timestamptz,
  completed_at    timestamptz,
  expires_at      timestamptz,
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now()
);
create index if not exists bookings_client_idx on public.bookings (client_id, created_at desc);
create index if not exists bookings_driver_idx on public.bookings (driver_id, created_at desc);
create index if not exists bookings_status_idx on public.bookings (status, expires_at);
create index if not exists bookings_city_idx on public.bookings (city_id);

create table if not exists public.booking_offers (
  id         uuid primary key default gen_random_uuid(),
  booking_id uuid not null references public.bookings (id) on delete cascade,
  driver_id  uuid not null references public.drivers (id) on delete cascade,
  status     public.offer_status not null default 'pending',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (booking_id, driver_id)
);
create index if not exists booking_offers_driver_idx on public.booking_offers (driver_id, status);

create table if not exists public.commissions (
  id         uuid primary key default gen_random_uuid(),
  booking_id uuid not null unique references public.bookings (id) on delete cascade,
  driver_id  uuid not null references public.drivers (id) on delete cascade,
  rate       numeric(5, 4) not null,
  amount     int not null check (amount >= 0),
  status     public.commission_status not null default 'deducted',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index if not exists commissions_driver_idx on public.commissions (driver_id, created_at desc);

create table if not exists public.wallet_transactions (
  id               uuid primary key default gen_random_uuid(),
  wallet_id        uuid not null references public.wallets (id) on delete cascade,
  type             public.wallet_tx_type not null,
  amount           int not null,
  balance_after    int not null check (balance_after >= 0),
  booking_id       uuid references public.bookings (id) on delete set null,
  topup_request_id uuid references public.topup_requests (id) on delete set null,
  note             text,
  created_by       uuid references public.profiles (id) on delete set null,
  created_at       timestamptz not null default now(),
  updated_at       timestamptz not null default now()
);
create index if not exists wallet_tx_wallet_idx on public.wallet_transactions (wallet_id, created_at desc);

-- ---------------------------------------------------------------------------
-- Avis, favoris, plaintes, notifications, annonces, audit
-- ---------------------------------------------------------------------------
create table if not exists public.reviews (
  id         uuid primary key default gen_random_uuid(),
  booking_id uuid not null unique references public.bookings (id) on delete cascade,
  client_id  uuid references public.profiles (id) on delete set null,
  driver_id  uuid not null references public.drivers (id) on delete cascade,
  rating     int not null check (rating between 1 and 5),
  comment    text,
  is_hidden  boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index if not exists reviews_driver_idx on public.reviews (driver_id, created_at desc);

create table if not exists public.favorites (
  id         uuid primary key default gen_random_uuid(),
  client_id  uuid not null references public.profiles (id) on delete cascade,
  driver_id  uuid not null references public.drivers (id) on delete cascade,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (client_id, driver_id)
);

create table if not exists public.complaints (
  id         uuid primary key default gen_random_uuid(),
  booking_id uuid references public.bookings (id) on delete set null,
  author_id  uuid not null references public.profiles (id) on delete cascade,
  against_id uuid references public.profiles (id) on delete set null,
  text       text not null,
  status     public.complaint_status not null default 'open',
  resolution text,
  handled_by uuid references public.profiles (id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index if not exists complaints_status_idx on public.complaints (status, created_at desc);

create table if not exists public.notifications (
  id         uuid primary key default gen_random_uuid(),
  user_id    uuid not null references public.profiles (id) on delete cascade,
  title      text not null,
  body       text not null,
  data       jsonb not null default '{}'::jsonb,
  read_at    timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index if not exists notifications_user_idx on public.notifications (user_id, created_at desc);

-- Modèles de notification localisés (utilisés par public.notify). Aucune policy : lecture serveur uniquement.
create table if not exists public.notification_templates (
  key   text not null,
  lang  text not null check (lang in ('ar', 'fr')),
  title text not null,
  body  text not null,
  primary key (key, lang)
);

create table if not exists public.announcements (
  id               uuid primary key default gen_random_uuid(),
  audience         text not null check (audience in ('drivers', 'clients', 'all')),
  title            text not null,
  body             text not null,
  recipients_count int not null default 0,
  created_by       uuid references public.profiles (id) on delete set null,
  created_at       timestamptz not null default now(),
  updated_at       timestamptz not null default now()
);

create table if not exists public.audit_logs (
  id         uuid primary key default gen_random_uuid(),
  actor_id   uuid references public.profiles (id) on delete set null,
  action     text not null,
  entity     text not null,
  entity_id  uuid,
  payload    jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index if not exists audit_logs_created_idx on public.audit_logs (created_at desc);

-- ---------------------------------------------------------------------------
-- Trigger set_updated_at sur toutes les tables ayant updated_at (idempotent)
-- ---------------------------------------------------------------------------
do $$
declare
  r record;
begin
  for r in
    select c.table_name
    from information_schema.columns c
    join information_schema.tables t
      on t.table_schema = c.table_schema and t.table_name = c.table_name and t.table_type = 'BASE TABLE'
    where c.table_schema = 'public' and c.column_name = 'updated_at'
  loop
    execute format('drop trigger if exists set_updated_at on public.%I', r.table_name);
    execute format(
      'create trigger set_updated_at before update on public.%I for each row execute function public.set_updated_at()',
      r.table_name);
  end loop;
end $$;

-- ---------------------------------------------------------------------------
-- RLS activée sur TOUTES les tables du schéma public (les policies suivent dans 08)
-- ---------------------------------------------------------------------------
do $$
declare
  r record;
begin
  for r in select tablename from pg_tables where schemaname = 'public' loop
    execute format('alter table public.%I enable row level security', r.tablename);
  end loop;
end $$;
