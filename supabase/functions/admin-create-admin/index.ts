// Edge Function : création d'un compte de l'équipe admin (super_admin uniquement).
// Appel : POST { "phone": "+22236123456", "password": "…", "full_name": "…", "admin_role": "validator" }
// Le trigger d'inscription ne crée jamais d'admin : on promeut le profil ici, côté serveur.
import {
  corsHeaders, errorResponse, HttpError, json, normalizePhone, requireAdmin, serviceClient, technicalEmail,
} from '../_shared/admin.ts';

const ROLES = ['super_admin', 'validator', 'support'];

Deno.serve(async (req: Request) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders });
  if (req.method !== 'POST') return json({ error: 'method_not_allowed' }, 405);

  try {
    const admin = serviceClient();
    const caller = await requireAdmin(req, admin, ['super_admin']);

    const body = await req.json().catch(() => ({}));
    const phone = normalizePhone(body.phone);
    if (!phone) throw new HttpError(400, 'invalid_phone');
    const password: string = body.password ?? '';
    if (typeof password !== 'string' || password.length < 8) throw new HttpError(400, 'password_too_short');
    if (!ROLES.includes(body.admin_role)) throw new HttpError(400, 'invalid_admin_role');
    const fullName = typeof body.full_name === 'string' ? body.full_name.trim() : '';
    if (!fullName) throw new HttpError(400, 'name_required');

    const { data: created, error: createError } = await admin.auth.admin.createUser({
      email: technicalEmail(phone),
      password,
      email_confirm: true,
      user_metadata: { phone, full_name: fullName, role: 'client', language: 'ar' },
    });
    if (createError || !created.user) {
      const msg = createError?.message ?? '';
      if (/already|registered|exists/i.test(msg)) throw new HttpError(409, 'phone_already_registered');
      throw new HttpError(400, 'create_user_failed');
    }

    const { error: promoteError } = await admin
      .from('profiles')
      .update({ role: 'admin', admin_role: body.admin_role })
      .eq('id', created.user.id);
    if (promoteError) {
      await admin.auth.admin.deleteUser(created.user.id);
      throw promoteError;
    }

    await admin.from('audit_logs').insert({
      actor_id: caller.id,
      action: 'create_admin',
      entity: 'profiles',
      entity_id: created.user.id,
      payload: { phone, admin_role: body.admin_role },
    });
    return json({ ok: true, id: created.user.id });
  } catch (e) {
    return errorResponse(e);
  }
});
