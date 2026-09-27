-- Daily Mind: initial schema (ARCHITECTURE.md sections 5.1 to 5.3)

-- ---------------------------------------------------------------------------
-- Tables
-- ---------------------------------------------------------------------------

create table if not exists public.topics (
  code text primary key,
  name text not null,
  icon text not null,
  sort_order int not null
);

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text,
  created_at timestamptz default now()
);

create table if not exists public.content_items (
  id uuid primary key default gen_random_uuid(),
  topic_code text not null references public.topics(code),
  type text not null check (type in ('fact','lesson','challenge','vocab','phrase')),
  title text not null,
  body text not null,
  statement text,
  is_true boolean,
  correct_answer text,
  explanation text,
  term text,
  translation text,
  example_sentence text,
  difficulty smallint not null default 1 check (difficulty between 1 and 3),
  source_name text,
  source_url text,
  verified boolean not null default false,
  in_offline_pack boolean not null default false,
  is_active boolean not null default true,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);
create index if not exists content_items_topic_code_idx on public.content_items (topic_code);
create index if not exists content_items_updated_at_idx on public.content_items (updated_at);
create index if not exists content_items_updated_at_id_idx on public.content_items (updated_at, id);

create table if not exists public.user_progress (
  user_id uuid references auth.users(id) on delete cascade,
  item_id uuid references public.content_items(id) on delete cascade,
  seen_count int not null default 0,
  answered_correct int not null default 0,
  answered_wrong int not null default 0,
  last_seen_at timestamptz,
  saved boolean not null default false,
  -- Client time of the last change to `saved`, used for last-write-wins
  -- (section 7.3). `updated_at` is always server time because of the trigger.
  saved_updated_at timestamptz not null default 'epoch',
  updated_at timestamptz default now(),
  primary key (user_id, item_id)
);

create table if not exists public.daily_activity (
  user_id uuid references auth.users(id) on delete cascade,
  day date not null,
  topics text[] not null,
  items_completed int not null default 0,
  primary key (user_id, day)
);

create table if not exists public.essays (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade,
  prompt text not null,
  image_path text not null,
  extracted_text text,
  score_total smallint,
  score_breakdown jsonb,
  feedback jsonb,
  status text not null default 'pending' check (status in ('pending','done','failed')),
  error_message text,
  created_at timestamptz default now()
);
create index if not exists essays_user_id_idx on public.essays (user_id, created_at desc);

create table if not exists public.ai_game_sessions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade,
  topic_code text references public.topics(code),
  mode text not null check (mode in ('teach','quiz','true_false')),
  messages jsonb not null default '[]',
  score int not null default 0,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);
create index if not exists ai_game_sessions_user_id_idx on public.ai_game_sessions (user_id);

create table if not exists public.ai_usage (
  user_id uuid references auth.users(id) on delete cascade,
  day date not null,
  essay_calls int not null default 0,
  game_calls int not null default 0,
  primary key (user_id, day)
);

create table if not exists public.essay_prompts (
  id uuid primary key default gen_random_uuid(),
  topic_code text references public.topics(code),
  prompt text not null unique,
  is_active boolean not null default true
);

create table if not exists public.content_reports (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade,
  item_id uuid references public.content_items(id) on delete cascade,
  reason text,
  created_at timestamptz default now()
);

-- ---------------------------------------------------------------------------
-- updated_at trigger (section 5.3)
-- ---------------------------------------------------------------------------

create or replace function public.set_updated_at()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists content_items_set_updated_at on public.content_items;
create trigger content_items_set_updated_at
  before update on public.content_items
  for each row execute function public.set_updated_at();

drop trigger if exists user_progress_set_updated_at on public.user_progress;
create trigger user_progress_set_updated_at
  before update on public.user_progress
  for each row execute function public.set_updated_at();

drop trigger if exists ai_game_sessions_set_updated_at on public.ai_game_sessions;
create trigger ai_game_sessions_set_updated_at
  before update on public.ai_game_sessions
  for each row execute function public.set_updated_at();

