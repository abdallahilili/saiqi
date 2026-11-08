# Scénarios d'intégration

Deux façons de rejouer de bout en bout le parcours métier de SAIQI.

## A. Sans Docker — `make db-check` (vérifié)

```bash
cd scripts/db-check && npm install && node run.mjs     # ou : make db-check
```

PostgreSQL embarqué + stubs Supabase → migrations (×2), seed, **tests pgTAP (107 assertions)**, contrôle de contrat Dart↔SQL, puis le scénario
`scripts/db-check/scenario.mjs`, joué avec le rôle `authenticated` et des claims JWT (donc **RLS et privilèges réels**) :

1. **Inscription chauffeur** (téléphone + mot de passe) → profil + dossier `draft`, aucun wallet.
2. Dossier : infos, véhicule, service, 4 documents → `submit_driver_application` → `pending`.
3. **Validation admin** (validator) → `approved`, wallet créé à 0 ; le chauffeur se met disponible.
4. **Recharge 300** : demande du chauffeur, validation du support → solde 300.
5. **Réservation client** (1000 MRU, commission 10 %) : le téléphone du client reste invisible pour le chauffeur ; **acceptation → solde 200** ;
   le client obtient alors le téléphone du chauffeur.
6. **Course** : en route → en cours → terminée → **avis 5★** (note moyenne du chauffeur recalculée).
7. **Demande créée par l'admin** (client sans compte, WhatsApp) envoyée à 2 chauffeurs : le premier qui accepte l'obtient, le second reçoit
   `booking_not_available` et n'est pas débité.
8. **Solde 100 < commission 150** : `insufficient_balance` (rien n'est débité) ; après une nouvelle recharge l'acceptation passe ;
   l'**annulation** restitue la commission. Invariant final : `solde = somme des wallet_transactions`.

## B. Contre un Supabase local réel (Docker) — `scripts/integration-http.mjs`

Même scénario, mais via GoTrue + PostgREST (JWT réels, signature `signUp`, politiques RLS en conditions réelles).

```bash
npx supabase start && npx supabase db reset
SUPABASE_URL=http://127.0.0.1:54321 \
SUPABASE_PUBLISHABLE_KEY=<anon key affichée par `supabase status`> \
node scripts/integration-http.mjs
```

> Ce script n'a **pas pu être exécuté dans l'environnement de développement** (pas de Docker) ; sa logique reprend le scénario A
> qui, lui, est vérifié. Il refuse de tourner contre `*.supabase.co` sans `ALLOW_REMOTE=1` (il crée des comptes de test).

## C. Parcours manuel avec les 3 apps

1. `supabase db reset` (comptes de seed, mot de passe `Test1234!`).
2. **App Chauffeur** : *Créer un compte* (n° quelconque, 8 car. min.) → remplir infos, documents (photos), véhicule, services → *Envoyer le dossier*.
3. **App Admin** (`+22220000002`) → Chauffeurs → *En attente* → ouvrir le dossier, visionner les documents → *Valider*.
4. **App Chauffeur** : l'écran « en attente » bascule seul vers l'accueil ; Portefeuille → *Demander une recharge* (300 MRU).
5. **App Admin** (`+22220000003`) → Portefeuilles → valider la recharge.
6. **App Client** (`+22236000001`) : choisir la ville et le service → chauffeur → *Réserver*.
7. **App Chauffeur** : la demande arrive en temps réel (compte à rebours, commission annoncée) → *Accepter* : le solde diminue.
8. Suivre *En route → Démarrer → Terminer* côté chauffeur ; côté client le suivi se met à jour ; noter le chauffeur.
9. **App Admin** : *Créer une demande* (client hors application, WhatsApp) → cocher 2 chauffeurs → le premier qui accepte l'obtient.
10. Descendre le solde sous la commission : le bouton *Accepter* est remplacé par *Recharger mon portefeuille*.
