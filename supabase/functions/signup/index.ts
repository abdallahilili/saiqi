// Inscription publique client/chauffeur via Auth Admin API.
// Contourne le rate-limit GoTrue sur /auth/v1/signup (cause du message « محاولات كثيرة »).
// Déployer avec : npx supabase functions deploy signup --no-verify-jwt
// Body : { phone, password, role: 'client'|'driver', language?: 'ar'|'fr', full_name?: string }
import {
  corsHeaders, errorResponse, HttpError, json, normalizePhone, serviceClient, technicalEmail,
} from '../_shared/admin.ts';

Deno.serve(async (req: Request) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders });
  if (req.method !== 'POST') return json({ error: 'method_not_allowed' }, 405);

  try {
    const admin = serviceClient();
    const body = await req.json().catch(() => ({}));

    const phone = normalizePhone(body.phone);
    if (!phone) throw new HttpError(400, 'invalid_phone');

    const password: string = body.password ?? '';
    if (typeof password !== 'string' || password.length < 8) {
      throw new HttpError(400, 'password_too_short');
    }

    const role = body.role === 'driver' ? 'driver' : body.role === 'client' ? 'client' : null;
    if (!role) throw new HttpError(400, 'permission_denied');

    const language = body.language === 'fr' ? 'fr' : 'ar';
    const fullName = typeof body.full_name === 'string' ? body.full_name.trim() : '';

    const { data: existing } = await admin.from('profiles').select('id').eq('phone', phone).maybeSingle();
    if (existing) throw new HttpError(409, 'phone_already_registered');

    const metadata: Record<string, string> = { phone, role, language };
    if (fullName) metadata.full_name = fullName;

    const { data: created, error: createError } = await admin.auth.admin.createUser({
      email: technicalEmail(phone),
      password,
      email_confirm: true,
      user_metadata: metadata,
    });
    if (createError || !created.user) {
      const msg = createError?.message ?? '';
      if (/already|registered|exists/i.test(msg)) throw new HttpError(409, 'phone_already_registered');
      if (/database error saving new user/i.test(msg)) throw new HttpError(400, 'signup_failed');
      throw new HttpError(400, 'create_user_failed');
    }

    // Vérifie que le trigger a bien créé le profil (sinon rollback Auth).
    const { data: profile } = await admin.from('profiles').select('id').eq('id', created.user.id).maybeSingle();
    if (!profile) {
      await admin.auth.admin.deleteUser(created.user.id);
      throw new HttpError(400, 'signup_failed');
    }

    return json({ ok: true, id: created.user.id });
  } catch (e) {
    return errorResponse(e);
  }
});
