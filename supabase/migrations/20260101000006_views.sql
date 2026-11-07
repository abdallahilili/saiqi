-- =============================================================================
-- SAIQI — 06 : vues publiques (aucun téléphone exposé)
-- Ces vues s'exécutent avec les droits du propriétaire (security definer par défaut) :
-- elles contournent volontairement la RLS de profiles/drivers pour n'exposer que des colonnes sûres.
-- =============================================================================

create or replace view public.public_drivers as
select d.id           as driver_id,
       p.full_name,
       p.avatar_url,
       d.city_id,
       d.rating_avg,
       d.rating_count,
       d.completed_count,
       d.is_available,
       d.years_experience,
       d.bio,
       true           as is_verified,
       v.vehicle_type,
       v.brand        as vehicle_brand,
       v.model        as vehicle_model,
       v.year         as vehicle_year,
       v.color        as vehicle_color,
       v.seats,
       coalesce(v.photo_paths, '{}') as vehicle_photos
  from public.drivers d
  join public.profiles p on p.id = d.profile_id
  left join public.vehicles v on v.driver_id = d.id
 where d.status = 'approved' and p.status = 'active';

create or replace view public.public_driver_services as
select ds.id,
       ds.driver_id,
       ds.service_type_id,
       ds.city_ids,
       ds.price,
       ds.price_unit
  from public.driver_services ds
  join public.drivers d on d.id = ds.driver_id
  join public.profiles p on p.id = d.profile_id
 where ds.is_active and d.status = 'approved' and p.status = 'active';

create or replace view public.public_driver_reviews as
select r.id,
       r.driver_id,
       r.rating,
       r.comment,
       r.created_at,
       coalesce(nullif(split_part(btrim(cp.full_name), ' ', 1), ''), 'Client') as reviewer_name
  from public.reviews r
  join public.drivers d on d.id = r.driver_id
  join public.profiles dp on dp.id = d.profile_id
  left join public.profiles cp on cp.id = r.client_id
 where not r.is_hidden and d.status = 'approved' and dp.status = 'active';

-- Demandes entrantes du chauffeur connecté : le téléphone du client n'y figure JAMAIS.
create or replace view public.driver_incoming_requests as
select o.id            as offer_id,
       b.id            as booking_id,
       b.client_name,
       b.service_type_id,
       st.name_ar      as service_name_ar,
       st.name_fr      as service_name_fr,
       b.city_id,
       c.name_ar       as city_name_ar,
       c.name_fr       as city_name_fr,
       b.pickup_text,
       b.dropoff_text,
       b.scheduled_at,
       b.passengers,
       b.notes,
       b.price,
       b.channel,
       b.expires_at,
       b.created_at,
       public.resolve_commission_rate(b.service_type_id, b.city_id) as commission_rate,
       public.compute_commission(b.price, public.resolve_commission_rate(b.service_type_id, b.city_id)) as commission_amount
  from public.booking_offers o
  join public.bookings b on b.id = o.booking_id
  join public.service_types st on st.id = b.service_type_id
  join public.cities c on c.id = b.city_id
 where o.driver_id = public.current_driver_id()
   and o.status = 'pending'
   and b.status = 'pending'
   and (b.expires_at is null or b.expires_at > now());
