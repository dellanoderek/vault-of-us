import { createClient } from 'npm:@supabase/supabase-js@2.117.2';

Deno.serve(async (request) => {
  if (request.method !== 'POST') return new Response('Method not allowed', { status: 405 });
  const expected = Deno.env.get('CRON_SHARED_SECRET');
  if (!expected || request.headers.get('Authorization') !== `Bearer ${expected}`) return new Response('Unauthorized', { status: 401 });
  try {
    const admin = createClient(Deno.env.get('SUPABASE_URL')!, Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!);
    const { data: expired, error } = await admin.from('chat_messages').select('id,object_path').lte('expires_at', new Date().toISOString()).limit(500);
    if (error) throw error;
    const paths = (expired ?? []).map((row) => row.object_path).filter((path): path is string => Boolean(path));
    if (paths.length) {
      const { error: removeError } = await admin.storage.from('chat-temp').remove(paths);
      if (removeError) throw removeError;
    }
    const ids = (expired ?? []).map((row) => row.id);
    if (ids.length) {
      const { error: deleteError } = await admin.from('chat_messages').delete().in('id', ids);
      if (deleteError) throw deleteError;
    }
    return Response.json({ removed: ids.length });
  } catch (error) {
    console.error('chat cleanup failed', error);
    return new Response('Cleanup failed', { status: 500 });
  }
});
