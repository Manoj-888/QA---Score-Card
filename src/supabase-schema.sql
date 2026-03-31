-- ============================================================
--  ScoreCard App — Run this ONCE in Supabase SQL Editor
--  Dashboard → SQL Editor → New Query → Paste → Run
-- ============================================================

-- 1. Multiple saved forms
create table if not exists sc_forms (
  id          text primary key,
  name        text not null default 'Untitled Form',
  form        jsonb not null default '{}',
  fields      jsonb not null default '[]',
  updated_at  timestamptz default now()
);

-- 2. Submissions linked to a form
create table if not exists sc_submissions (
  id          uuid primary key default gen_random_uuid(),
  form_id     text references sc_forms(id) on delete cascade,
  meta        jsonb not null default '{}',
  answers     jsonb not null default '{}',
  earned      integer not null default 0,
  possible    integer not null default 0,
  pct         integer not null default 0,
  created_at  timestamptz default now()
);

-- 3. Legacy config table (kept for compatibility)
create table if not exists sc_config (
  id          text primary key default 'main',
  form        jsonb not null default '{}',
  fields      jsonb not null default '[]',
  updated_at  timestamptz default now()
);

-- 4. Enable Row Level Security
alter table sc_forms       enable row level security;
alter table sc_submissions enable row level security;
alter table sc_config      enable row level security;

-- 5. Public access policies (no login required)
create policy "Public read sc_forms"        on sc_forms       for select using (true);
create policy "Public insert sc_forms"      on sc_forms       for insert with check (true);
create policy "Public update sc_forms"      on sc_forms       for update using (true);
create policy "Public delete sc_forms"      on sc_forms       for delete using (true);

create policy "Public read sc_submissions"   on sc_submissions for select using (true);
create policy "Public insert sc_submissions" on sc_submissions for insert with check (true);
create policy "Public update sc_submissions" on sc_submissions for update using (true);
create policy "Public delete sc_submissions" on sc_submissions for delete using (true);

create policy "Public all sc_config"        on sc_config      for all using (true) with check (true);

-- 6. Performance indexes
create index if not exists idx_sub_form_id on sc_submissions(form_id);
create index if not exists idx_sub_created on sc_submissions(created_at desc);
