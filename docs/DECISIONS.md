# Décisions techniques (SAIQI)

Décisions prises sans interrompre le travail, avec leur justification. Mises à jour au fil des phases.

## Dépôt et outillage

1. **Racine du dépôt = le dossier de travail `Saiqi/`** (pas de sous-dossier `saiqi/` supplémentaire) : le dossier existant porte déjà le nom du projet.
2. **Pas de Docker ni de Supabase CLI locale sur la machine de développement** : `supabase start` / `db reset` / `db test` n'ont pas pu être exécutés ici. À la place, `scripts/db-check` démarre un **vrai PostgreSQL 18 embarqué**, charge des stubs (schémas `auth`/`storage`, rôles `anon`/`authenticated`/`service_role`, publication realtime), applique les migrations deux fois (idempotence), le seed et les tests SQL avec un **shim pgTAP**. `pg_cron` et la vraie extension pgTAP n'y existent pas : les migrations les protègent par une garde conditionnelle, et les tests `supabase/tests/*.sql` sont écrits en pgTAP standard pour `supabase test db`.
3. **Chaque app est autonome** (`lib/core/` copié par `scripts/sync_core.sh`, outil de développement uniquement, jamais au build).

## Authentification

4. Email technique `<chiffres>@saiqi.app` (ex. `22236123456@saiqi.app`), confirmation désactivée, mot de passe ≥ 8. Le numéro réel est dans `profiles.phone` (unique, `+222XXXXXXXX`).
5. **Format du numéro : `+222` + 8 chiffres quelconques** (`^\+222[0-9]{8}$`), pour rester compatible avec l'exemple du cahier des charges (`22212345678`) sans lister les préfixes opérateurs, qui évoluent.
6. **Un numéro = un seul rôle** (client OU chauffeur OU admin). Chaque app vérifie le rôle à la connexion et refuse l'accès sinon.
7. Le trigger d'inscription **ne crée jamais d'admin** ; les comptes admin sont promus côté serveur (script `create-super-admin.mjs`, Edge Function `admin-create-admin`).
8. Erreurs d'inscription : le trigger lève `invalid_phone` / `phone_already_registered`. L'app valide le numéro côté client avant d'appeler Auth et traduit « User already registered ».

## Modèle de données

9. **Un véhicule par chauffeur** (`vehicles.driver_id` unique) — la fiche publique et la recherche s'appuient sur ce véhicule.
10. **`weekday` ISO 1–7** (comme `DateTime.weekday` en Dart).
11. **Chauffeur : disponibilité via RPC** (`set_driver_availability`), pas d'écriture directe de `is_available`. Un chauffeur non approuvé ne peut jamais être disponible (trigger).
12. **Documents requis pour soumettre le dossier** : carte d'identité, permis, carte grise, photo. L'assurance est acceptée mais **facultative**.
13. **Réservation à chauffeur unique et à chauffeurs multiples** passent toutes par `booking_offers` ; `bookings.driver_id` est renseigné dès la création si un seul chauffeur est visé, sinon à l'acceptation.
14. **Prix d'une réservation app** = tarif du chauffeur pour ce service (par course/heure/jour) au moment de la demande ; la commission est calculée sur ce prix.
15. **Taux de commission** : service+ville > service > ville > `default_commission_rate` (10 %). Commission = `round(prix × taux)` en MRU entiers.
16. **Délai de réponse** (`response_timeout_minutes`, 10 min) : `expire_pending_bookings()` (pg_cron, chaque minute) passe les demandes et offres en `expired`.
17. **Avis masqués** (`reviews.is_hidden`) : modération admin, exclus de la note moyenne.
18. **Notifications localisées côté SQL** : titre/corps générés dans la langue du destinataire via `notification_templates` ; `data.screen` indique l'écran à ouvrir au tap.
19. `driver_status` et `account_status` sont distincts : `account_status` bloque tout le compte (connexion refusée par les apps), `driver_status = suspended` retire le chauffeur de la recherche.
20. Données de référence (réglages, villes, services, modèles de notification) dans une **migration** (pour que `supabase db push` les provisionne en production) ; `seed.sql` ne contient que les comptes et données de démo (mot de passe `Test1234!`, local uniquement).

## Sécurité

21. **Moindre privilège** : `revoke all` pour `anon`/`authenticated`, puis `GRANT` explicites (colonnes limitées pour `profiles`, `drivers`, `notifications`). Les futures fonctions ne sont pas exposées par défaut.
22. **Téléphones** : le chauffeur ne peut lire une ligne `bookings` (donc `client_phone`) qu'**après acceptation** (`accepted_at is not null`). Avant, il n'a que la vue `driver_incoming_requests` (sans téléphone). Aucune vue publique n'a de colonne téléphone.
23. `public_drivers` est lisible par `anon` (aucune donnée sensible) ; elle contient les chauffeurs approuvés **et actifs**, avec `is_available` en colonne — `search_drivers` filtre par défaut sur les disponibles.
24. **Rôles admin** : `super_admin` (tout), `validator` (dossiers, documents, suspension de chauffeurs), `support` (réservations, recharges, plaintes, clients, annonces). Ajustement de wallet, taux, catalogues et équipe : `super_admin` uniquement.
25. Clé secrète Supabase : jamais dans le code ni dans git ; `supabase/.env` (ignoré) pour les scripts locaux, secret `SAIQI_SECRET_KEY` pour les Edge Functions (`supabase secrets set`).
26. `send-push` est protégée par le secret partagé `PUSH_WEBHOOK_SECRET` (le webhook n'envoie pas de JWT utilisateur).
27. Edge Function supplémentaire **`admin-create-admin`** (non listée au cahier des charges) : la création d'un compte Auth exige la clé secrète, impossible côté app.
