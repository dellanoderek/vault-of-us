import { createClient } from 'npm:@supabase/supabase-js@2.117.2';
import webpush from 'npm:web-push@3.6.7';

const cors = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
};

Deno.serve(async (request) => {
  if (request.method === 'OPTIONS') return new Response('ok', { headers: cors });
  try {
    const authorization = request.headers.get('Authorization');
    if (!authorization) return new Response('Unauthorized', { status: 401, headers: cors });
    const url = Deno.env.get('SUPABASE_URL')!;
    const anon = Deno.env.get('SUPABASE_ANON_KEY')!;
    const serviceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
    const userClient = createClient(url, anon, { global: { headers: { Authorization: authorization } } });
    const { data: auth, error: authError } = await userClient.auth.getUser();
    if (authError || !auth.user) return new Response('Unauthorized', { status: 401, headers: cors });
    const { message_id } = await request.json();
    if (typeof message_id !== 'string') return new Response('Bad request', { status: 400, headers: cors });
    const admin = createClient(url, serviceKey);
    const { data: message, error: messageError } = await admin.from('chat_messages').select('id,couple_id,sender_id,expires_at').eq('id', message_id).maybeSingle();
    if (messageError || !message || message.sender_id !== auth.user.id || Date.parse(message.expires_at) <= Date.now()) {
      return new Response('Message unavailable', { status: 404, headers: cors });
    }
    const { data: couple, error: coupleError } = await admin.from('couples').select('member_one,member_two').eq('id', message.couple_id).single();
    if (coupleError || !couple || ![couple.member_one, couple.member_two].includes(auth.user.id)) return new Response('Forbidden', { status: 403, headers: cors });
    const recipientId = couple.member_one === auth.user.id ? couple.member_two : couple.member_one;
    if (!recipientId) return new Response('No recipient', { status: 409, headers: cors });
    const { data: subscriptions } = await admin.from('push_subscriptions').select('endpoint,subscription').eq('user_id', recipientId);
    const publicKey = Deno.env.get('VAPID_PUBLIC_KEY');
    const privateKey = Deno.env.get('VAPID_PRIVATE_KEY');
    const subject = Deno.env.get('VAPID_SUBJECT');
    if (!publicKey || !privateKey || !subject) return new Response('Push is not configured', { status: 503, headers: cors });
    webpush.setVapidDetails(subject, publicKey, privateKey);
    await Promise.all((subscriptions ?? []).map(async (row) => {
      try {
        await webpush.sendNotification(row.subscription, JSON.stringify({ title: 'Vault of Us', body: 'Você recebeu uma mensagem.', url: '/#chat' }), { TTL: 3600 });
      } catch (error) {
        const status = (error as { statusCode?: number }).statusCode;
        if (status === 404 || status === 410) await admin.from('push_subscriptions').delete().eq('user_id', recipientId).eq('endpoint', row.endpoint);
      }
    }));
    return new Response(JSON.stringify({ ok: true }), { headers: { ...cors, 'Content-Type': 'application/json' } });
  } catch (error) {
    console.error('push delivery failed', error);
    return new Response('Push delivery failed', { status: 500, headers: cors });
  }
});
