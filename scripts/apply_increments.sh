#!/usr/bin/env bash
# Runs increment scripts not yet recorded in STATE. Each is run once.
set -euo pipefail
DIR="$(cd "$(dirname "$0")/increments" && pwd)"
STATE="$DIR/STATE"
touch "$STATE"
for f in "$DIR"/[0-9]*.sh; do
  [ -e "$f" ] || continue
  name="$(basename "$f")"
  if grep -qxF "$name" "$STATE"; then
    echo "  - skip $name (already applied)"
  else
    echo "  - apply $name"
    bash "$f"
    echo "$name" >> "$STATE"
  fi
done
