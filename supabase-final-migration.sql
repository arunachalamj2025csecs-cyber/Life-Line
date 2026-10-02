-- LifeLine FINAL backend migration
-- Run this ONCE against an EXISTING LifeLine Supabase database.
-- It preserves patient rows and only changes constraints/policies needed
-- for the new SOLVED + DELETE workflow.

-- 1) Allow SOLVED as a doctor-assigned priority.
alter table public.patients
  drop constraint if exists patients_priority_check;

alter table public.patients
  add constraint patients_priority_check
  check (priority in ('EMERGENCY','SAME-DAY','ROUTINE','SOLVED'));

-- 2) Keep the audit trail compatible with SOLVED assignments.
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

-- 3) Allow the doctor portal to delete a solved patient.
drop policy if exists "demo patients delete" on public.patients;

create policy "demo patients delete"
on public.patients for delete
to anon, authenticated
using (true);

grant delete on public.patients to anon, authenticated;

-- 4) Add Realtime only if patients is not already a member.
-- This avoids: 42710 relation "patients" is already a member of publication.
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

-- 5) Helpful index for active/solved queue lookups.
create index if not exists patients_priority_timestamp_idx
  on public.patients(priority, timestamp desc);
