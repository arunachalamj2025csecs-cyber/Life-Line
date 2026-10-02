# LifeLine: security fixes and required deployment work

## Changes applied in this package
- Removed hard-coded shared patient/doctor passwords from the browser. Both sign-in paths fail closed rather than exposing a universal credential.
- Made the AI endpoint configurable with `window.LIFELINE_API_URL` (defaults to localhost for local development).
- Added `SECURITY-LOCKDOWN.sql` to revoke the existing public demo access. **This intentionally blocks the current queue until authenticated policies are implemented.**
- Preserved the responsive changes and added this deployment checklist.

## Important: not safe for real patient data yet
This is a source-code remediation, not a clinical or production certification. Do not enter real patient data until all items below are completed and independently tested.

## Required actions (cannot be completed from this ZIP alone)
1. **Supabase ownership:** In the project dashboard, back up the database, then run `SECURITY-LOCKDOWN.sql`. It revokes access for anon and authenticated roles; the current browser queue will stop working until proper RLS is configured.
2. **Authentication:** Enable Supabase Auth; create accounts through the trusted admin process; assign doctor/patient roles in a server-controlled table or JWT custom claims. Never accept a role supplied by browser form/session storage. Replace the demo login flow with `signInWithPassword`, validate `getUser()` on the server, and use RLS policies based on verified `auth.uid()` and role claims. Do not re-enable the old open policies.
3. **Backend:** The original archive does not contain the `backend/` directory or `requirements.txt` referenced by its README. Create/deploy a FastAPI service, set `GEMINI_API_KEY` only in server environment secrets, require authenticated requests, validate input, add rate limits, CORS allow-list, request-size limits, timeouts, and audit logging. Set `window.LIFELINE_API_URL` to its HTTPS URL in deployment config.
4. **Clinical safety:** Have licensed clinicians validate every red-flag rule, thresholds, wording, escalation path, and failure mode. Keep emergency guidance deterministic and visible even if AI/backend is unavailable. Do not present model output as diagnosis or treatment. Add a clear emergency disclaimer and local emergency contact instructions approved for the deployment region.
5. **Privacy:** Define consent, retention/deletion, access logging, encryption, breach response, and applicable healthcare/privacy compliance with qualified counsel and your institution. Avoid sending identifiable patient data to an AI provider unless approved and covered by the required agreements.
6. **Test before release:** Verify patient A cannot read patient B; patients cannot access doctor queue; patients cannot update priorities; unauthenticated requests fail; revoked users lose access; backend errors/timeouts never downgrade emergency severity; mobile layouts work at 320/375/768/1024px; and no secrets appear in source maps, browser storage, or network responses.

## Configuration
In `ai-bot.html`, `window.LIFELINE_API_URL` may be set before the page script loads, for example:
`<script>window.LIFELINE_API_URL = 'https://YOUR-API-DOMAIN';</script>`
Do not put Gemini or Supabase service-role keys in frontend files. The Supabase anon/publishable key is designed to be public, but is safe only with correct RLS and grants.

## Deployment status
Not production-ready. Authentication integration, authenticated RLS, backend implementation/deployment, clinical validation, and privacy review require project-owner credentials and decisions that are not present in the supplied archive.
