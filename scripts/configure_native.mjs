#!/usr/bin/env node
// Configure (de façon idempotente) les projets natifs des 3 apps :
//  - Android : permissions, <queries> (appel / WhatsApp), nom d'app localisé (ar/fr), canal FCM par défaut,
//              Firebase activé SEULEMENT si google-services.json existe, signature release via key.properties
//  - iOS     : permissions caméra/photos, schémas URL, mode d'arrière-plan push, nom affiché + InfoPlist.strings ar/fr
//   node scripts/configure_native.mjs
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');

const apps = {
  saiqi_client: { ar: 'سائقي', fr: 'SAIQI', ios: 'SAIQI' },
  saiqi_driver: { ar: 'سائقي - سائق', fr: 'SAIQI Chauffeur', ios: 'SAIQI Chauffeur' },
  saiqi_admin: { ar: 'سائقي - إدارة', fr: 'SAIQI Admin', ios: 'SAIQI Admin' },
};

const read = (f) => fs.readFileSync(f, 'utf8').replace(/\r\n/g, '\n');
const write = (f, s) => fs.writeFileSync(f, s);

for (const [app, names] of Object.entries(apps)) {
  const base = path.join(root, 'apps', app);
  if (!fs.existsSync(base)) continue;
  const android = path.join(base, 'android');

  // ---- AndroidManifest.xml ----------------------------------------------------
  const manifestFile = path.join(android, 'app', 'src', 'main', 'AndroidManifest.xml');
  let m = read(manifestFile);
  m = m.replace(/android:label="[^"]*"/, 'android:label="@string/app_name"');
  if (!m.includes('android.permission.INTERNET')) {
    m = m.replace(
      '<application',
      `<uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
    <application`,
    );
  }
  if (!m.includes('android:scheme="whatsapp"')) {
    m = m.replace(
      '<queries>',
      `<queries>
        <intent>
            <action android:name="android.intent.action.VIEW"/>
            <data android:scheme="tel"/>
        </intent>
        <intent>
            <action android:name="android.intent.action.VIEW"/>
            <data android:scheme="https"/>
        </intent>
        <intent>
            <action android:name="android.intent.action.VIEW"/>
            <data android:scheme="whatsapp"/>
        </intent>`,
    );
  }
  if (!m.includes('default_notification_channel_id')) {
    m = m.replace(
      '<meta-data\n            android:name="flutterEmbedding"',
      `<meta-data
            android:name="com.google.firebase.messaging.default_notification_channel_id"
            android:value="saiqi_default" />
        <meta-data
            android:name="flutterEmbedding"`,
    );
  }
  write(manifestFile, m);

  // ---- noms d'app localisés (Android) -----------------------------------------------
  const res = path.join(android, 'app', 'src', 'main', 'res');
  const strings = (name) => `<?xml version="1.0" encoding="utf-8"?>\n<resources>\n    <string name="app_name">${name}</string>\n</resources>\n`;
  for (const [dir, name] of [['values', names.ar], ['values-ar', names.ar], ['values-fr', names.fr]]) {
    fs.mkdirSync(path.join(res, dir), { recursive: true });
    write(path.join(res, dir, 'strings.xml'), strings(name));
  }

  // ---- settings.gradle.kts : plugin Google Services (déclaré, non appliqué) --------------
  const settingsFile = path.join(android, 'settings.gradle.kts');
  let s = read(settingsFile);
  if (!s.includes('com.google.gms.google-services')) {
    s = s.replace(
      'id("org.jetbrains.kotlin.android")',
      'id("com.google.gms.google-services") version "4.4.2" apply false\n    id("org.jetbrains.kotlin.android")',
    );
    write(settingsFile, s);
  }

  // ---- app/build.gradle.kts -----------------------------------------------------------
  const gradleFile = path.join(android, 'app', 'build.gradle.kts');
  let g = read(gradleFile);
  if (!g.includes('key.properties')) {
    g = 'import java.util.Properties\n\n' + g;
    g = g.replace(
      /(plugins \{[\s\S]*?\n\}\n)/,
      `$1
// Push (FCM) : activé uniquement si google-services.json est présent (fichier non commité, voir docs/FIREBASE.md).
if (file("google-services.json").exists()) {
    apply(plugin = "com.google.gms.google-services")
}

// Signature release : android/key.properties (non commité) ; à défaut, signature debug pour les essais.
val keystoreProperties = Properties().apply {
    val f = rootProject.file("key.properties")
    if (f.exists()) f.inputStream().use { load(it) }
}
`,
    );
    g = g.replace('minSdk = flutter.minSdkVersion', 'minSdk = maxOf(flutter.minSdkVersion, 23) // firebase_messaging : API 23 minimum');
    g = g.replace(
      /    buildTypes \{[\s\S]*?\n    \}\n\}/,
      `    signingConfigs {
        if (keystoreProperties.containsKey("storeFile")) {
            create("release") {
                storeFile = file(keystoreProperties.getProperty("storeFile"))
                storePassword = keystoreProperties.getProperty("storePassword")
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (keystoreProperties.containsKey("storeFile")) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
        }
    }
}`,
    );
    write(gradleFile, g);
  }

  // ---- iOS Info.plist ---------------------------------------------------------------------
  const plistFile = path.join(base, 'ios', 'Runner', 'Info.plist');
  let p = read(plistFile);
  p = p.replace(/(<key>CFBundleDisplayName<\/key>\s*<string>)[^<]*(<\/string>)/, `$1${names.ios}$2`);
  if (!p.includes('NSCameraUsageDescription')) {
    p = p.replace(
      /<\/dict>\s*<\/plist>\s*$/,
      `\t<key>CFBundleLocalizations</key>
\t<array>
\t\t<string>ar</string>
\t\t<string>fr</string>
\t</array>
\t<key>NSCameraUsageDescription</key>
\t<string>Prendre une photo (document, véhicule, preuve de paiement) / التقاط صورة (مستند، سيارة، إثبات دفع)</string>
\t<key>NSPhotoLibraryUsageDescription</key>
\t<string>Choisir une photo depuis la galerie / اختيار صورة من المعرض</string>
\t<key>LSApplicationQueriesSchemes</key>
\t<array>
\t\t<string>tel</string>
\t\t<string>whatsapp</string>
\t\t<string>https</string>
\t</array>
\t<key>UIBackgroundModes</key>
\t<array>
\t\t<string>remote-notification</string>
\t</array>
</dict>
</plist>
`,
    );
  }
  write(plistFile, p);

  // ---- iOS : noms localisés (fichiers prêts ; à rattacher à la cible Runner dans Xcode, voir docs/SETUP.md)
  for (const [lang, name] of [['ar', names.ar], ['fr', names.fr]]) {
    const dir = path.join(base, 'ios', 'Runner', `${lang}.lproj`);
    fs.mkdirSync(dir, { recursive: true });
    write(path.join(dir, 'InfoPlist.strings'), `"CFBundleDisplayName" = "${name}";\n"CFBundleName" = "${name}";\n`);
  }

  console.log(`configuré : ${app}`);
}
