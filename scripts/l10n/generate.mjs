// Génère apps/saiqi_driver/lib/core/l10n/app_ar.arb et app_fr.arb depuis scripts/l10n/strings/*.mjs
// (une seule source => parité ar/fr garantie). Usage : node scripts/l10n/generate.mjs
// Les placeholders {nom} sont détectés automatiquement (type String : les montants/dates sont formatés avant).
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath, pathToFileURL } from 'node:url';

const here = path.dirname(fileURLToPath(import.meta.url));
const outDir = path.resolve(here, '..', '..', 'apps', 'saiqi_driver', 'lib', 'core', 'l10n');
const dir = path.join(here, 'strings');

const all = {};
for (const f of fs.readdirSync(dir).filter((f) => f.endsWith('.mjs')).sort()) {
  const mod = await import(pathToFileURL(path.join(dir, f)).href);
  for (const [k, v] of Object.entries(mod.default)) {
    if (all[k]) throw new Error(`Clé dupliquée : ${k} (${f})`);
    if (!Array.isArray(v) || v.length !== 2 || !v[0] || !v[1]) throw new Error(`Clé ${k} : [ar, fr] requis`);
    all[k] = v;
  }
}

const re = /\{([a-zA-Z][a-zA-Z0-9_]*)\}/g;
const names = (s) => [...s.matchAll(re)].map((m) => m[1]).sort().join(',');

const build = (idx, lang) => {
  const arb = { '@@locale': lang };
  for (const [k, v] of Object.entries(all)) {
    const a = names(v[0]), f = names(v[1]);
    if (a !== f) throw new Error(`Placeholders différents pour ${k} : ar[${a}] fr[${f}]`);
    arb[k] = v[idx];
    if (a && idx === 0) {
      arb[`@${k}`] = { placeholders: Object.fromEntries(a.split(',').map((p) => [p, { type: 'String' }])) };
    }
  }
  return arb;
};

// ---- Dart : libellés d'énumérations et messages d'erreur, générés depuis les clés ----
const enumGroups = {
  bookingStatus: 'BookingStatus', driverStatus: 'DriverStatus', accountStatus: 'AccountStatus',
  documentType: 'DocumentType', documentStatus: 'DocumentStatus', channel: 'BookingChannel',
  txType: 'WalletTxType', topupStatus: 'TopupStatus', complaintStatus: 'ComplaintStatus',
  priceUnit: 'PriceUnit', adminRole: 'AdminRole',
};
let dart = `// GÉNÉRÉ par scripts/l10n/generate.mjs — ne pas modifier à la main.
import '../models/enums.dart';
import 'gen/app_localizations.dart';

extension EnumLabels on AppLocalizations {
`;
for (const [prefix, type] of Object.entries(enumGroups)) {
  const keys = Object.keys(all).filter((k) => k.startsWith(prefix + '_'));
  dart += `  String ${prefix}Label(${type} v) => switch (v) {\n`;
  for (const k of keys) dart += `        ${type}.${k.slice(prefix.length + 1)} => ${k},\n`;
  dart += `      };\n`;
}
const stringGroup = (prefix, fn, fallbackKey) => {
  const keys = Object.keys(all).filter((k) => k.startsWith(prefix + '_'));
  let s = `  String ${fn}(String v) => switch (v) {\n`;
  for (const k of keys) s += `        '${k.slice(prefix.length + 1)}' => ${k},\n`;
  return s + `        _ => v,\n      };\n`;
};
dart += stringGroup('vehicleType', 'vehicleTypeLabel');
dart += stringGroup('audience', 'audienceLabel');
dart += `  String weekdayLabel(int weekday) => switch (weekday) {\n`;
for (let i = 1; i <= 7; i++) dart += `        ${i} => weekday_${i},\n`;
dart += `        _ => '',\n      };\n`;
dart += `\n  /// Message localisé pour un code d'erreur métier ; null si le code est inconnu.\n  String? errorForCode(String code) => switch (code) {\n`;
for (const k of Object.keys(all).filter((k) => k.startsWith('err_') && k !== 'err_insufficient_balance_detail')) {
  dart += `        '${k.slice(4)}' => ${k},\n`;
}
dart += `        _ => null,\n      };\n}\n`;

fs.mkdirSync(outDir, { recursive: true });
fs.writeFileSync(path.join(outDir, 'l10n_labels.dart'), dart);
fs.writeFileSync(path.join(outDir, 'app_ar.arb'), JSON.stringify(build(0, 'ar'), null, 2) + '\n');
fs.writeFileSync(path.join(outDir, 'app_fr.arb'), JSON.stringify(build(1, 'fr'), null, 2) + '\n');
console.log(`ARB générés : ${Object.keys(all).length} clés`);
