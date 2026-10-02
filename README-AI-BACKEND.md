# LifeLine AI Backend

The AI bot now uses a real Gemini API through a local FastAPI backend. The Gemini key is **not** stored in the browser.

## 1. Install and set the key (Windows)

Open Command Prompt in this folder:

```bat
py -m venv .venv
.venv\Scripts\activate
python -m pip install -r backend\requirements.txt
set GEMINI_API_KEY=YOUR_GEMINI_API_KEY
```

You can also create a `.env` file if you use a process manager, but the included `run_backend.bat` expects `GEMINI_API_KEY` to be present in the environment.

## 2. Start the AI backend

```bat
python -m uvicorn backend.server:app --host 127.0.0.1 --port 8000
```

Or use `run_backend.bat` after setting the environment variable.

Check:

`http://127.0.0.1:8000/api/health`

It should return JSON showing `ok: true` and `gemini_configured: true`.

## 3. Start the frontend

Use VS Code Live Server (or another local HTTP server) and open `index.html`.
Do not open the HTML with `file://`.

Patient Portal -> login -> AI Assistant.

The AI assistant reads the patient profile from the existing `sessionStorage` login session and sends it to the backend.

## Safety architecture

```text
Patient message
   -> FastAPI backend
   -> deterministic emergency checks
   -> Gemini conversational/structured triage
   -> safety result
   -> Supabase queue
   -> Doctor review
```

Emergency patterns are checked outside Gemini and cannot be downgraded by the model. The approved LifeLine knowledge base is supplied to the model as context. The model is not allowed to diagnose or prescribe; the doctor remains the final decision-maker.

The Gemini API key must never be put in `index.html`, `ai-bot.html`, or `supabase-config.js`.
