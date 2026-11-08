# API SAIQI — fonctions RPC, vues et Edge Functions

Toute la logique sensible (commission, wallet, acceptation, annulation) est en SQL (`SECURITY DEFINER`, `search_path = public`).
Les apps appellent `supabase.rpc('<fonction>', params: {...})`. Les erreurs métier sont des exceptions Postgres `P0001` dont le
**message est un code stable** (`PostgrestException.message`) ; `details` porte des paramètres (`required=150;balance=40`).

## Conventions

- Montants : **MRU entiers**. Commission = `round(prix × taux)`.
- Téléphones : stockés `+222XXXXXXXX` (normalisés par `normalize_phone`).
- Identité d'authentification : email technique `<chiffres>@saiqi.app` (jamais montré à l'utilisateur).
- `weekday` : ISO 1 (lundi) … 7 (dimanche).

## RPC — client

| Fonction | Paramètres | Retour | Règles / erreurs |
|---|---|---|---|
| `create_booking` | `p_driver_id, p_service_type_id, p_city_id, p_pickup_text, p_dropoff_text, p_scheduled_at, p_passengers=1, p_notes` | `bookings` | `not_client`, `driver_not_available`, `service_not_offered`, `pickup_required`, `invalid_schedule`, `too_many_passengers`, `too_many_pending`. Prix = tarif du chauffeur ; `expires_at = now() + response_timeout_minutes`. |
| `cancel_booking` | `p_booking_id, p_reason` | `bookings` | Client : `pending`/`accepted` seulement (`cancel_not_allowed_after_en_route`). Chauffeur : après acceptation. Admin : tout statut non final. Restitue la commission (`refund`). `booking_not_cancellable`, `not_allowed`. |
| `submit_review` | `p_booking_id, p_rating (1..5), p_comment` | `reviews` | Uniquement si `completed`, 1 avis par réservation : `booking_not_completed`, `already_reviewed`, `invalid_rating`. |
| `get_booking_contact` | `p_booking_id` | `(full_name, phone)` | Client → téléphone du chauffeur ; chauffeur → téléphone du client. Seulement si le statut est `accepted`, `en_route`, `in_progress` ou `completed` (`contact_not_available`, `not_allowed`). |
| `get_booking_driver` | `p_booking_id` | infos chauffeur sans téléphone | Réservé au client de la réservation (ou admin). Plaque visible après acceptation. |
| `search_drivers` | `p_city_id, p_service_type_id, p_min_price, p_max_price, p_min_rating, p_min_seats, p_vehicle_type, p_only_available=true, p_sort ('rating'\|'price_asc'\|'price_desc'\|'trips'), p_limit=50, p_offset=0` | liste (une ligne par chauffeur, service le moins cher correspondant) | Chauffeurs `approved` et comptes actifs uniquement. |
| `file_complaint` | `p_booking_id (nullable), p_text` | `complaints` | Auteur = client ou chauffeur de la réservation. `text_too_short`. |

## RPC — chauffeur

| Fonction | Paramètres | Retour | Règles / erreurs |
|---|---|---|---|
| `accept_booking` | `p_booking_id` | `bookings` | Atomique (`FOR UPDATE` booking, offre, wallet). Débite la commission, écrit `commissions` + `wallet_transactions`, passe `accepted`, expire les autres offres. Erreurs : `driver_not_approved`, `booking_not_available` (déjà prise/annulée), `booking_expired`, `offer_not_available`, **`insufficient_balance`** (`details: required=…;balance=…`). |
| `reject_booking` | `p_booking_id` | void | Refuse l'offre ; si plus aucune offre en attente → réservation `rejected`. |
| `update_booking_status` | `p_booking_id, p_new_status` | `bookings` | Transitions valides : `accepted→en_route→in_progress→completed` (`invalid_transition`, `not_allowed`). |
| `set_driver_availability` | `p_available` | `drivers` | Chauffeur `approved` uniquement. |
| `save_driver_document` | `p_type, p_file_path` | `driver_documents` | Chemin obligatoirement `<user_id>/…` (`invalid_path`). Repasse le document en `pending`. |
| `submit_driver_application` | — | `drivers` | `draft`/`rejected` → `pending`. `application_incomplete` (`details: missing=vehicle,doc:id_card,…`). Documents requis : id_card, driving_license, vehicle_registration, photo. |
| `request_topup` | `p_amount, p_method, p_reference, p_proof_path` | `topup_requests` | `amount_too_low` (`min=…`), `method_required`. Notifie les admins. |
| `driver_stats` | — | jsonb | `completed_count, revenue_gross, commissions_paid, rating_avg, rating_count, pending_requests, upcoming_count`. |

## RPC — admin (contrôle par `admin_role`)

