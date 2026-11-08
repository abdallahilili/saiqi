// Scénario d'intégration de bout en bout, joué sur la vraie base (PostgreSQL embarqué) avec les MÊMES fonctions
// que les apps appellent (RPC SECURITY DEFINER + RLS), en changeant d'identité comme le fait PostgREST
// (rôle `authenticated` + claims JWT). Voir docs/INTEGRATION.md.
import assert from 'node:assert/strict';

export async function runScenario(db, say) {
  const uid = () => crypto.randomUUID();
  const q = (sql, params) => db.query(sql, params);
  const one = async (sql, params) => (await q(sql, params)).rows[0];

  /** Exécute `fn` comme l'utilisateur `userId` (rôle authenticated + claims), puis revient au rôle serveur. */
  async function as(userId, fn) {
    await q(`select set_config('request.jwt.claims', $1, false)`, [JSON.stringify({ sub: userId, role: 'authenticated' })]);
    await q('set role authenticated');
    try {
      return await fn();
    } finally {
      await q('reset role');
      await q(`select set_config('request.jwt.claims', '', false)`);
    }
  }
  const expectError = async (code, fn) => {
    try {
      await fn();
    } catch (e) {
      assert.equal(e.message, code, `erreur attendue « ${code} », reçue « ${e.message} »`);
      return e;
    }
    assert.fail(`l'erreur « ${code} » était attendue`);
  };
  const balanceOf = async (driverId) => (await one('select balance from public.wallets where driver_id = $1', [driverId])).balance;

  const nkc = (await one(`select id from public.cities where name_fr = 'Nouakchott'`)).id;
  const taxi = (await one(`select id from public.service_types where name_fr = 'Taxi'`)).id;
  const validator = (await one(`select id from public.profiles where phone = '+22220000002'`)).id;
  const support = (await one(`select id from public.profiles where phone = '+22220000003'`)).id;
  const seedDriver = await one(`select d.id, d.profile_id from public.drivers d join public.profiles p on p.id = d.profile_id where p.phone = '+22222000001'`);

  // ───────────── 1. Inscription chauffeur (comme GoTrue : insertion dans auth.users) ─────────────
  say('1. Inscription d\'un chauffeur (téléphone + mot de passe → profil + dossier en brouillon)');
  const driverUser = uid();
  const phone = '+22222' + String(Math.floor(100000 + Math.random() * 899999));
  await q(
    `insert into auth.users (instance_id, id, aud, role, email, raw_user_meta_data)
     values ('00000000-0000-0000-0000-000000000000', $1, 'authenticated', 'authenticated', $2, $3)`,
    [driverUser, phone.replace('+', '') + '@saiqi.app', JSON.stringify({ phone, role: 'driver', language: 'fr' })],
  );
  let driver = await one('select * from public.drivers where profile_id = $1', [driverUser]);
  assert.equal(driver.status, 'draft');
  assert.equal((await q('select 1 from public.wallets where driver_id = $1', [driver.id])).rowCount, 0, 'pas de wallet avant validation');

  say('   dossier : infos, véhicule, service, documents, soumission');
  await as(driverUser, async () => {
    await q(`update public.profiles set full_name = 'Chauffeur Scénario' where id = $1`, [driverUser]);
    await q('update public.drivers set city_id = $1, years_experience = 4 where profile_id = $2', [nkc, driverUser]);
    await q(`insert into public.vehicles (driver_id, vehicle_type, brand, model, year, seats, plate) values ($1, 'sedan', 'Toyota', 'Camry', 2019, 4, '4545 SC 00')`, [driver.id]);
    await q(`insert into public.driver_services (driver_id, service_type_id, city_ids, price, price_unit) values ($1, $2, array[$3::uuid], 1000, 'per_trip')`, [driver.id, taxi, nkc]);
    for (const type of ['id_card', 'driving_license', 'vehicle_registration', 'photo']) {
      await q('select public.save_driver_document($1::public.document_type, $2)', [type, `${driverUser}/${type}/1.jpg`]);
    }
    await q('select public.submit_driver_application()');
  });
  driver = await one('select * from public.drivers where profile_id = $1', [driverUser]);
  assert.equal(driver.status, 'pending');

  // ───────────── 2. Validation admin ─────────────
  say('2. Validation par un admin (validator) → wallet créé à 0');
  await as(validator, () => q('select public.admin_review_driver($1, true, null)', [driver.id]));
  assert.equal((await one('select status from public.drivers where id = $1', [driver.id])).status, 'approved');
  assert.equal(await balanceOf(driver.id), 0);
  await as(driverUser, () => q('select public.set_driver_availability(true)'));

  // ───────────── 3. Recharge 300 ─────────────
  say('3. Recharge : le chauffeur envoie 300 MRU, le support valide → solde 300');
  const topup = await as(driverUser, async () => one(`select (public.request_topup(300, 'bankily', 'BK-SCEN', null)).id as id`));
  assert.equal(await balanceOf(driver.id), 0, 'le solde ne bouge pas avant validation');
  await as(support, () => q(`select public.admin_review_topup($1, true, 'reçu OK')`, [topup.id]));
  assert.equal(await balanceOf(driver.id), 300);

  // ───────────── 4. Réservation client → acceptation (commission 10 %) ─────────────
  say('4. Réservation d\'un client (1000 MRU, commission 10 %) → acceptation : commission 100 déduite');
  const clientUser = uid();
  await q(
    `insert into auth.users (instance_id, id, aud, role, email, raw_user_meta_data)
     values ('00000000-0000-0000-0000-000000000000', $1, 'authenticated', 'authenticated', $2, $3)`,
    [clientUser, 'c' + clientUser.slice(0, 8) + '@saiqi.app', JSON.stringify({ phone: '+22236' + String(Math.floor(100000 + Math.random() * 899999)), role: 'client', full_name: 'Client Scénario' })],
  );
  const booking = await as(clientUser, () =>
    one(`select (public.create_booking($1, $2, $3, 'Aéroport', 'Tevragh Zeina', now() + interval '1 hour', 2, null)).id as id`, [driver.id, taxi, nkc]),
  );
  await expectError('contact_not_available', () => as(clientUser, () => q('select * from public.get_booking_contact($1)', [booking.id])));
  assert.equal((await as(driverUser, () => q('select 1 from public.bookings where id = $1', [booking.id]))).rowCount, 0, 'téléphone client protégé avant acceptation');
  await as(driverUser, () => q('select public.accept_booking($1)', [booking.id]));
  assert.equal(await balanceOf(driver.id), 200, 'solde 300 − commission 100');
  const contact = await as(clientUser, () => one('select * from public.get_booking_contact($1)', [booking.id]));
  assert.equal(contact.phone, phone, 'après acceptation le client voit le téléphone du chauffeur');

  say('5. Déroulement : en route → en cours → terminée, puis évaluation 5★');
  await as(driverUser, async () => {
    for (const s of ['en_route', 'in_progress', 'completed']) await q('select public.update_booking_status($1, $2::public.booking_status)', [booking.id, s]);
  });
  await as(clientUser, () => q(`select public.submit_review($1, 5, 'Excellent')`, [booking.id]));
  driver = await one('select * from public.drivers where id = $1', [driver.id]);
  assert.equal(Number(driver.rating_avg), 5);
  assert.equal(driver.completed_count, 1);

  // ───────────── 6. Demande créée par l'admin, envoyée à 2 chauffeurs ─────────────
  say('6. Demande créée par l\'admin pour un client hors application → 2 chauffeurs : le premier qui accepte l\'obtient');
  const adminBooking = await as(support, () =>
    one(
      `select (public.admin_create_booking('Client WhatsApp', '+22237123456', $1, $2, 'Sebkha', 'Marché Capitale', now() + interval '2 hours', 1, null, 1000, 'whatsapp', $3::uuid[])).id as id`,
      [taxi, nkc, [driver.id, seedDriver.id]],
    ),
  );
  const seedBefore = await balanceOf(seedDriver.id);
  await as(driverUser, () => q('select public.accept_booking($1)', [adminBooking.id]));
  assert.equal(await balanceOf(driver.id), 100, 'solde 200 − 100');
  await expectError('booking_not_available', () => as(seedDriver.profile_id, () => q('select public.accept_booking($1)', [adminBooking.id])));
  assert.equal(await balanceOf(seedDriver.id), seedBefore, 'le perdant n\'est pas débité');
  const winner = await one('select driver_id from public.bookings where id = $1', [adminBooking.id]);
  assert.equal(winner.driver_id, driver.id);

  // ───────────── 7. Solde insuffisant : acceptation bloquée ─────────────
  say('7. Solde 100 < commission 150 : acceptation bloquée, puis recharge → acceptation possible');
  const costly = await as(support, () =>
    one(
      `select (public.admin_create_booking('Client Mine', '+22245111222', $1, $2, 'Mine', 'Ville', now() + interval '3 hours', 1, null, 1500, 'phone', $3::uuid[])).id as id`,
      [taxi, nkc, [driver.id]],
    ),
  );
  const err = await expectError('insufficient_balance', () => as(driverUser, () => q('select public.accept_booking($1)', [costly.id])));
  assert.match(err.detail ?? '', /required=150;balance=100/);
  assert.equal(await balanceOf(driver.id), 100, 'rien n\'a été débité');
  const topup2 = await as(driverUser, () => one(`select (public.request_topup(300, 'masrvi', 'BK-2', null)).id as id`));
  await as(support, () => q(`select public.admin_review_topup($1, true, null)`, [topup2.id]));
  await as(driverUser, () => q('select public.accept_booking($1)', [costly.id]));
  assert.equal(await balanceOf(driver.id), 250, '100 + 300 − 150');

  // ───────────── 8. Annulation : commission restituée ─────────────
  say('8. Annulation par le chauffeur : commission restituée');
  await as(driverUser, () => q(`select public.cancel_booking($1, 'imprévu')`, [costly.id]));
  assert.equal(await balanceOf(driver.id), 400, '250 + 150 restitués');

  // ───────────── Invariant final ─────────────
  const inv = await one(
    `select w.balance, coalesce(sum(t.amount), 0)::int as total from public.wallets w
       left join public.wallet_transactions t on t.wallet_id = w.id where w.driver_id = $1 group by w.balance`,
    [driver.id],
  );
  assert.equal(inv.balance, inv.total, 'invariant : solde = somme des transactions');
  say(`   ✔ invariant wallet : solde ${inv.balance} MRU = somme des ${(await one('select count(*)::int n from public.wallet_transactions t join public.wallets w on w.id=t.wallet_id where w.driver_id=$1', [driver.id])).n} transactions`);
}
