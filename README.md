# SAIQI (سائقي)

Plateforme mauritanienne qui relie **chauffeurs** et **clients**. Trois applications mobiles Flutter (Android + iOS) partagent un seul backend **Supabase**.

| App | Dossier | Rôle |
|---|---|---|
| **Client** | `apps/saiqi_client` | Cherche un chauffeur, réserve, suit en temps réel, évalue |
| **Chauffeur** | `apps/saiqi_driver` | S'inscrit gratuitement, publie ses services, accepte/refuse, gère son portefeuille |
| **Admin** | `apps/saiqi_admin` | Valide les chauffeurs, crée des demandes pour des clients hors application, commissions, portefeuilles, plaintes |

Langues : **arabe (RTL, par défaut) et français** dans les 3 apps · Devise : **MRU** (entiers) · Téléphones : **+222**.

## Modèle économique (sans abonnement)

1. L'inscription du chauffeur est **gratuite**.
2. Le chauffeur envoie de l'argent à SAIQI (ex. 300 MRU) → l'admin valide la recharge → **solde = 300**.
3. À chaque service **accepté**, la **commission** (prix × taux, 10 % par défaut ; réglable par service / ville) est déduite du solde.
4. Solde insuffisant pour la commission → le chauffeur **ne peut pas accepter**. **Annulation → commission restituée.**
5. Le client paie le chauffeur directement (espèces / paiement mobile) : l'application ne traite pas le paiement du service.

Toute la logique sensible (commission, wallet, acceptation, annulation) est en **SQL** (`SECURITY DEFINER`, transactions et verrous `FOR UPDATE`) :
**aucune écriture financière n'est possible depuis les apps**. Deux canaux de demande : l'app client, ou l'admin qui crée la demande pour un client
qui a appelé / écrit sur WhatsApp et l'envoie à 1..n chauffeurs (**le premier qui accepte l'obtient**).

## Authentification sans SMS

Numéro `+222XXXXXXXX` + mot de passe (8 car. min.) + confirmation. En interne : Supabase Auth email/mot de passe avec un email technique
`<chiffres>@saiqi.app` (confirmation d'email désactivée) ; le vrai numéro est dans `profiles.phone` (unique). L'utilisateur ne voit jamais cet email.

## Structure

```
.
├── apps/
│   ├── saiqi_client/  saiqi_driver/  saiqi_admin/   # 3 apps 100 % autonomes (aucune dépendance entre elles)
│   │   └── lib/core/        # socle commun copié à l'identique (modèles, repositories, thème, l10n, widgets)
├── supabase/
│   ├── migrations/          # tout le SQL : schéma, RLS, fonctions métier, vues, storage, cron, grants (12 fichiers)
│   ├── functions/           # Edge Functions : send-push, signup, admin-reset-password, admin-create-admin, admin-create-driver
│   ├── tests/               # tests pgTAP (107 assertions)
│   ├── seed.sql             # comptes et données de démo (LOCAL uniquement)
│   └── config.toml
├── scripts/
│   ├── db-check/            # validation sans Docker : PostgreSQL embarqué, pgTAP shim, contrat Dart↔SQL, scénario d'intégration
│   ├── l10n/                # source unique des textes ar/fr → ARB + libellés Dart générés
│   ├── sync_core.sh         # copie lib/core de saiqi_driver vers les 2 autres apps (outil de dev, jamais au build)
│   ├── create-super-admin.mjs, configure_native.mjs, generate_icons.mjs, integration-http.mjs
└── docs/                    # SETUP, API, DECISIONS, FIREBASE, INTEGRATION
```

## Démarrage rapide

Prérequis : Flutter stable, Node ≥ 20, JDK 17, (Docker pour Supabase local). Détails : [`docs/SETUP.md`](docs/SETUP.md).

```bash
# 1) Base de données
npx supabase start && npx supabase db reset            # local (Docker) — comptes de seed, mot de passe Test1234!
make db-check                                          # sans Docker : migrations + tests pgTAP + scénario complet

# 2) Lancer une app (depuis son dossier, ou via make)
cd apps/saiqi_driver && cp .env.example .env
flutter pub get
flutter run --dart-define-from-file=.env               # idem pour saiqi_client et saiqi_admin
#   make run-client | make run-driver | make run-admin
```

`.env` contient **uniquement** `SUPABASE_URL` et `SUPABASE_PUBLISHABLE_KEY` (valeurs du projet distant par défaut). La clé secrète n'est jamais utilisée par les apps.

### Projet Supabase distant

```bash
npx supabase login
npx supabase link --project-ref oortozhvjalltvwqfrdy
npx supabase db push                                   # migrations + données de référence
# désactiver « Confirm email » dans le dashboard (Authentication → Providers → Email)
cp supabase/.env.example supabase/.env                 # renseigner SUPABASE_SECRET_KEY soi-même
node scripts/create-super-admin.mjs +22236123456 "MotDePasse8+" "Admin SAIQI"
npx supabase functions deploy send-push signup --no-verify-jwt && npx supabase functions deploy admin-reset-password admin-create-admin admin-create-driver
```

Secrets et webhook push : [`docs/SETUP.md`](docs/SETUP.md) · Firebase : [`docs/FIREBASE.md`](docs/FIREBASE.md).

### Builds de production

```bash
cd apps/saiqi_driver && flutter build apk --release --dart-define-from-file=.env     # Android (AAB : flutter build appbundle)
cd apps/saiqi_driver && flutter build ipa --release --dart-define-from-file=.env     # iOS (macOS + Xcode requis)
```

Signature Android : créer `android/key.properties` (`storeFile`, `storePassword`, `keyAlias`, `keyPassword`) — non commité ; sans lui, le build release est signé en debug.

## Tests et qualité

```bash
make analyze        # flutter analyze × 3
make test           # flutter test × 3 + make db-check
```

- **Base** : 107 assertions pgTAP (acceptation atomique, solde 300 → 2 services → 0 → refus, restitution, premier-accepté-gagne, RLS, visibilité des téléphones, inscription), contrôle de contrat Dart↔SQL, scénario de bout en bout — [`docs/INTEGRATION.md`](docs/INTEGRATION.md).
- **Flutter** : tests unitaires du socle (téléphones +222, formats MRU, modèles, erreurs, parité ar/fr) et tests de widgets des écrans clés de chaque app (états de solde, contact masqué avant acceptation, droits par rôle admin, RTL).

## Documentation

[`docs/SETUP.md`](docs/SETUP.md) · [`docs/API.md`](docs/API.md) (RPC, vues, Edge Functions) · [`docs/DECISIONS.md`](docs/DECISIONS.md) · [`docs/FIREBASE.md`](docs/FIREBASE.md) · [`docs/INTEGRATION.md`](docs/INTEGRATION.md)
