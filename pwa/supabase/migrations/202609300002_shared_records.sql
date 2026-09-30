create table if not exists public.couple_records (
  couple_id uuid not null references public.couples(id) on delete cascade,
  record_id text not null check (length(record_id) <= 100 and (record_id like 'memory:%' or record_id like 'together:%')),
  content_ciphertext text not null,
  content_iv text not null check (length(content_iv) <= 32),
  updated_at timestamptz not null default now(),
  primary key (couple_id, record_id)
);

create index if not exists couple_records_updated_idx on public.couple_records(couple_id, updated_at desc);

create or replace function public.touch_couple_record()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.updated_at := now();
  return new;
end;
$$;

drop trigger if exists couple_record_updated_at on public.couple_records;
create trigger couple_record_updated_at
before update on public.couple_records
for each row execute function public.touch_couple_record();

alter table public.couple_records enable row level security;

drop policy if exists "Couple members read encrypted shared records" on public.couple_records;
create policy "Couple members read encrypted shared records" on public.couple_records
for select to authenticated using (public.is_couple_member(couple_id));

drop policy if exists "Couple members create encrypted shared records" on public.couple_records;
create policy "Couple members create encrypted shared records" on public.couple_records
for insert to authenticated with check (public.is_couple_member(couple_id));

drop policy if exists "Couple members update encrypted shared records" on public.couple_records;
create policy "Couple members update encrypted shared records" on public.couple_records
for update to authenticated using (public.is_couple_member(couple_id))
with check (public.is_couple_member(couple_id));

grant select, insert, update on public.couple_records to authenticated;
revoke delete on public.couple_records from anon, authenticated;

do $$
begin
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'couple_records'
  ) then
    alter publication supabase_realtime add table public.couple_records;
  end if;
end
$$;
