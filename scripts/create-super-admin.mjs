#!/usr/bin/env node
// Crée (ou promeut) le premier super admin d'un projet Supabase.
//
//   node scripts/create-super-admin.mjs <téléphone> <mot_de_passe> ["Nom complet"]
//   ex. node scripts/create-super-admin.mjs +22236123456 "MotDePasse8+" "Admin SAIQI"
//
// La clé secrète est lue dans supabase/.env (ignoré par git — voir supabase/.env.example) :
//   SUPABASE_URL=https://<ref>.supabase.co
//   SUPABASE_SECRET_KEY=<clé secrète du projet>
// Elle n'est jamais écrite ailleurs, ni loguée, ni transmise à une app.
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');

function loadEnv(file) {
  const out = {};
  if (!fs.existsSync(file)) return out;
  for (const line of fs.readFileSync(file, 'utf8').split(/\r?\n/)) {
    const m = line.match(/^\s*([A-Z0-9_]+)\s*=\s*(.*)\s*$/);
    if (m && !line.trim().startsWith('#')) out[m[1]] = m[2].replace(/^["']|["']$/g, '');
  }
  return out;
}

function normalizePhone(input) {
  let d = String(input ?? '').replace(/\D/g, '');
  if (d.length === 13 && d.startsWith('00222')) d = d.slice(5);
  else if (d.length === 11 && d.startsWith('222')) d = d.slice(3);
  return /^[0-9]{8}$/.test(d) ? `+222${d}` : null;
}

const [, , phoneArg, password, fullName = 'Super Admin'] = process.argv;
const phone = normalizePhone(phoneArg);
if (!phone || !password) {
  console.error('Usage : node scripts/create-super-admin.mjs <téléphone +222…> <mot_de_passe> ["Nom complet"]');
  process.exit(1);
}
if (password.length < 8) {
  console.error('Le mot de passe doit contenir au moins 8 caractères.');
  process.exit(1);
}

const env = { ...loadEnv(path.join(root, 'supabase', '.env')), ...process.env };
const url = (env.SUPABASE_URL || '').replace(/\/$/, '');
const secret = env.SUPABASE_SECRET_KEY;
if (!url || !secret) {
  console.error('SUPABASE_URL et SUPABASE_SECRET_KEY sont requis dans supabase/.env (voir supabase/.env.example).');
  process.exit(1);
}

// Les clés « sb_secret_… » ne sont pas des JWT : on les envoie uniquement dans `apikey`.
const headers = { apikey: secret, 'Content-Type': 'application/json' };
if (secret.startsWith('eyJ')) headers.Authorization = `Bearer ${secret}`;

const email = `${phone.replace(/\D/g, '')}@saiqi.app`;

async function call(method, endpoint, body, extra = {}) {
  const res = await fetch(`${url}${endpoint}`, { method, headers: { ...headers, ...extra }, body: body ? JSON.stringify(body) : undefined });
  const text = await res.text();
  let json = null;
  try { json = text ? JSON.parse(text) : null; } catch { /* non JSON */ }
  return { ok: res.ok, status: res.status, json, text };
}

const created = await call('POST', '/auth/v1/admin/users', {
  email,
  password,
  email_confirm: true,
  user_metadata: { phone, full_name: fullName, role: 'client', language: 'ar' },
});
if (!created.ok && !/already|registered|exists/i.test(created.text)) {
  console.error(`Création du compte impossible (HTTP ${created.status}) : ${created.json?.msg || created.json?.message || created.text}`);
  process.exit(1);
}
console.log(created.ok ? `Compte créé pour ${phone}.` : `Le compte ${phone} existe déjà : promotion uniquement.`);

// Le trigger d'inscription ne crée jamais d'admin : on promeut le profil côté serveur.
const promoted = await call(
  'PATCH',
  `/rest/v1/profiles?phone=eq.${encodeURIComponent(phone)}`,
  { role: 'admin', admin_role: 'super_admin', status: 'active' },
  { Prefer: 'return=representation' },
);
if (!promoted.ok || !Array.isArray(promoted.json) || promoted.json.length === 0) {
  console.error(`Promotion impossible (HTTP ${promoted.status}) : ${promoted.text}`);
  console.error('Vérifiez que les migrations ont bien été appliquées (supabase db push).');
  process.exit(1);
}
console.log(`✓ ${phone} est maintenant super_admin. Connectez-vous dans l'app Admin avec ce numéro et ce mot de passe.`);
