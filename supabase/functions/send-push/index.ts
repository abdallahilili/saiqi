// Edge Function : envoie une notification push FCM à chaque INSERT dans public.notifications.
// Déclenchement : Database Webhook (Dashboard > Database > Webhooks) sur INSERT de `notifications`,
// avec l'en-tête HTTP  x-webhook-secret: <PUSH_WEBHOOK_SECRET>.
// Secrets requis (supabase secrets set …) :
//   PUSH_WEBHOOK_SECRET        secret partagé avec le webhook
//   FIREBASE_SERVICE_ACCOUNT   JSON complet du compte de service Firebase (FCM HTTP v1)
//   SAIQI_SECRET_KEY           clé secrète du projet (lecture du token FCM)
import { serviceClient } from '../_shared/admin.ts';

interface ServiceAccount {
  project_id: string;
  client_email: string;
  private_key: string;
}

let cachedToken: { value: string; expiresAt: number } | null = null;

function b64url(input: ArrayBuffer | string): string {
  const bytes = typeof input === 'string' ? new TextEncoder().encode(input) : new Uint8Array(input);
  let s = '';
  bytes.forEach((b) => (s += String.fromCharCode(b)));
  return btoa(s).replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/, '');
}

async function accessToken(sa: ServiceAccount): Promise<string> {
  const now = Math.floor(Date.now() / 1000);
  if (cachedToken && cachedToken.expiresAt - 60 > now) return cachedToken.value;

  const header = b64url(JSON.stringify({ alg: 'RS256', typ: 'JWT' }));
  const claim = b64url(JSON.stringify({
    iss: sa.client_email,
    scope: 'https://www.googleapis.com/auth/firebase.messaging',
    aud: 'https://oauth2.googleapis.com/token',
    iat: now,
    exp: now + 3600,
  }));
  const pem = sa.private_key.replace(/-----[^-]+-----/g, '').replace(/\s+/g, '');
  const der = Uint8Array.from(atob(pem), (c) => c.charCodeAt(0));
  const key = await crypto.subtle.importKey(
    'pkcs8', der, { name: 'RSASSA-PKCS1-v1_5', hash: 'SHA-256' }, false, ['sign'],
  );
  const signature = await crypto.subtle.sign('RSASSA-PKCS1-v1_5', key, new TextEncoder().encode(`${header}.${claim}`));
  const assertion = `${header}.${claim}.${b64url(signature)}`;

  const res = await fetch('https://oauth2.googleapis.com/token', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({ grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer', assertion }),
  });
  if (!res.ok) throw new Error(`oauth_failed_${res.status}`);
  const json = await res.json();
  cachedToken = { value: json.access_token, expiresAt: now + (json.expires_in ?? 3600) };
  return cachedToken.value;
}

Deno.serve(async (req: Request) => {
  if (req.method !== 'POST') return new Response('method not allowed', { status: 405 });

  const expected = Deno.env.get('PUSH_WEBHOOK_SECRET');
  if (!expected || req.headers.get('x-webhook-secret') !== expected) {
    return new Response('unauthorized', { status: 401 });
  }

  try {
    const payload = await req.json();
    const record = payload?.record;
    if (payload?.type !== 'INSERT' || !record?.user_id) return Response.json({ skipped: 'not_an_insert' });

    const saRaw = Deno.env.get('FIREBASE_SERVICE_ACCOUNT');
    if (!saRaw) return Response.json({ skipped: 'firebase_not_configured' });
    const sa: ServiceAccount = JSON.parse(saRaw);

    const admin = serviceClient();
    const { data: profile } = await admin.from('profiles').select('fcm_token').eq('id', record.user_id).maybeSingle();
    const token = profile?.fcm_token;
    if (!token) return Response.json({ skipped: 'no_token' });

    // FCM n'accepte que des chaînes dans `data`
    const data: Record<string, string> = { notification_id: String(record.id ?? '') };
    for (const [k, v] of Object.entries(record.data ?? {})) data[k] = typeof v === 'string' ? v : JSON.stringify(v);

    const res = await fetch(`https://fcm.googleapis.com/v1/projects/${sa.project_id}/messages:send`, {
      method: 'POST',
      headers: { Authorization: `Bearer ${await accessToken(sa)}`, 'Content-Type': 'application/json' },
      body: JSON.stringify({
        message: {
          token,
          notification: { title: record.title, body: record.body },
          data,
          android: { priority: 'high', notification: { channel_id: 'saiqi_default' } },
          apns: { payload: { aps: { sound: 'default' } } },
        },
      }),
    });

    if (!res.ok) {
      const err = await res.text();
      // Token périmé : on le supprime pour ne plus réessayer
      if (res.status === 404 || /UNREGISTERED|INVALID_ARGUMENT/.test(err)) {
        await admin.from('profiles').update({ fcm_token: null }).eq('id', record.user_id);
      }
      return Response.json({ sent: false, status: res.status }, { status: 200 });
    }
    return Response.json({ sent: true });
  } catch (e) {
    console.error('send-push failed', e);
    return Response.json({ sent: false, error: 'internal_error' }, { status: 200 });
  }
});
