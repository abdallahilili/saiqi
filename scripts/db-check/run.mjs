// Validation Docker-less de la base SAIQI :
//  1. démarre un PostgreSQL embarqué (vrai Postgres, pas un émulateur)
//  2. charge des stubs Supabase (auth, storage, rôles, realtime)
//  3. applique TOUTES les migrations dans l'ordre, puis les ré-applique (contrôle d'idempotence)
//  4. charge seed.sql
//  5. exécute supabase/tests/*.sql avec un shim pgTAP
// Limites : pg_cron et la vraie extension pgTAP ne sont pas disponibles ici (voir docs/SETUP.md).
import EmbeddedPostgres from 'embedded-postgres';
import pg from 'pg';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { checkContract } from './contract.mjs';
import { runScenario } from './scenario.mjs';

const here = path.dirname(fileURLToPath(import.meta.url));
const root = path.resolve(here, '..', '..');
const migrationsDir = path.join(root, 'supabase', 'migrations');
const testsDir = path.join(root, 'supabase', 'tests');
const seedFile = path.join(root, 'supabase', 'seed.sql');
const port = Number(process.env.SAIQI_CHECK_PORT || 54598);
const keep = process.argv.includes('--keep');
const only = process.argv.find((a) => a.startsWith('--only='))?.slice(7);

const dataDir = fs.mkdtempSync(path.join(os.tmpdir(), 'saiqi-pg-'));
const server = new EmbeddedPostgres({
  databaseDir: dataDir, user: 'postgres', password: 'postgres', port, persistent: false,
  initdbFlags: ['--encoding=UTF8', '--locale=C'],
  onLog: () => {}, onError: () => {},
});

const conn = (database) => new pg.Client({ host: 'localhost', port, user: 'postgres', password: 'postgres', database });
let failures = 0;
let dbClient = null;
const fail = (msg) => { failures++; console.log(`  ✗ ${msg}`); };
const pass = (msg) => console.log(`  ✓ ${msg}`);

async function run(client, file, label, opts = {}) {
  let sql = fs.readFileSync(file, 'utf8');
  if (opts.stripPgtap) sql = sql.replace(/^\s*create extension[^;]*pgtap[^;]*;\s*$/gim, '-- (pgtap: shim)');
  try {
    await client.query(sql);
    return true;
  } catch (e) {
    fail(`${label}: ${e.message}${e.position ? ` (pos ${e.position})` : ''}${e.where ? `\n      ${e.where.split('\n')[0]}` : ''}`);
    return false;
  }
}

async function main() {
  console.log('→ démarrage de PostgreSQL embarqué…');
  await server.initialise();
  await server.start();
  const admin = conn('postgres');
  await admin.connect();
  await admin.query("create database saiqi_check encoding 'UTF8' template template0");
  await admin.end();

  const db = conn('saiqi_check');
  dbClient = db;
  db.on('error', () => {});
  await db.connect();
  const notices = [];
  db.on('notice', (n) => { if (n.message?.startsWith('TAP|')) notices.push(n.message); });

  console.log(`→ version : ${(await db.query('select version()')).rows[0].version.split(',')[0]}`);
  console.log('→ stubs Supabase');
  if (!(await run(db, path.join(here, 'stubs.sql'), 'stubs.sql'))) throw new Error('stubs');

  const migrations = fs.readdirSync(migrationsDir).filter((f) => f.endsWith('.sql')).sort();
  console.log(`→ ${migrations.length} migrations`);
  for (const m of migrations) {
    if (await run(db, path.join(migrationsDir, m), m)) pass(m);
  }
  if (failures) throw new Error('migrations');

  console.log('→ contrat Dart ↔ SQL (rpc, tables, colonnes)');
  const checked = await checkContract(db, root, (msg) => fail(msg));
  if (!failures) pass(`${checked} appels vérifiés contre le schéma réel`);

  console.log('→ ré-application des migrations (idempotence)');
  let idem = 0;
  for (const m of migrations) {
    if (!(await run(db, path.join(migrationsDir, m), `[2e passage] ${m}`))) idem++;
  }
  if (!idem) pass('toutes les migrations sont ré-exécutables');

  if (fs.existsSync(seedFile)) {
    console.log('→ seed.sql');
    if (await run(db, seedFile, 'seed.sql')) pass('seed.sql');
    if (failures) throw new Error('seed');

    // Invariants financiers sur les données de seed : solde == somme des transactions, commissions cohérentes
    const bad = await db.query(`
      select w.id, w.balance, coalesce(sum(t.amount), 0)::int as tx_sum
        from public.wallets w left join public.wallet_transactions t on t.wallet_id = w.id
       group by w.id having w.balance <> coalesce(sum(t.amount), 0)`);
    if (bad.rowCount) fail(`invariant wallet violé sur ${bad.rowCount} wallet(s)`); else pass('invariant : solde = somme des transactions (seed)');
    const bad2 = await db.query(`
      select c.booking_id from public.commissions c
        left join public.wallet_transactions t on t.booking_id = c.booking_id and t.type = 'commission'
       where c.amount > 0 and t.id is null`);
    if (bad2.rowCount) fail('commission sans transaction'); else pass('invariant : chaque commission a sa transaction (seed)');
    const st = await db.query(`select status::text, count(*)::int n from public.bookings group by 1 order by 1`);
    console.log('    réservations de seed :', st.rows.map((r) => `${r.status}=${r.n}`).join(', '));
  }

  console.log('→ tests SQL (shim pgTAP)');
  await run(db, path.join(here, 'pgtap_shim.sql'), 'pgtap_shim.sql');
  const files = fs.existsSync(testsDir)
    ? fs.readdirSync(testsDir).filter((f) => f.endsWith('.sql')).sort().filter((f) => !only || f.includes(only))
    : [];
  let total = 0, okCount = 0;
  for (const f of files) {
    notices.length = 0;
    const ok = await run(db, path.join(testsDir, f), f, { stripPgtap: true });
    if (!ok) {
      try { await db.query('rollback'); } catch {}
      try { await db.query('reset role'); } catch {}
    }
    let fileFail = 0;
    for (const msg of notices) {
      const [, status, n, desc, diag] = msg.split('|');
      total++;
      if (status === 'ok') okCount++;
      else { fileFail++; fail(`${f} #${n} ${desc}${diag ? `\n      ${diag}` : ''}`); }
    }
    if (ok && !fileFail) pass(`${f} (${notices.length} assertions)`);
  }
  console.log(`→ assertions : ${okCount}/${total} réussies`);

  console.log('→ scénario d\'intégration (inscription → validation → recharge → course → avis, demande admin, solde insuffisant)');
  try {
    await runScenario(db, (m) => console.log(`    ${m}`));
    pass('scénario complet réussi');
  } catch (e) {
    fail(`scénario : ${e.message}`);
    try { await db.query('reset role'); } catch {}
  }
  await db.end();
  dbClient = null;
}

try {
  await main();
} catch (e) {
  if (!failures) { failures++; console.log(`  ✗ ${e.message}`); }
} finally {
  try { if (dbClient) await dbClient.end(); } catch {}
  try { await server.stop(); } catch {}
  if (!keep) { try { fs.rmSync(dataDir, { recursive: true, force: true }); } catch {} }
}
console.log(failures ? `\n✗ ${failures} échec(s)` : '\n✓ base SAIQI validée');
process.exit(failures ? 1 : 0);