-- Create a profile row for every new auth user.
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.profiles (id, display_name)
  values (
    new.id,
    coalesce(new.raw_user_meta_data ->> 'full_name', new.raw_user_meta_data ->> 'name')
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ---------------------------------------------------------------------------
-- Row Level Security (section 5.2)
-- ---------------------------------------------------------------------------

alter table public.topics enable row level security;
alter table public.profiles enable row level security;
alter table public.content_items enable row level security;
alter table public.user_progress enable row level security;
alter table public.daily_activity enable row level security;
alter table public.essays enable row level security;
alter table public.ai_game_sessions enable row level security;
alter table public.ai_usage enable row level security;
alter table public.essay_prompts enable row level security;
alter table public.content_reports enable row level security;

-- Read-only reference data. Only the service role (content pipeline) writes.
drop policy if exists "topics: read" on public.topics;
create policy "topics: read" on public.topics
  for select to authenticated using (true);

drop policy if exists "content_items: read active" on public.content_items;
create policy "content_items: read active" on public.content_items
  for select to authenticated using (is_active = true);

drop policy if exists "essay_prompts: read active" on public.essay_prompts;
create policy "essay_prompts: read active" on public.essay_prompts
  for select to authenticated using (is_active = true);

-- Own rows only.
drop policy if exists "profiles: own" on public.profiles;
create policy "profiles: own" on public.profiles
  for all to authenticated
  using (id = (select auth.uid()))
  with check (id = (select auth.uid()));

drop policy if exists "user_progress: own" on public.user_progress;
create policy "user_progress: own" on public.user_progress
  for all to authenticated
  using (user_id = (select auth.uid()))
  with check (user_id = (select auth.uid()));

drop policy if exists "daily_activity: own" on public.daily_activity;
create policy "daily_activity: own" on public.daily_activity
  for all to authenticated
  using (user_id = (select auth.uid()))
  with check (user_id = (select auth.uid()));

drop policy if exists "essays: own" on public.essays;
create policy "essays: own" on public.essays
  for all to authenticated
  using (user_id = (select auth.uid()))
  with check (user_id = (select auth.uid()));

drop policy if exists "ai_game_sessions: own" on public.ai_game_sessions;
create policy "ai_game_sessions: own" on public.ai_game_sessions
  for all to authenticated
  using (user_id = (select auth.uid()))
  with check (user_id = (select auth.uid()));

-- ai_usage is read-only for users. Counters are only changed by
-- increment_ai_usage() from Edge Functions, so users cannot reset their limit.
drop policy if exists "ai_usage: read own" on public.ai_usage;
create policy "ai_usage: read own" on public.ai_usage
  for select to authenticated using (user_id = (select auth.uid()));

drop policy if exists "content_reports: insert own" on public.content_reports;
create policy "content_reports: insert own" on public.content_reports
  for insert to authenticated with check (user_id = (select auth.uid()));

drop policy if exists "content_reports: read own" on public.content_reports;
create policy "content_reports: read own" on public.content_reports
  for select to authenticated using (user_id = (select auth.uid()));

-- ---------------------------------------------------------------------------
-- Sync functions (section 7.3 conflict rules), called by the app via RPC.
-- security invoker: RLS still applies, and user_id always comes from the JWT.
-- ---------------------------------------------------------------------------

create or replace function public.sync_user_progress(p_rows jsonb)
returns void
language plpgsql
security invoker
set search_path = ''
as $$
begin
  insert into public.user_progress as up (
    user_id, item_id, seen_count, answered_correct, answered_wrong,
    last_seen_at, saved, saved_updated_at
  )
  select
    auth.uid(),
    (r ->> 'item_id')::uuid,
    greatest(coalesce((r ->> 'seen_count')::int, 0), 0),
    greatest(coalesce((r ->> 'answered_correct')::int, 0), 0),
    greatest(coalesce((r ->> 'answered_wrong')::int, 0), 0),
    (r ->> 'last_seen_at')::timestamptz,
    coalesce((r ->> 'saved')::boolean, false),
    coalesce((r ->> 'saved_updated_at')::timestamptz, 'epoch')
  from jsonb_array_elements(p_rows) as r
  -- Skip items the server does not know (yet), instead of failing the batch.
  where exists (
    select 1 from public.content_items ci where ci.id = (r ->> 'item_id')::uuid
  )
  on conflict (user_id, item_id) do update set
    seen_count = greatest(up.seen_count, excluded.seen_count),
    answered_correct = greatest(up.answered_correct, excluded.answered_correct),
    answered_wrong = greatest(up.answered_wrong, excluded.answered_wrong),
    last_seen_at = greatest(up.last_seen_at, excluded.last_seen_at),
    saved = case
      when excluded.saved_updated_at > up.saved_updated_at then excluded.saved
      else up.saved
    end,
    saved_updated_at = greatest(up.saved_updated_at, excluded.saved_updated_at);
end;
$$;

create or replace function public.sync_daily_activity(p_rows jsonb)
returns void
language plpgsql
security invoker
set search_path = ''
as $$
begin
  insert into public.daily_activity as da (user_id, day, topics, items_completed)
  select
    auth.uid(),
    (r ->> 'day')::date,
    coalesce(
      array(select jsonb_array_elements_text(r -> 'topics')),
      '{}'::text[]
    ),
    greatest(coalesce((r ->> 'items_completed')::int, 0), 0)
  from jsonb_array_elements(p_rows) as r
  on conflict (user_id, day) do update set
    topics = excluded.topics,
    items_completed = greatest(da.items_completed, excluded.items_completed);
end;
$$;

revoke execute on function public.sync_user_progress(jsonb) from public, anon;
revoke execute on function public.sync_daily_activity(jsonb) from public, anon;
grant execute on function public.sync_user_progress(jsonb) to authenticated;
grant execute on function public.sync_daily_activity(jsonb) to authenticated;

-- ---------------------------------------------------------------------------
-- AI rate limiting (section 9.1). Atomic check-and-increment.
-- Returns true when the call is allowed. Only Edge Functions (service role)
-- may call it.
-- ---------------------------------------------------------------------------

create or replace function public.increment_ai_usage(
  p_user_id uuid,
  p_kind text,
  p_limit int
)
returns boolean
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_updated int;
begin
  if p_kind not in ('essay', 'game') then
    raise exception 'unknown ai usage kind: %', p_kind;
  end if;

  insert into public.ai_usage (user_id, day)
  values (p_user_id, (now() at time zone 'utc')::date)
  on conflict (user_id, day) do nothing;

  if p_kind = 'essay' then
    update public.ai_usage
       set essay_calls = essay_calls + 1
     where user_id = p_user_id
       and day = (now() at time zone 'utc')::date
       and essay_calls < p_limit;
  else
    update public.ai_usage
       set game_calls = game_calls + 1
     where user_id = p_user_id
       and day = (now() at time zone 'utc')::date
       and game_calls < p_limit;
  end if;

  get diagnostics v_updated = row_count;
  return v_updated > 0;
end;
$$;

revoke execute on function public.increment_ai_usage(uuid, text, int) from public, anon, authenticated;
grant execute on function public.increment_ai_usage(uuid, text, int) to service_role;

-- ---------------------------------------------------------------------------
-- Content updates with keyset pagination on (updated_at, id), used by the
-- get-content-updates Edge Function. Returns inactive rows too, so the app can
-- remove content that was withdrawn.
-- ---------------------------------------------------------------------------

create or replace function public.content_updates(
  p_since timestamptz,
  p_after_id uuid,
  p_limit int
)
returns setof public.content_items
language sql
stable
security definer
set search_path = ''
as $$
  select *
    from public.content_items ci
   where (ci.updated_at, ci.id) > (p_since, p_after_id)
   order by ci.updated_at, ci.id
   limit least(greatest(p_limit, 1), 1000);
$$;

revoke execute on function public.content_updates(timestamptz, uuid, int) from public, anon, authenticated;
grant execute on function public.content_updates(timestamptz, uuid, int) to service_role;

-- ---------------------------------------------------------------------------
-- Storage: private bucket for essay photos, path {user_id}/{essay_id}.jpg
-- ---------------------------------------------------------------------------

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('essays', 'essays', false, 10485760, array['image/jpeg'])
on conflict (id) do nothing;

drop policy if exists "essays bucket: read own" on storage.objects;
create policy "essays bucket: read own" on storage.objects
  for select to authenticated
  using (bucket_id = 'essays' and (storage.foldername(name))[1] = (select auth.uid())::text);

drop policy if exists "essays bucket: upload own" on storage.objects;
create policy "essays bucket: upload own" on storage.objects
  for insert to authenticated
  with check (bucket_id = 'essays' and (storage.foldername(name))[1] = (select auth.uid())::text);

drop policy if exists "essays bucket: update own" on storage.objects;
create policy "essays bucket: update own" on storage.objects
  for update to authenticated
  using (bucket_id = 'essays' and (storage.foldername(name))[1] = (select auth.uid())::text)
  with check (bucket_id = 'essays' and (storage.foldername(name))[1] = (select auth.uid())::text);

drop policy if exists "essays bucket: delete own" on storage.objects;
create policy "essays bucket: delete own" on storage.objects
  for delete to authenticated
  using (bucket_id = 'essays' and (storage.foldername(name))[1] = (select auth.uid())::text);
