#!/usr/bin/env bash
# Idempotent bootstrap: only does what's missing.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"

echo "==> Backend"
cd "$ROOT/backend"
[ -d .venv ] || python3 -m venv .venv
. .venv/bin/activate
pip install -q --upgrade pip
pip install -q -r requirements-dev.txt
[ -f .env ] || cp .env.example .env
python manage.py migrate --noinput
deactivate

echo "==> Frontend"
cd "$ROOT/frontend"
[ -d node_modules ] || npm install
[ -f .env ] || cp .env.example .env

echo "==> Applying pending increments"
bash "$ROOT/scripts/apply_increments.sh"

echo "✅ Bootstrap complete. Run 'make dev'."