| Fonction | Rôles | Description |
|---|---|---|
| `admin_review_driver(p_driver_id, p_approve, p_reason)` | super_admin, validator | Valide/refuse un dossier `pending` (motif obligatoire au refus) ; crée le wallet. |
| `admin_review_document(p_document_id, p_approve, p_reason)` | super_admin, validator | Valide/refuse un document. |
| `admin_set_driver_status(p_driver_id, p_status ['approved'\|'suspended'], p_reason)` | super_admin, validator | Suspend / réactive. |
| `admin_set_account_status(p_profile_id, p_status, p_reason)` | selon la cible (client : super_admin/support ; chauffeur : +validator ; admin : super_admin) | Suspend/bloque un compte. |
| `admin_set_admin_role(p_profile_id, p_admin_role)` | super_admin | Change le rôle d'un membre de l'équipe. |
| `admin_review_topup(p_topup_id, p_approve, p_note)` | super_admin, support | Crédite le wallet si approuvé. |
| `admin_adjust_wallet(p_driver_id, p_amount, p_note)` | super_admin | Ajustement signé avec motif ; jamais sous 0. |
| `admin_create_booking(p_client_name, p_client_phone, p_service_type_id, p_city_id, p_pickup_text, p_dropoff_text, p_scheduled_at, p_passengers, p_notes, p_price, p_channel ['phone'\|'whatsapp'\|'other'], p_driver_ids uuid[])` | super_admin, support | Demande pour un client sans compte ; 1..20 chauffeurs ; le premier qui accepte l'obtient. Lie `client_id` si le numéro correspond à un client existant. |
| `admin_reassign_booking(p_booking_id, p_driver_ids uuid[])` | super_admin, support | Change de chauffeur : restitue la commission, renvoie des offres. |
| `admin_handle_complaint(p_complaint_id, p_status, p_resolution)` | super_admin, support | Traite une plainte. |
| `admin_moderate_review(p_review_id, p_hidden)` | super_admin, support | Masque un avis (retiré du calcul de note). |
| `admin_send_announcement(p_audience ['drivers'\|'clients'\|'all'], p_title, p_body)` | super_admin, support | Notification à tous. |
| `admin_warn_user(p_profile_id, p_message)` | super_admin, support | Envoie un avertissement (notification) à un utilisateur ; audité. |
| `admin_dashboard_stats()` | tous les admins | KPI du tableau de bord. |

Les catalogues (`cities`, `service_types`), `commission_rates` et `app_settings` sont modifiés directement (RLS : `super_admin` seulement, audités par trigger).

## Vues

| Vue | Contenu |
|---|---|
| `public_drivers` | Chauffeurs approuvés + comptes actifs : nom, avatar, ville, note, véhicule (sans plaque), **jamais de téléphone**. Lisible par `anon` et `authenticated`. |
| `public_driver_services` | Tarifs actifs des chauffeurs visibles. |
| `public_driver_reviews` | Avis non masqués (prénom du client seulement). |
| `driver_incoming_requests` | Demandes en attente du chauffeur connecté (avec `commission_amount`), **sans téléphone client**. |

## Tables lisibles par le client API (RLS)

Chauffeur : ses `drivers`, `driver_documents`, `vehicles`, `driver_services`, `driver_availability`, `wallets`, `wallet_transactions`, `commissions`, `topup_requests`, `booking_offers`, `reviews`, et les `bookings` **acceptés par lui**.
Client : ses `bookings`, `reviews`, `favorites` (écriture), `complaints`, `notifications`.
Admin : lecture de tout ; écriture directe seulement sur catalogues/taux/paramètres (super_admin).
**Aucune écriture client** sur `wallets`, `wallet_transactions`, `commissions`, `bookings`, `booking_offers`, `topup_requests`, `driver_documents`.
Écritures directes autorisées : `profiles(full_name, avatar_url, language, fcm_token)`, `drivers(city_id, bio, years_experience)`, `vehicles`, `driver_services`, `driver_availability`, `favorites`, `notifications(read_at)`.

## Edge Functions

| Fonction | Auth | Body | Description |
|---|---|---|---|
| `send-push` | en-tête `x-webhook-secret` (Database Webhook sur `notifications` INSERT) | payload webhook | Envoie la notification FCM (HTTP v1) au `fcm_token` du profil. |
| `signup` | anon (`--no-verify-jwt`) | `{ phone, password, role: client\|driver, language?, full_name? }` | Crée le compte via Auth Admin (évite le rate-limit GoTrue `/signup`). Puis l'app ouvre une session avec `signInWithPassword`. |
| `admin-reset-password` | JWT admin (super_admin ou support) | `{ user_id \| phone, new_password }` | Réinitialise un mot de passe (min. 8). Erreurs : `password_too_short`, `profile_not_found`, `admin_forbidden`, `cannot_modify_self`. |
| `admin-create-admin` | JWT super_admin | `{ phone, password, full_name, admin_role }` | Crée un compte d'équipe admin. |
| `admin-create-driver` | JWT super_admin ou validator | `{ phone, password, full_name }` | Crée un compte chauffeur en statut `draft` (le chauffeur complète puis soumet). |

## Realtime

Publication `supabase_realtime` : `bookings`, `booking_offers`, `wallets`, `wallet_transactions`, `drivers`, `driver_documents`, `topup_requests`, `notifications`, `complaints` (filtrés par RLS).

## Notifications

Chaque notification insérée dans `notifications` (titre/corps localisés ar/fr d'après `profiles.language`, `data.screen` / `data.booking_id` pour la navigation) déclenche `send-push`.
