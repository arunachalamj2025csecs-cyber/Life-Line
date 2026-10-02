-- Run only after backing up the project database.
-- This immediately blocks the current public demo access. The browser app's
-- patient/doctor queue will remain unavailable until authenticated RLS is deployed.
alter table public.patients enable row level security;
alter table public.override_logs enable row level security;
drop policy if exists "demo patients select" on public.patients;
drop policy if exists "demo patients insert" on public.patients;
drop policy if exists "demo patients update" on public.patients;
drop policy if exists "demo patients delete" on public.patients;
drop policy if exists "demo audit select" on public.override_logs;
drop policy if exists "demo audit insert" on public.override_logs;
revoke all on public.patients from anon;
revoke all on public.override_logs from anon;
revoke all on public.patients from authenticated;
revoke all on public.override_logs from authenticated;
-- Do not add permissive policies until Auth, verified role assignment,
-- patient ownership rules, doctor authorization, and audit controls exist.
