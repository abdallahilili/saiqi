#!/usr/bin/env node
// Scénario d'intégration contre un VRAI Supabase (GoTrue + PostgREST + RLS), après `supabase db reset` :
//   SUPABASE_URL=http://127.0.0.1:54321 SUPABASE_PUBLISHABLE_KEY=<anon key de `supabase status`> node scripts/integration-http.mjs
// Utilise les comptes de seed (mot de passe Test1234!) : validateur +22220000002, support +22220000003,
// chauffeur de seed +22222000001. Crée un nouveau chauffeur et un nouveau client à chaque exécution.
// ⚠ À LOCAL UNIQUEMENT : ne pas lancer contre la production (crée des comptes de test).
import assert from 'node:assert/strict';

const url = (process.env.SUPABASE_URL || 'http://127.0.0.1:54321').replace(/\/$/, '');
const key = process.env.SUPABASE_PUBLISHABLE_KEY;
if (!key) {
  console.error('SUPABASE_PUBLISHABLE_KEY requis (voir `supabase status` -> anon key).');
  process.exit(1);
}
if (/supabase\.co/.test(url) && process.env.ALLOW_REMOTE !== '1') {
  console.error('Refus : URL distante détectée. Ce script crée des comptes de test (ALLOW_REMOTE=1 pour forcer).');
  process.exit(1);
}

const email = (phone) => `${phone.replace(/\D/g, '')}@saiqi.app`;
const log = (m) => console.log(m);

async function http(method, path, { token, body, prefer } = {}) {
  const res = await fetch(`${url}${path}`, {
    method,
    headers: {
      apikey: key,
      'Content-Type': 'application/json',
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
      ...(prefer ? { Prefer: prefer } : {}),
    },
    body: body === undefined ? undefined : JSON.stringify(body),
  });
  const text = await res.text();
  const json = text ? JSON.parse(text) : null;
  if (!res.ok) throw Object.assign(new Error(json?.message ?? json?.msg ?? text), { status: res.status, body: json });
  return json;
}
const signIn = async (phone, password = 'Test1234!') => {
  const r = await http('POST', '/auth/v1/token?grant_type=password', { body: { email: email(phone), password } });
  return { token: r.access_token, id: r.user.id };
};
const signUp = async (phone, role, password = 'Test1234!') => {
  // Même chemin que les apps : Edge Function `signup` (Auth Admin) puis login.
  await http('POST', '/functions/v1/signup', { body: { phone, password, role, language: 'fr' } });
  return signIn(phone, password);
};
const rpc = (token, fn, params = {}) => http('POST', `/rest/v1/rpc/${fn}`, { token, body: params });
const rest = (token, method, path, body) => http(method, `/rest/v1/${path}`, { token, body, prefer: 'return=representation' });
const expectError = async (code, fn) => {
  try {
    await fn();
  } catch (e) {
    assert.equal(e.body?.message, code, `attendu « ${code} », reçu « ${e.body?.message ?? e.message} »`);
    return e;
  }
  assert.fail(`erreur « ${code} » attendue`);
};

const rand = () => String(Math.floor(100000 + Math.random() * 899999));
const driverPhone = '+22222' + rand();
const clientPhone = '+22236' + rand();

log('1. Inscription chauffeur + dossier');
const drv = await signUp(driverPhone, 'driver');
const [city] = await rest(drv.token, 'GET', 'cities?name_fr=eq.Nouakchott&select=id');
const [taxi] = await rest(drv.token, 'GET', 'service_types?name_fr=eq.Taxi&select=id');
await rest(drv.token, 'PATCH', `profiles?id=eq.${drv.id}`, { full_name: 'Chauffeur HTTP' });
const [driverRow] = await rest(drv.token, 'PATCH', `drivers?profile_id=eq.${drv.id}`, { city_id: city.id });
await rest(drv.token, 'POST', 'vehicles', { driver_id: driverRow.id, brand: 'Toyota', model: 'Yaris', seats: 4, plate: '1111 HT 00' });
await rest(drv.token, 'POST', 'driver_services', { driver_id: driverRow.id, service_type_id: taxi.id, city_ids: [city.id], price: 1000 });
for (const t of ['id_card', 'driving_license', 'vehicle_registration', 'photo']) {
  await rpc(drv.token, 'save_driver_document', { p_type: t, p_file_path: `${drv.id}/${t}/1.jpg` });
}
await rpc(drv.token, 'submit_driver_application');

