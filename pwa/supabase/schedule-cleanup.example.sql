-- Run once in the Supabase SQL Editor after saving these Vault secrets:
--   vault-of-us-cleanup-url       = https://<project-ref>.supabase.co/functions/v1/cleanup-expired-chat
--   vault-of-us-cleanup-secret    = the same random secret set as CRON_SHARED_SECRET
-- Never commit real project URLs containing credentials or secret values here.

create extension if not exists pg_cron with schema extensions;
create extension if not exists pg_net with schema extensions;

select cron.schedule(
  'vault-of-us-cleanup-expired-chat',
  '* * * * *',
  $$
    select net.http_post(
      url := (select decrypted_secret from vault.decrypted_secrets where name = 'vault-of-us-cleanup-url'),
      headers := jsonb_build_object(
        'Content-Type', 'application/json',
        'Authorization', 'Bearer ' || (select decrypted_secret from vault.decrypted_secrets where name = 'vault-of-us-cleanup-secret')
      ),
      body := '{}'::jsonb,
      timeout_milliseconds := 10000
    );
  $$
);
