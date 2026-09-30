create extension if not exists pgcrypto with schema extensions;

create table if not exists public.couples (
  id uuid primary key default gen_random_uuid(),
  member_one uuid not null references auth.users(id) on delete cascade,
  member_two uuid references auth.users(id) on delete cascade,
  created_at timestamptz not null default now(),
  constraint couples_distinct_members check (member_two is null or member_one <> member_two)
);

create unique index if not exists couples_member_one_unique on public.couples(member_one);
create unique index if not exists couples_member_two_unique on public.couples(member_two) where member_two is not null;

create or replace function public.is_couple_member(couple_id_to_check uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (select 1 from public.couples c where c.id = couple_id_to_check and auth.uid() in (c.member_one, c.member_two));
$$;

create table if not exists public.couple_invites (
  token_hash text primary key check (length(token_hash) = 64),
  couple_id uuid not null unique references public.couples(id) on delete cascade,
  inviter_id uuid not null references auth.users(id) on delete cascade,
  expires_at timestamptz not null default (now() + interval '24 hours'),
  created_at timestamptz not null default now()
);

create table if not exists public.device_secrets (
  owner_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  secret_key text not null,
  iv text not null,
  secret_ciphertext text not null,
  updated_at timestamptz not null default now(),
  primary key (owner_id, secret_key)
);

create table if not exists public.chat_messages (
  id uuid primary key default gen_random_uuid(),
  couple_id uuid not null references public.couples(id) on delete cascade,
  sender_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  content_ciphertext text not null,
  content_iv text not null,
  message_type text not null check (message_type in ('text', 'image', 'video', 'audio')),
  object_path text,
  media_type text,
  sent_at timestamptz not null default now(),
  read_at timestamptz,
  expires_at timestamptz not null default (now() + interval '1 hour'),
  constraint chat_media_path_type check (
    (message_type = 'text' and object_path is null and media_type is null)
    or (message_type in ('image', 'video', 'audio') and object_path is not null and media_type is not null)
  )
);

alter table public.chat_messages add column if not exists read_at timestamptz;
alter table public.chat_messages drop constraint if exists chat_messages_message_type_check;
alter table public.chat_messages add constraint chat_messages_message_type_check
  check (message_type in ('text', 'image', 'video', 'audio'));
alter table public.chat_messages drop constraint if exists chat_media_path_type;
alter table public.chat_messages add constraint chat_media_path_type check (
  (message_type = 'text' and object_path is null and media_type is null)
  or (message_type in ('image', 'video', 'audio') and object_path is not null and media_type is not null)
);

create index if not exists chat_messages_couple_sent_idx on public.chat_messages(couple_id, sent_at desc);
create index if not exists chat_messages_expiration_idx on public.chat_messages(expires_at);

create or replace function public.enforce_chat_message_expiration()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.sender_id := auth.uid();
  new.sent_at := now();
  new.read_at := null;
  new.expires_at := now() + interval '1 hour';
  return new;
end;
$$;

drop trigger if exists chat_message_expiration on public.chat_messages;
create trigger chat_message_expiration
before insert on public.chat_messages
for each row execute function public.enforce_chat_message_expiration();

create table if not exists public.push_subscriptions (
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  endpoint text not null,
  subscription jsonb not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  primary key(user_id, endpoint)
);

alter table public.couples enable row level security;
alter table public.couple_invites enable row level security;
alter table public.device_secrets enable row level security;
alter table public.chat_messages enable row level security;
alter table public.push_subscriptions enable row level security;

drop policy if exists "Members can read their couple" on public.couples;
create policy "Members can read their couple" on public.couples for select to authenticated
using (auth.uid() = member_one or auth.uid() = member_two);

drop policy if exists "Members can read their pending invite" on public.couple_invites;
create policy "Members can read their pending invite" on public.couple_invites for select to authenticated
using (inviter_id = auth.uid());

drop policy if exists "Owners manage their wrapped couple key" on public.device_secrets;
create policy "Owners manage their wrapped couple key" on public.device_secrets for all to authenticated
using (owner_id = auth.uid()) with check (owner_id = auth.uid());

drop policy if exists "Couple members read unexpired messages" on public.chat_messages;
create policy "Couple members read unexpired messages" on public.chat_messages for select to authenticated
using (
  expires_at > now() and public.is_couple_member(couple_id)
);

drop policy if exists "Couple members send their own messages" on public.chat_messages;
create policy "Couple members send their own messages" on public.chat_messages for insert to authenticated
with check (
  sender_id = auth.uid() and public.is_couple_member(couple_id)
);

drop policy if exists "Users manage only their push subscriptions" on public.push_subscriptions;
create policy "Users manage only their push subscriptions" on public.push_subscriptions for all to authenticated
using (user_id = auth.uid()) with check (user_id = auth.uid());

create or replace function public.create_partner_invite(invite_token_hash text)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare new_couple_id uuid;
begin
  if auth.uid() is null then raise exception 'authentication required'; end if;
  if length(invite_token_hash) <> 64 or invite_token_hash !~ '^[0-9a-f]+$' then raise exception 'invalid invite'; end if;
  if exists (
    select 1 from public.couples c
    where auth.uid() in (c.member_one, c.member_two)
  ) then raise exception 'user is already paired'; end if;

  delete from public.couple_invites where expires_at <= now();
  delete from public.device_secrets where owner_id = auth.uid() and secret_key in (
    select 'couple:' || c.id::text from public.couples c where c.member_one = auth.uid() and c.member_two is null
  );
  delete from public.couples where member_one = auth.uid() and member_two is null;
  insert into public.couples(member_one) values (auth.uid()) returning id into new_couple_id;
  insert into public.couple_invites(token_hash, couple_id, inviter_id)
  values (invite_token_hash, new_couple_id, auth.uid());
  return new_couple_id;
end;
$$;

create or replace function public.accept_partner_invite(invite_token_hash text)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare invite public.couple_invites%rowtype;
begin
  if auth.uid() is null then raise exception 'authentication required'; end if;
  if length(invite_token_hash) <> 64 or invite_token_hash !~ '^[0-9a-f]+$' then raise exception 'invalid invite'; end if;
  if exists (select 1 from public.couples c where auth.uid() in (c.member_one, c.member_two)) then
    raise exception 'user is already paired';
  end if;

  select * into invite from public.couple_invites i
  where i.token_hash = invite_token_hash and i.expires_at > now()
  for update;
  if not found then raise exception 'invite is invalid or expired'; end if;
  if invite.inviter_id = auth.uid() then raise exception 'cannot accept your own invite'; end if;

  update public.couples set member_two = auth.uid() where id = invite.couple_id and member_two is null;
  if not found then raise exception 'invite has already been used'; end if;
  delete from public.couple_invites where token_hash = invite_token_hash;
  return invite.couple_id;
end;
$$;

revoke all on function public.create_partner_invite(text) from public;
revoke all on function public.accept_partner_invite(text) from public;
grant execute on function public.create_partner_invite(text) to authenticated;
grant execute on function public.accept_partner_invite(text) to authenticated;

create or replace function public.cancel_partner_invite(couple_id_to_cancel uuid)
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  if auth.uid() is null then raise exception 'authentication required'; end if;
  delete from public.couples c
  where c.id = couple_id_to_cancel and c.member_one = auth.uid() and c.member_two is null;
  if not found then raise exception 'pending invite not found'; end if;
  delete from public.device_secrets where owner_id = auth.uid() and secret_key = 'couple:' || couple_id_to_cancel::text;
end;
$$;

revoke all on function public.cancel_partner_invite(uuid) from public;
grant execute on function public.cancel_partner_invite(uuid) to authenticated;

create or replace function public.mark_chat_message_read(message_id_to_mark uuid)
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  if auth.uid() is null then raise exception 'authentication required'; end if;
  update public.chat_messages m set read_at = now()
  from public.couples c
  where m.id = message_id_to_mark and c.id = m.couple_id
    and auth.uid() in (c.member_one, c.member_two)
    and m.sender_id <> auth.uid() and m.read_at is null and m.expires_at > now();
end;
$$;

revoke all on function public.mark_chat_message_read(uuid) from public;
grant execute on function public.mark_chat_message_read(uuid) to authenticated;

grant select on public.couples, public.couple_invites to authenticated;
grant select, insert, update, delete on public.device_secrets, public.push_subscriptions to authenticated;
grant select, insert on public.chat_messages to authenticated;
revoke all on function public.is_couple_member(uuid) from public, anon, authenticated;
grant execute on function public.is_couple_member(uuid) to authenticated;

insert into storage.buckets(id, name, public, file_size_limit, allowed_mime_types)
values ('chat-temp', 'chat-temp', false, 52428800, array['application/octet-stream'])
on conflict (id) do update set public = false, file_size_limit = excluded.file_size_limit,
  allowed_mime_types = excluded.allowed_mime_types;

drop policy if exists "Couple members upload encrypted chat media" on storage.objects;
create policy "Couple members upload encrypted chat media" on storage.objects for insert to authenticated
with check (
  bucket_id = 'chat-temp' and public.is_couple_member(((storage.foldername(name))[1])::uuid)
);

drop policy if exists "Couple members read unexpired encrypted chat media" on storage.objects;
create policy "Couple members read unexpired encrypted chat media" on storage.objects for select to authenticated
using (
  bucket_id = 'chat-temp' and exists (
    select 1 from public.chat_messages m
    where m.object_path = name and m.expires_at > now()
      and public.is_couple_member(m.couple_id)
  )
);

drop policy if exists "Couple members remove orphan uploads" on storage.objects;
create policy "Couple members remove orphan uploads" on storage.objects for delete to authenticated
using (
  bucket_id = 'chat-temp' and public.is_couple_member(((storage.foldername(name))[1])::uuid)
  and not exists (select 1 from public.chat_messages m where m.object_path = name)
);

do $$
begin
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'chat_messages'
  ) then
    alter publication supabase_realtime add table public.chat_messages;
  end if;
end
$$;
