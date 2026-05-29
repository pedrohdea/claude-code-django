#!/usr/bin/env bash
# Increment 001: create a default superuser if none exists.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT/backend"
. .venv/bin/activate
python manage.py shell << 'PY'
from apps.accounts.models import User
if not User.objects.filter(is_superuser=True).exists():
    User.objects.create_superuser(
        username="admin", email="admin@example.com", password="admin12345"
    )
    print("superuser created: admin@example.com / admin12345")
else:
    print("superuser already exists")
PY
