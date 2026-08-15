#!/usr/bin/env bash
set -Eeuo pipefail

COMPOSE_DIR="/srv/ihris"
BACKUP_DIR="/var/backups/ihris"
DB_SERVICE="db"

PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

latest="$(find "$BACKUP_DIR" -maxdepth 1 -type f -name '*.backup' -printf '%T@ %p\n' \
  | sort -nr | head -1 | cut -d' ' -f2-)"

if [[ -z "$latest" || ! -s "$latest" ]]; then
  echo "ERROR: No non-empty iHRIS backup found in ${BACKUP_DIR}" >&2
  exit 1
fi

checksum="${latest}.sha256"
if [[ ! -f "$checksum" ]]; then
  echo "ERROR: Checksum file not found: ${checksum}" >&2
  exit 1
fi

cd -- "$BACKUP_DIR"
sha256sum -c "$(basename "$checksum")"

cd -- "$COMPOSE_DIR"
docker compose exec -T "$DB_SERVICE" pg_restore -l < "$latest" > /dev/null

echo "[$(date -u +%FT%TZ)] Latest backup verified: ${latest}"

# Archive readability is not a full restore test. Restore regularly into an
# isolated environment and validate FHIR/iHRIS behavior.
