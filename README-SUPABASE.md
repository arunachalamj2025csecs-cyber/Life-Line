# LifeLine — Supabase Final Configuration

## Existing Supabase project
This package is configured for the existing LifeLine Supabase project through `supabase-config.js`.

### 1. Existing database
Open Supabase SQL Editor and run:
`supabase-final-migration.sql`

This preserves existing `patients` rows and adds the SOLVED/delete backend support. It also safely handles Realtime when `patients` is already in `supabase_realtime`.

### 2. Fresh database
If this is a completely new Supabase project, run:
`supabase-schema.sql`

### 3. Frontend configuration
`index.html` loads the Supabase JS SDK and `supabase-config.js`.
The app then creates the Supabase client and uses the `patients` and `override_logs` tables.

### 4. Important security note
The browser uses a Supabase anon/publishable key. Never put a service_role/secret key in frontend code. This is a hackathon/demo architecture; real healthcare deployment requires Supabase Auth, strict role-based RLS, and server-side authorization.

### 5. Run locally
Use VS Code Live Server or another local HTTP server. Do not open `index.html` with `file://`.


Connection fix: the application now has a fallback to the configured Supabase URL/publishable key and performs a real patients-table connection test on startup.
