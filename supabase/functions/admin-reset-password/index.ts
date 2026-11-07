// Edge Function : réinitialisation du mot de passe d'un utilisateur par un administrateur.
// Appel : POST { "phone": "+22236123456" | "user_id": "<uuid>", "new_password": "…" } avec le JWT de l'admin.
// Rôles autorisés : super_admin et support (support : uniquement clients et chauffeurs).
import {
  corsHeaders, errorResponse, HttpError, json, normalizePhone, requireAdmin, serviceClient,
} from '../_shared/admin.ts';

Deno.serve(async (req: Request) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders });
  if (req.method !== 'POST') return json({ error: 'method_not_allowed' }, 405);

  try {
    const admin = serviceClient();
    const caller = await requireAdmin(req, admin, ['super_admin', 'support']);

    const body = await req.json().catch(() => ({}));
    const newPassword: string = body.new_password ?? '';
    if (typeof newPassword !== 'string' || newPassword.length < 8) {
      throw new HttpError(400, 'password_too_short');
    }

    let query = admin.from('profiles').select('id, role, phone');
    if (body.user_id) {
      query = query.eq('id', body.user_id);
    } else {
      const phone = normalizePhone(body.phone);
      if (!phone) throw new HttpError(400, 'invalid_phone');
      query = query.eq('phone', phone);
    }
    const { data: target, error } = await query.maybeSingle();
    if (error) throw error;
    if (!target) throw new HttpError(404, 'profile_not_found');
    if (target.id === caller.id) throw new HttpError(400, 'cannot_modify_self');
    if (target.role === 'admin' && caller.adminRole !== 'super_admin') {
      throw new HttpError(403, 'admin_forbidden');
    }

    const { error: updateError } = await admin.auth.admin.updateUserById(target.id, { password: newPassword });
    if (updateError) throw updateError;

    await admin.from('audit_logs').insert({
      actor_id: caller.id,
      action: 'reset_password',
      entity: 'profiles',
      entity_id: target.id,
      payload: { phone: target.phone },
    });
    return json({ ok: true });
  } catch (e) {
    return errorResponse(e);
  }
});
