# LifeLine project – responsive update and review

## Changes made
- Added small-screen layout rules to `index.html` and `ai-bot.html`.
- Header navigation can wrap/scroll instead of forcing the page wider.
- Main grids collapse on narrow screens; controls and buttons fit mobile widths.
- Tables can scroll horizontally; mobile form text uses 16px to reduce unwanted iOS zoom.

## Major issues to address (not silently changed)
1. **Client-side portal passwords:** `index.html` compares patient/doctor passwords in browser JavaScript. Anyone can inspect or bypass this; it is not authentication. Move sign-in and role authorization to a trusted server (e.g. Supabase Auth + RLS).
2. **Clinical safety:** This is a triage prototype, not a validated medical device or a substitute for a clinician. Rule coverage, thresholds, language handling, false negatives, and escalation behavior need clinical review, documented validation, and prominent emergency instructions.
3. **Backend mismatch:** `README-AI-BACKEND.md` describes a FastAPI backend and `ai-bot.html` calls `http://127.0.0.1:8000/api/triage`, but no `backend/` folder or requirements file is included in this ZIP. This will not work for deployed users without a separately deployed backend and configured URL.
4. **Supabase data security:** The browser contains a Supabase anon key (normal only when protected by strict Row Level Security). Verify RLS policies for every table and ensure no service-role key is ever exposed. Do not store identifiable patient/health data without appropriate consent, access controls, retention, and legal review.
5. **Deployment configuration:** A localhost backend URL cannot serve remote users. Use an HTTPS production API endpoint, CORS allowlisting, secrets stored server-side, and environment-specific configuration.
6. **Accessibility and UX:** Test keyboard navigation, visible focus, screen-reader labels/status announcements, contrast, error states, and Tamil/other-language text at real device sizes.
7. **Testing gaps:** No automated tests or browser/device test evidence were included. Test patient intake, red-flag escalation, doctor access, persistence, offline behavior, and network failures before any real-world use.

## Important
The update is CSS-only and does not certify functionality, security, clinical accuracy, or deployment readiness. Test on actual phones/tablets and with a qualified clinical reviewer before use with patients.
