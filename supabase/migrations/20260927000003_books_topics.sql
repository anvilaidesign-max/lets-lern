-- v1.1: five new topics, topic books (chapters with quizzes), chapter progress.

insert into public.topics (code, name, icon, sort_order) values
  ('math',        'Mathematics',             'calculate',            1),
  ('english',     'English',                 'menu_book',            2),
  ('french',      'French',                  'translate',            3),
  ('science',     'Science',                 'science',              4),
  ('tech',        'Technology',              'memory',               5),
  ('engineering', 'Electronics Engineering', 'electrical_services',  6),
  ('medicine',    'Medicine',                'medical_services',     7),
  ('law',         'Law',                     'gavel',                8),
  ('politics',    'Politics',                'account_balance',      9),
  ('economics',   'Economics',               'trending_up',         10),
  ('finance',     'Finance',                 'savings',             11),
  ('business',    'Business & Startups',     'rocket_launch',       12),
  ('relations',   'International Relations', 'public',              13)
on conflict (code) do update set
  name = excluded.name,
  icon = excluded.icon,
  sort_order = excluded.sort_order;

-- ---------------------------------------------------------------------------
-- Topic books
-- ---------------------------------------------------------------------------

create table if not exists public.chapters (
  id uuid primary key,
  topic_code text not null references public.topics(code),
  position int not null,
  title text not null,
  summary text not null default '',
  body text not null,
  key_points jsonb not null default '[]',
  quiz jsonb not null default '[]',
  difficulty smallint not null default 1 check (difficulty between 1 and 3),
  sources jsonb not null default '[]',
  verified boolean not null default false,
  is_active boolean not null default true,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);
create index if not exists chapters_topic_position_idx on public.chapters (topic_code, position);
create index if not exists chapters_updated_at_idx on public.chapters (updated_at);

drop trigger if exists chapters_set_updated_at on public.chapters;
create trigger chapters_set_updated_at
  before update on public.chapters
  for each row execute function public.set_updated_at();

alter table public.chapters enable row level security;
drop policy if exists "chapters: read active" on public.chapters;
create policy "chapters: read active" on public.chapters
  for select to authenticated using (is_active = true);

create table if not exists public.user_chapter_progress (
  user_id uuid references auth.users(id) on delete cascade,
  chapter_id uuid references public.chapters(id) on delete cascade,
  read_at timestamptz,
  best_score int,
  last_score int,
  attempts int not null default 0,
  total_questions int,
  updated_at timestamptz default now(),
  primary key (user_id, chapter_id)
);

drop trigger if exists user_chapter_progress_set_updated_at on public.user_chapter_progress;
create trigger user_chapter_progress_set_updated_at
  before update on public.user_chapter_progress
  for each row execute function public.set_updated_at();

alter table public.user_chapter_progress enable row level security;
drop policy if exists "user_chapter_progress: own" on public.user_chapter_progress;
create policy "user_chapter_progress: own" on public.user_chapter_progress
  for all to authenticated
  using (user_id = (select auth.uid()))
  with check (user_id = (select auth.uid()));

-- Merge rules: earliest read time, best score and most attempts win; the last
-- score is last write. security invoker, so RLS applies.
create or replace function public.sync_chapter_progress(p_rows jsonb)
returns void
language plpgsql
security invoker
set search_path = ''
as $$
begin
  insert into public.user_chapter_progress as cp (
    user_id, chapter_id, read_at, best_score, last_score, attempts, total_questions
  )
  select
    auth.uid(),
    (r ->> 'chapter_id')::uuid,
    (r ->> 'read_at')::timestamptz,
    (r ->> 'best_score')::int,
    (r ->> 'last_score')::int,
    greatest(coalesce((r ->> 'attempts')::int, 0), 0),
    (r ->> 'total_questions')::int
  from jsonb_array_elements(p_rows) as r
  where exists (select 1 from public.chapters c where c.id = (r ->> 'chapter_id')::uuid)
  on conflict (user_id, chapter_id) do update set
    read_at = least(cp.read_at, excluded.read_at),
    best_score = greatest(cp.best_score, excluded.best_score),
    last_score = coalesce(excluded.last_score, cp.last_score),
    attempts = greatest(cp.attempts, excluded.attempts),
    total_questions = coalesce(excluded.total_questions, cp.total_questions);
end;
$$;

revoke execute on function public.sync_chapter_progress(jsonb) from public, anon;
grant execute on function public.sync_chapter_progress(jsonb) to authenticated;

-- ---------------------------------------------------------------------------
-- Essay prompts for the new topics
-- ---------------------------------------------------------------------------

insert into public.essay_prompts (topic_code, prompt) values
  ('tech',        'Is artificial intelligence more likely to create jobs or destroy them in the next ten years? Argue your view.'),
  ('tech',        'Explain how the internet delivers a web page to your phone, as if to a curious friend.'),
  ('tech',        'Should governments regulate social media platforms? Give reasons and examples.'),
  ('engineering', 'Explain why reliable electricity is the foundation of industrial growth, using examples from southern Africa.'),
  ('engineering', 'Describe an engineering problem in your community and how you would solve it.'),
  ('engineering', 'Automation in factories: a threat or an opportunity for workers? Argue your view.'),
  ('medicine',    'What is the most important public health challenge in your country, and how should it be tackled?'),
  ('medicine',    'Should everyone learn basic first aid? Give reasons and examples.'),
  ('medicine',    'Explain how vaccines protect not only individuals but whole communities.'),
  ('law',         'Why does the rule of law matter for ordinary citizens? Use examples.'),
  ('law',         'Should every young adult understand how a contract works? Explain why.'),
  ('law',         'Describe the balance between freedom of expression and protecting people from harm.'),
  ('business',    'What makes a startup succeed? Use at least one real example.'),
  ('business',    'Explain how venture capital works and whether it is good for African startups.'),
  ('business',    'Describe a business you would start in your community and how it would make money.')
on conflict (prompt) do nothing;
