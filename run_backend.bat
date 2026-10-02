@echo off
cd /d "%~dp0"
if not exist .venv (
  py -m venv .venv
)
call .venv\Scripts\activate
python -m pip install -r backend\requirements.txt
if not defined GEMINI_API_KEY (
  echo.
  echo GEMINI_API_KEY is not set.
  echo Set it before starting the backend, for example:
  echo set GEMINI_API_KEY=YOUR_KEY
  echo.
  pause
  exit /b 1
)
python -m uvicorn backend.server:app --host 127.0.0.1 --port 8000
