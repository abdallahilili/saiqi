// Utilitaires partagés par les Edge Functions réservées aux admins.
// La clé secrète vient des secrets Supabase (jamais du code) :
//   supabase secrets set SAIQI_SECRET_KEY=<clé secrète du projet>
// (repli : SUPABASE_SERVICE_ROLE_KEY, injecté automatiquement par Supabase si présent)
import { createClient, SupabaseClient } from 'npm:@supabase/supabase-js@2';

export const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
};

export function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  });
}

export class HttpError extends Error {
  constructor(public status: number, public code: string) {
    super(code);
  }
}

export function serviceClient(): SupabaseClient {
  const url = Deno.env.get('SUPABASE_URL');
  const key = Deno.env.get('SAIQI_SECRET_KEY') ?? Deno.env.get('SUPABASE_SERVICE_ROLE_KEY');
  if (!url || !key) throw new HttpError(500, 'server_not_configured');
  return createClient(url, key, { auth: { autoRefreshToken: false, persistSession: false } });
}

export interface Caller {
  id: string;
  adminRole: 'super_admin' | 'validator' | 'support';
}

/** Identifie l'appelant à partir de son JWT puis vérifie en base qu'il est un admin actif. */
export async function requireAdmin(
  req: Request,
  admin: SupabaseClient,
  allowed: Array<Caller['adminRole']>,
): Promise<Caller> {
  const header = req.headers.get('Authorization') ?? '';
  const jwt = header.replace(/^Bearer\s+/i, '').trim();
  if (!jwt) throw new HttpError(401, 'missing_token');

  const { data: userData, error: userError } = await admin.auth.getUser(jwt);
  if (userError || !userData.user) throw new HttpError(401, 'invalid_token');

  const { data: profile, error } = await admin
    .from('profiles')
    .select('id, role, status, admin_role')
    .eq('id', userData.user.id)
    .maybeSingle();
  if (error || !profile) throw new HttpError(403, 'admin_forbidden');
  if (profile.role !== 'admin' || profile.status !== 'active' || !allowed.includes(profile.admin_role)) {
    throw new HttpError(403, 'admin_forbidden');
  }
  return { id: profile.id, adminRole: profile.admin_role };
}

/** Même règle que public.normalize_phone() : +222 + 8 chiffres, sinon null. */
export function normalizePhone(input: string | null | undefined): string | null {
  if (!input) return null;
  let d = input.replace(/\D/g, '');
  if (d.length === 13 && d.startsWith('00222')) d = d.slice(5);
  else if (d.length === 11 && d.startsWith('222')) d = d.slice(3);
  return /^[0-9]{8}$/.test(d) ? `+222${d}` : null;
}

export function technicalEmail(phone: string): string {
  return `${phone.replace(/\D/g, '')}@saiqi.app`;
}

export function errorResponse(e: unknown): Response {
  if (e instanceof HttpError) return json({ error: e.code }, e.status);
  console.error(e);
  return json({ error: 'internal_error' }, 500);
}
