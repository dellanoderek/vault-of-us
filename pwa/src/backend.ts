import { createClient } from '@supabase/supabase-js';

const url = import.meta.env.VITE_SUPABASE_URL;
const key = import.meta.env.VITE_SUPABASE_ANON_KEY;

export const backendConfigured = Boolean(url && key && !url.includes('YOUR_PROJECT'));
export const supabase = backendConfigured
  ? createClient(url!, key!, {
      auth: { persistSession: true, autoRefreshToken: true, detectSessionInUrl: true },
    })
  : undefined;

export function webPushPublicKey(): string | undefined {
  const value = import.meta.env.VITE_WEB_PUSH_PUBLIC_KEY;
  return value && !value.includes('YOUR_') ? value : undefined;
}
