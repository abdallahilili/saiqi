# Notifications push (Firebase Cloud Messaging)

Les 3 apps enregistrent un token FCM dans `profiles.fcm_token` après connexion. Chaque ligne insérée dans `public.notifications`
(réservation reçue, acceptée, recharge validée, dossier validé, annonce…) déclenche l'Edge Function `send-push`, qui envoie la
notification au token du destinataire dans sa langue (ar/fr). Au tap, l'app ouvre l'écran concerné (`data.screen`, `data.booking_id`).

> Sans Firebase configuré, les apps **fonctionnent normalement** (le push est simplement désactivé) et se compilent sans les fichiers ci-dessous.

## 1. Projet Firebase

1. Créer un projet sur <https://console.firebase.google.com>.
2. Ajouter **3 apps Android** (identifiants de paquet exacts) :
   - `com.saiqi.saiqi_client`
   - `com.saiqi.saiqi_driver`
   - `com.saiqi.saiqi_admin`
3. Ajouter **3 apps iOS** (Bundle ID exacts) : `com.saiqi.saiqiClient`, `com.saiqi.saiqiDriver`, `com.saiqi.saiqiAdmin`.
4. Télécharger les fichiers de configuration et les placer ainsi (**ils sont ignorés par git, ne jamais les commiter**) :

| App | Android | iOS |
|---|---|---|
| Client | `apps/saiqi_client/android/app/google-services.json` | `apps/saiqi_client/ios/Runner/GoogleService-Info.plist` |
| Chauffeur | `apps/saiqi_driver/android/app/google-services.json` | `apps/saiqi_driver/ios/Runner/GoogleService-Info.plist` |
| Admin | `apps/saiqi_admin/android/app/google-services.json` | `apps/saiqi_admin/ios/Runner/GoogleService-Info.plist` |

Le build Android applique automatiquement le plugin Google Services **uniquement si** `google-services.json` est présent.

## 2. iOS (APNs)

- Firebase Console → Paramètres du projet → Cloud Messaging → *Clé d'authentification APNs* : téléverser une clé `.p8` (Apple Developer).
- Dans Xcode (cible *Runner*, pour chaque app) : *Signing & Capabilities* → ajouter **Push Notifications** et **Background Modes → Remote notifications**.
- Ajouter `GoogleService-Info.plist` à la cible *Runner* (glisser-déposer dans Xcode, « Copy items if needed »).

## 3. Envoi côté serveur (Edge Function `send-push`)

1. Firebase Console → Paramètres → *Comptes de service* → *Générer une nouvelle clé privée* (JSON). **Ne pas le commiter.**
2. Secrets Supabase :

```bash
npx supabase secrets set FIREBASE_SERVICE_ACCOUNT="$(cat chemin/vers/service-account.json)"
npx supabase secrets set PUSH_WEBHOOK_SECRET=<chaîne aléatoire longue>
npx supabase secrets set SAIQI_SECRET_KEY=<clé secrète du projet Supabase>
npx supabase functions deploy send-push --no-verify-jwt
```

3. Dashboard Supabase → Database → **Webhooks** → *Create a new hook* :
   - Table : `public.notifications`, événement : **Insert**
   - Type : *Supabase Edge Functions* → `send-push`, méthode `POST`
   - En-tête HTTP : `x-webhook-secret` = la valeur de `PUSH_WEBHOOK_SECRET`

## 4. Vérification

1. Lancer l'app Chauffeur sur un appareil réel, se connecter : `profiles.fcm_token` est renseigné.
2. Depuis l'app Admin, envoyer une annonce (Plus → Annonces) : la notification arrive en premier plan (notification locale),
   en arrière-plan (notification système) et le tap ouvre l'app.

## Notes techniques

- Canal Android : `saiqi_default` (importance haute) ; autorisation `POST_NOTIFICATIONS` demandée au premier démarrage (Android 13+).
- À la déconnexion, le token est retiré du profil : un appareil ne reçoit plus les notifications du compte précédent.
- Token FCM : l'API `getToken()` (dépréciée au profit de `register()`/`onRegistered`, qui produit un *Installation ID* et non un
  token d'enregistrement FCM v1) est conservée volontairement ; voir `docs/DECISIONS.md`.
