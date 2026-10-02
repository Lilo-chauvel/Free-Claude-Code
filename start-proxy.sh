#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

if [[ ! -f .env ]]; then
  printf 'Erreur : %s/.env est absent. Copiez .env.example vers .env et renseignez les clés.\n' "$SCRIPT_DIR" >&2
  exit 1
fi

docker compose up -d --build
docker compose ps
