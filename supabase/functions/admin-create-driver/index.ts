// Edge Function : création d'un compte chauffeur par un admin (super_admin ou validator).
// Appel : POST { "phone": "+222…", "password": "…", "full_name": "…" }
// Statut initial : draft — le chauffeur complète son dossier puis soumet.
import {
  corsHeaders, errorResponse, HttpError, json, normalizePhone, requireAdmin, serviceClient, technicalEmail,
} from '../_shared/admin.ts';

Deno.serve(async (req: Request) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders });
  if (req.method !== 'POST') return json({ error: 'method_not_allowed' }, 405);

  try {
    const admin = serviceClient();
    const caller = await requireAdmin(req, admin, ['super_admin', 'validator']);

    const body = await req.json().catch(() => ({}));
    const phone = normalizePhone(body.phone);
    if (!phone) throw new HttpError(400, 'invalid_phone');
    const password: string = body.password ?? '';
    if (typeof password !== 'string' || password.length < 8) throw new HttpError(400, 'password_too_short');
    const fullName = typeof body.full_name === 'string' ? body.full_name.trim() : '';
    if (!fullName) throw new HttpError(400, 'name_required');

    const { data: created, error: createError } = await admin.auth.admin.createUser({
      email: technicalEmail(phone),
      password,
      email_confirm: true,
      user_metadata: { phone, full_name: fullName, role: 'driver', language: 'ar' },
    });
    if (createError || !created.user) {
      const msg = createError?.message ?? '';
      if (/already|registered|exists/i.test(msg)) throw new HttpError(409, 'phone_already_registered');
      throw new HttpError(400, 'create_user_failed');
    }

    // Le trigger handle_new_user crée déjà profiles + drivers (status draft).
    const { data: driver, error: driverError } = await admin
      .from('drivers')
      .select('id')
      .eq('profile_id', created.user.id)
      .maybeSingle();
    if (driverError || !driver) {
      await admin.auth.admin.deleteUser(created.user.id);
      throw driverError ?? new HttpError(500, 'driver_row_missing');
    }

    await admin.from('audit_logs').insert({
      actor_id: caller.id,
      action: 'create_driver',
      entity: 'drivers',
      entity_id: driver.id,
      payload: { phone, profile_id: created.user.id },
    });
    return json({ ok: true, id: driver.id, profile_id: created.user.id });
  } catch (e) {
    return errorResponse(e);
  }
});
