#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
trap 'kill 0' EXIT
( cd "$ROOT/backend" && . .venv/bin/activate && python manage.py runserver ) &
( cd "$ROOT/frontend" && npm run dev ) &
wait
