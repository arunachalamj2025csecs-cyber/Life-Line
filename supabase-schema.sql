-- LifeLine Triage System - Supabase schema
-- ONE schema file for both NEW and EXISTING LifeLine databases.
-- Run this in Supabase Dashboard -> SQL Editor.
-- It is idempotent: it does not drop patient tables or patient rows.
--
-- IMPORTANT:
-- This is a hackathon/demo browser architecture using the Supabase anon/publishable key.
-- Do NOT use these open demo policies for real healthcare data.

-- ============================================================
-- 1) PATIENTS TABLE
-- ============================================================
create table if not exists public.patients (
  patient_id text primary key,
  patient_name text not null,
  age integer,
  gender text,
  language text,
  chief_complaint text not null,
  duration_days integer,
  symptoms jsonb not null default '[]'::jsonb,
  medical_history jsonb not null default '[]'::jsonb,
  vitals jsonb not null default '{}'::jsonb,
  raw_transcript text,
  priority text not null default 'ROUTINE',
  triggered_red_flags jsonb not null default '[]'::jsonb,
  rationale text,
  confidence numeric,
  timestamp timestamptz not null default now(),
  is_overridden boolean not null default false
);

-- Keep the priority constraint compatible with both the original
-- three priorities and the new doctor-assigned SOLVED state.
alter table public.patients
  drop constraint if exists patients_priority_check;

alter table public.patients
  add constraint patients_priority_check
  check (priority in ('EMERGENCY','SAME-DAY','ROUTINE','SOLVED'));

create index if not exists patients_priority_idx
  on public.patients(priority);

create index if not exists patients_timestamp_idx
  on public.patients(timestamp desc);

create index if not exists patients_priority_timestamp_idx
  on public.patients(priority, timestamp desc);

-- ============================================================
-- 2) DOCTOR OVERRIDE / AUDIT LOG
-- ============================================================
create table if not exists public.override_logs (
  log_id text primary key,
  timestamp timestamptz not null default now(),
  doctor_id text not null,
  patient_id text not null references public.patients(patient_id) on delete cascade,
  old_priority text not null,
  new_priority text not null,
  reason text not null,
  notes text
);

-- Make the audit table accept SOLVED as well.
alter table public.override_logs
  drop constraint if exists override_logs_old_priority_check;

alter table public.override_logs
  drop constraint if exists override_logs_new_priority_check;

alter table public.override_logs
  add constraint override_logs_old_priority_check
  check (old_priority in ('EMERGENCY','SAME-DAY','ROUTINE','SOLVED'));

alter table public.override_logs
  add constraint override_logs_new_priority_check
  check (new_priority in ('EMERGENCY','SAME-DAY','ROUTINE','SOLVED'));

create index if not exists override_logs_timestamp_idx
  on public.override_logs(timestamp desc);

-- ============================================================
-- 3) ROW LEVEL SECURITY
-- ============================================================
alter table public.patients enable row level security;
alter table public.override_logs enable row level security;

-- DEMO POLICIES ONLY.
-- These allow the browser client to operate the shared hackathon queue.
-- For production healthcare data, replace these with Supabase Auth,
-- strict role-based RLS and server-side authorization.

-- Patients: SELECT
 drop policy if exists "demo patients select" on public.patients;
create policy "demo patients select"
on public.patients for select
to anon, authenticated
using (true);

-- Patients: INSERT
 drop policy if exists "demo patients insert" on public.patients;
create policy "demo patients insert"
on public.patients for insert
to anon, authenticated
with check (true);

-- Patients: UPDATE (doctor priority override)
 drop policy if exists "demo patients update" on public.patients;
create policy "demo patients update"
on public.patients for update
to anon, authenticated
using (true)
with check (true);

-- Patients: DELETE (only used by the doctor portal for SOLVED patients)
 drop policy if exists "demo patients delete" on public.patients;
create policy "demo patients delete"
on public.patients for delete
to anon, authenticated
using (true);

-- Audit log: SELECT
 drop policy if exists "demo audit select" on public.override_logs;
create policy "demo audit select"
on public.override_logs for select
to anon, authenticated
using (true);

-- Audit log: INSERT
 drop policy if exists "demo audit insert" on public.override_logs;
create policy "demo audit insert"
on public.override_logs for insert
to anon, authenticated
with check (true);

-- ============================================================
-- 4) PERMISSIONS FOR THE FRONTEND
-- ============================================================
grant select, insert, update, delete on public.patients to anon, authenticated;
grant select, insert on public.override_logs to anon, authenticated;

-- ============================================================
-- 5) SUPABASE REALTIME
-- ============================================================
-- Add patients to Realtime only if it is not already there.
-- This prevents error 42710:
-- relation "patients" is already a member of publication "supabase_realtime"

do $$
begin
  if not exists (
    select 1
    from pg_publication_tables
    where pubname = 'supabase_realtime'
      and schemaname = 'public'
      and tablename = 'patients'
  ) then
    execute 'alter publication supabase_realtime add table public.patients';
  end if;
end $$;

-- ============================================================
-- DONE
-- ============================================================
-- After running this file:
--   patients       -> patient triage queue
--   override_logs  -> doctor priority audit trail
--   SOLVED         -> valid doctor priority
--   DELETE         -> allowed for solved-patient removal
--   Realtime       -> safe even if patients is already configured
