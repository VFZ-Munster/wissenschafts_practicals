-- Classroom polls for the practicals website.
-- Run this once in the Supabase dashboard: SQL Editor -> New query -> paste -> Run.

-- Teachers allowed to control polls (add your login e-mail here).
create table if not exists teachers (
  email text primary key
);
insert into teachers (email) values ('ignacio.leiva@uni-muenster.de')
on conflict do nothing;

-- One row per poll (created automatically on the first vote).
-- "round" increases each time the teacher resets the poll for a new class.
create table if not exists polls (
  id         text primary key,
  round      int not null default 1,
  revealed   boolean not null default false,
  updated_at timestamptz not null default now()
);

-- One anonymous vote per browser, per poll, per round.
create table if not exists votes (
  poll_id    text not null references polls(id) on delete cascade,
  round      int not null,
  voter      uuid not null,
  choice     int not null check (choice between 0 and 19),
  created_at timestamptz not null default now(),
  primary key (poll_id, round, voter)
);

alter table teachers enable row level security;
alter table polls    enable row level security;
alter table votes    enable row level security;

create or replace function is_teacher() returns boolean
language sql stable security definer set search_path = public as $$
  select exists (select 1 from teachers where email = auth.email());
$$;

-- Students never touch votes directly; polls metadata (id, round, revealed) is readable by all.
drop policy if exists "anyone reads polls"   on polls;
drop policy if exists "teacher reads polls"  on polls;
drop policy if exists "teacher writes polls" on polls;
drop policy if exists "teacher reads votes"  on votes;
create policy "anyone reads polls"   on polls for select using (true);
create policy "teacher writes polls" on polls for update using (is_teacher()) with check (is_teacher());
create policy "teacher reads votes"  on votes for select using (is_teacher());

-- Cast or change a vote in the current round.
create or replace function cast_vote(p_poll text, p_voter uuid, p_choice int)
returns int
language plpgsql security definer set search_path = public as $$
declare
  r int;
begin
  insert into polls (id) values (p_poll) on conflict do nothing;
  select round into r from polls where id = p_poll;
  insert into votes (poll_id, round, voter, choice)
  values (p_poll, r, p_voter, p_choice)
  on conflict (poll_id, round, voter)
  do update set choice = excluded.choice, created_at = now();
  return r;
end;
$$;

-- Current state of the given polls.
-- Counts per option are only returned once the poll is revealed (or to a teacher).
-- Total submission count is always returned for every poll matching p_polls, even with 0 votes.
create or replace function poll_results(p_polls text[])
returns table (poll_id text, round int, revealed boolean, choice int, n bigint)
language sql stable security definer set search_path = public as $$
  select p.id, p.round, p.revealed, v.choice, count(v.voter)
  from polls p
  join votes v on v.poll_id = p.id and v.round = p.round
  where p.id = any(p_polls) and (p.revealed or is_teacher())
  group by p.id, p.round, p.revealed, v.choice
  union all
  select p.id, p.round, p.revealed, null, count(v.voter)
  from polls p
  left join votes v on v.poll_id = p.id and v.round = p.round
  where p.id = any(p_polls)
  group by p.id, p.round, p.revealed;
$$;

-- Teacher controls.
create or replace function set_revealed(p_poll text, p_revealed boolean)
returns void
language plpgsql security definer set search_path = public as $$
begin
  if not is_teacher() then raise exception 'not allowed'; end if;
  insert into polls (id) values (p_poll) on conflict do nothing;
  update polls set revealed = p_revealed, updated_at = now() where id = p_poll;
end;
$$;

create or replace function reset_poll(p_poll text)
returns void
language plpgsql security definer set search_path = public as $$
begin
  if not is_teacher() then raise exception 'not allowed'; end if;
  insert into polls (id) values (p_poll) on conflict do nothing;
  update polls set round = round + 1, revealed = false, updated_at = now() where id = p_poll;
end;
$$;

revoke all on function set_revealed(text, boolean), reset_poll(text) from public;
grant execute on function cast_vote(text, uuid, int), poll_results(text[]) to anon, authenticated;
grant execute on function set_revealed(text, boolean), reset_poll(text) to authenticated;
