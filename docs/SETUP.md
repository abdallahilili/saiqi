# Installation et mise en route (SAIQI)

## 1. Prérequis

- Flutter stable (testé avec 3.44.x / Dart 3.12), JDK 17, Android SDK (licences acceptées : `flutter doctor --android-licenses`).
- Node.js ≥ 20 (scripts, Supabase CLI via `npx`).
- Docker Desktop (uniquement pour `supabase start` / `db reset` / `db test` en local).
- Supabase CLI : `npm i -g supabase` ou `npx supabase …`.

## 2. Supabase — projet distant (déjà créé)

Projet : `https://oortozhvjalltvwqfrdy.supabase.co` (ref `oortozhvjalltvwqfrdy`).

```bash
npx supabase login                                    # navigateur / jeton d'accès
npx supabase link --project-ref oortozhvjalltvwqfrdy  # demande le mot de passe de la base
npx supabase db push                                  # applique supabase/migrations/* (+ données de référence)
```

**Dashboard distant → Authentication → Providers → Email : désactiver « Confirm email »** (obligatoire, sinon l'inscription par numéro ne fonctionne pas) et vérifier « Minimum password length = 8 ». Aucun fournisseur SMS/OTP n'est nécessaire.

Dashboard → Database → Extensions : activer `pg_cron` si la migration ne l'a pas fait (la planification `saiqi-expire-pending-bookings` est créée automatiquement quand l'extension existe).

### Premier super admin (une seule fois)

```bash
cp supabase/.env.example supabase/.env      # puis renseigner SUPABASE_SECRET_KEY vous-même (fichier ignoré par git)
node scripts/create-super-admin.mjs +22236123456 "MotDePasse8+" "Admin SAIQI"
```

### Edge Functions et secrets

```bash
# Secrets (valeurs à fournir par vous ; jamais dans git)
npx supabase secrets set SAIQI_SECRET_KEY=<clé secrète du projet>
npx supabase secrets set PUSH_WEBHOOK_SECRET=<chaîne aléatoire longue>
npx supabase secrets set FIREBASE_SERVICE_ACCOUNT="$(cat chemin/vers/firebase-service-account.json)"

npx supabase functions deploy send-push --no-verify-jwt
npx supabase functions deploy admin-reset-password
npx supabase functions deploy admin-create-admin
```

**Database Webhook** (Dashboard → Database → Webhooks → Create) : table `public.notifications`, événement `INSERT`, type *Supabase Edge Functions* → `send-push`, méthode `POST`, en-tête `x-webhook-secret: <PUSH_WEBHOOK_SECRET>`.

## 3. Supabase — local (Docker requis)

```bash
npx supabase start          # base, auth, storage, realtime, edge runtime locaux
npx supabase db reset       # migrations + seed.sql (comptes de démo, mot de passe Test1234!)
npx supabase test db        # tests pgTAP (supabase/tests/*.test.sql)
npx supabase functions serve --env-file supabase/.env
```

Comptes de seed (mot de passe `Test1234!`) : admins `+22220000001` (super_admin), `+22220000002` (validator), `+22220000003` (support) ; clients `+22236000001`, `+22236000002` ; chauffeurs `+22222000001` … `+22222000005` (le n°5 a un solde de 0).

### Validation sans Docker

```bash
make db-check     # ou : cd scripts/db-check && npm install && node run.mjs
```

PostgreSQL embarqué + stubs Supabase + shim pgTAP : applique les migrations deux fois, charge le seed, vérifie les invariants du wallet et exécute les tests SQL. Voir `docs/DECISIONS.md` (n°2) pour les limites.

## 4. Apps Flutter

Chaque app est autonome. Dans `apps/saiqi_<app>/` :

```bash
cp .env.example .env        # contient uniquement SUPABASE_URL et SUPABASE_PUBLISHABLE_KEY
flutter pub get
flutter run --dart-define-from-file=.env
# ou explicitement :
flutter run --dart-define=SUPABASE_URL=https://oortozhvjalltvwqfrdy.supabase.co --dart-define=SUPABASE_PUBLISHABLE_KEY=sb_publishable_…
```

Contre un Supabase local, remplacer l'URL par `http://10.0.2.2:54321` (émulateur Android) ou `http://127.0.0.1:54321` (iOS simulateur) et la clé par l'`anon key` affichée par `supabase start`.

## 5. Dépôt Git

`git push` vers `https://github.com/abdallahilili/saiqi.git`. En cas d'échec d'authentification : exécuter `gh auth login` ou configurer un jeton d'accès personnel / une clé SSH ; ne jamais forcer le push.
