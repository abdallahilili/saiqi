// Contrôle de contrat Dart <-> SQL : chaque appel `.rpc('fn', params: {...})`, chaque `.from('table')` et chaque
// colonne filtrée (`.eq`, `.order`, `.inFilter`…) des repositories du socle doit exister dans le schéma réel.
import fs from 'node:fs';
import path from 'node:path';

export async function checkContract(db, root, report) {
  const reposDir = path.join(root, 'apps', 'saiqi_driver', 'lib', 'core', 'repositories');
  const files = fs.readdirSync(reposDir).filter((f) => f.endsWith('.dart'));

  // --- schéma réel ---
  const fns = new Map(); // nom -> { args: Set, required: Set }
  const procs = await db.query(`
    select p.proname, p.pronargs, p.pronargdefaults, p.proargnames, p.proargmodes
      from pg_proc p join pg_namespace n on n.oid = p.pronamespace where n.nspname = 'public'`);
  for (const r of procs.rows) {
    const toArray = (v) => (typeof v === 'string' ? v.replace(/[{}]/g, '').split(',').filter(Boolean) : v);
    const names = toArray(r.proargnames) ?? [];
    const modes = toArray(r.proargmodes);
    const inNames = names.filter((_, i) => !modes || modes[i] === 'i' || modes[i] === 'b' || modes[i] === 'v');
    const required = new Set(inNames.slice(0, Math.max(0, inNames.length - r.pronargdefaults)));
    const entry = fns.get(r.proname);
    // plusieurs surcharges possibles : on garde la plus permissive
    if (!entry || inNames.length > entry.args.size) fns.set(r.proname, { args: new Set(inNames), required });
  }
  const rels = new Map(); // table/vue -> Set colonnes
  const cols = await db.query(`
    select table_name, column_name from information_schema.columns where table_schema = 'public'`);
  for (const r of cols.rows) {
    if (!rels.has(r.table_name)) rels.set(r.table_name, new Set());
    rels.get(r.table_name).add(r.column_name);
  }

  let checked = 0;
  for (const f of files) {
    const src = fs.readFileSync(path.join(reposDir, f), 'utf8');

    // rpc('fn', params: { 'p_a': ..., 'p_b': ... })
    for (const m of src.matchAll(/\.rpc\(\s*'([a-z_]+)'(?:\s*,\s*params:\s*\{([\s\S]*?)\}\s*)?\)/g)) {
      checked++;
      const [, name, body = ''] = m;
      const fn = fns.get(name);
      if (!fn) { report(`${f} : rpc('${name}') n'existe pas dans le schéma`); continue; }
      const given = [...body.matchAll(/'(p_[a-z_]+)'\s*:/g)].map((x) => x[1]);
      for (const g of given) if (!fn.args.has(g)) report(`${f} : rpc('${name}') paramètre inconnu « ${g} » (attendu : ${[...fn.args].join(', ')})`);
      for (const req of fn.required) if (!given.includes(req)) report(`${f} : rpc('${name}') paramètre obligatoire manquant « ${req} »`);
    }

    // _db.from('table') ... ; colonnes filtrées dans la même instruction
    for (const m of src.matchAll(/\.from\('([a-z_]+)'\)([\s\S]*?)(?:;|\n\s*\n)/g)) {
      checked++;
      const [, table, chain] = m;
      const colset = rels.get(table);
      if (!colset) { report(`${f} : from('${table}') — table/vue inconnue`); continue; }
      for (const c of chain.matchAll(/\.(?:eq|neq|gte|lte|gt|lt|inFilter|isFilter|order|ilike)\(\s*'([a-z_]+)'/g)) {
        if (!colset.has(c[1])) report(`${f} : ${table}.${c[1]} — colonne inconnue`);
      }
      for (const k of chain.matchAll(/\.(?:insert|update|upsert)\(\s*\{([\s\S]*?)\}\s*[,)]/g)) {
        for (const key of k[1].matchAll(/'([a-z_]+)'\s*:/g)) {
          if (!colset.has(key[1])) report(`${f} : ${table}.${key[1]} — colonne inconnue dans l'écriture`);
        }
      }
    }
    // stream sur une table
    for (const m of src.matchAll(/\.from\('([a-z_]+)'\)\s*\.stream/g)) {
      checked++;
      if (!rels.has(m[1])) report(`${f} : stream('${m[1]}') inconnue`);
    }
  }
  // Contraintes FK référencées comme indices d'embed PostgREST (profiles!<contrainte>)
  const fks = await db.query(`select conname from pg_constraint where contype = 'f' and connamespace = 'public'::regnamespace`);
  const fkNames = new Set(fks.rows.map((r) => r.conname));
  for (const f of files) {
    const src = fs.readFileSync(path.join(reposDir, f), 'utf8');
    for (const m of src.matchAll(/!([a-z_]+_fkey)\b/g)) {
      checked++;
      if (!fkNames.has(m[1])) report(`${f} : indice d'embed « ${m[1]} » — contrainte FK inexistante`);
    }
  }
  return checked;
}