log('2. Validation par le validateur de seed');
const validator = await signIn('+22220000002');
await rpc(validator.token, 'admin_review_driver', { p_driver_id: driverRow.id, p_approve: true, p_reason: null });
await rpc(drv.token, 'set_driver_availability', { p_available: true });

log('3. Recharge 300 validée par le support');
const support = await signIn('+22220000003');
const topup = await rpc(drv.token, 'request_topup', { p_amount: 300, p_method: 'bankily', p_reference: 'HTTP-1', p_proof_path: null });
await rpc(support.token, 'admin_review_topup', { p_topup_id: topup.id, p_approve: true, p_note: 'ok' });
const wallet = () => rest(drv.token, 'GET', 'wallets?select=balance').then((r) => r[0].balance);
assert.equal(await wallet(), 300);

log('4. Réservation client -> acceptation (commission 10 % de 1000 = 100)');
const client = await signUp(clientPhone, 'client');
const booking = await rpc(client.token, 'create_booking', {
  p_driver_id: driverRow.id, p_service_type_id: taxi.id, p_city_id: city.id,
  p_pickup_text: 'Aéroport', p_dropoff_text: 'Ksar', p_scheduled_at: new Date(Date.now() + 3600e3).toISOString(), p_passengers: 2, p_notes: null,
});
assert.equal((await rest(drv.token, 'GET', `bookings?id=eq.${booking.id}&select=id`)).length, 0, 'téléphone client protégé avant acceptation');
await expectError('contact_not_available', () => rpc(client.token, 'get_booking_contact', { p_booking_id: booking.id }));
await rpc(drv.token, 'accept_booking', { p_booking_id: booking.id });
assert.equal(await wallet(), 200);
const contact = await rpc(client.token, 'get_booking_contact', { p_booking_id: booking.id });
assert.equal(contact[0]?.phone ?? contact.phone, driverPhone);

log('5. Course + avis');
for (const s of ['en_route', 'in_progress', 'completed']) await rpc(drv.token, 'update_booking_status', { p_booking_id: booking.id, p_new_status: s });
await rpc(client.token, 'submit_review', { p_booking_id: booking.id, p_rating: 5, p_comment: 'Parfait' });

log('6. Demande admin -> 2 chauffeurs, le premier gagne');
const seedDriver = await signIn('+22222000001');
const [seedRow] = await rest(seedDriver.token, 'GET', 'drivers?select=id');
const adminBooking = await rpc(support.token, 'admin_create_booking', {
  p_client_name: 'Client WhatsApp', p_client_phone: '+22237123456', p_service_type_id: taxi.id, p_city_id: city.id,
  p_pickup_text: 'Sebkha', p_dropoff_text: 'Marché', p_scheduled_at: new Date(Date.now() + 7200e3).toISOString(), p_passengers: 1,
  p_notes: null, p_price: 1000, p_channel: 'whatsapp', p_driver_ids: [driverRow.id, seedRow.id],
});
await rpc(drv.token, 'accept_booking', { p_booking_id: adminBooking.id });
await expectError('booking_not_available', () => rpc(seedDriver.token, 'accept_booking', { p_booking_id: adminBooking.id }));
assert.equal(await wallet(), 100);

log('7. Solde 100 < commission 150 : acceptation bloquée');
const costly = await rpc(support.token, 'admin_create_booking', {
  p_client_name: 'Client Mine', p_client_phone: '+22245111222', p_service_type_id: taxi.id, p_city_id: city.id,
  p_pickup_text: 'Mine', p_dropoff_text: null, p_scheduled_at: new Date(Date.now() + 10800e3).toISOString(), p_passengers: 1,
  p_notes: null, p_price: 1500, p_channel: 'phone', p_driver_ids: [driverRow.id],
});
await expectError('insufficient_balance', () => rpc(drv.token, 'accept_booking', { p_booking_id: costly.id }));
assert.equal(await wallet(), 100);

log('8. Écritures interdites côté client (RLS / privilèges)');
await assert.rejects(() => rest(drv.token, 'PATCH', 'wallets', { balance: 999999 }), /permission denied/i);
await assert.rejects(() => rest(client.token, 'PATCH', `profiles?id=eq.${client.id}`, { role: 'admin' }), /permission denied/i);
assert.equal((await rest(client.token, 'GET', 'wallets?select=id')).length, 0);

log('\n✓ Scénario d\'intégration HTTP réussi');
