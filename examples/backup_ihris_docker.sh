#!/usr/bin/env bash
set -Eeuo pipefail

# Copy this script to /opt/ihris-ops and edit these non-secret settings.
COMPOSE_DIR="/srv/ihris"
BACKUP_DIR="/var/backups/ihris"
DB_SERVICE="db"
DB_NAME="hapi"
DB_USER="admin"
RETENTION_DAYS="30"

PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
umask 077

timestamp="$(date -u +%Y%m%dT%H%M%SZ)"
hostname_short="$(hostname -s)"
filename="${BACKUP_DIR}/${hostname_short}-${DB_NAME}-${timestamp}.backup"
temporary="${filename}.partial"
checksum="${filename}.sha256"

cleanup() {
  rm -f -- "$temporary"
}
trap cleanup EXIT

mkdir -p -- "$BACKUP_DIR"
chmod 700 -- "$BACKUP_DIR"

cd -- "$COMPOSE_DIR"

echo "[$(date -u +%FT%TZ)] Starting PostgreSQL backup: ${DB_NAME}"

docker compose exec -T "$DB_SERVICE" \
  pg_dump -U "$DB_USER" -d "$DB_NAME" \
  --format=custom --compress=6 \
  > "$temporary"

if [[ ! -s "$temporary" ]]; then
  echo "ERROR: Backup output is empty" >&2
  exit 1
fi

# Test that pg_restore can read the custom-format archive before accepting it.
docker compose exec -T "$DB_SERVICE" pg_restore -l < "$temporary" > /dev/null

mv -- "$temporary" "$filename"
sha256sum "$filename" > "$checksum"

echo "[$(date -u +%FT%TZ)] Backup created: ${filename}"
du -h -- "$filename"

# Delete only backup/checksum files created by this naming pattern.
find "$BACKUP_DIR" -maxdepth 1 -type f \
  -name "${hostname_short}-${DB_NAME}-*.backup" \
  -mtime "+${RETENTION_DAYS}" -print -delete

find "$BACKUP_DIR" -maxdepth 1 -type f \
  -name "${hostname_short}-${DB_NAME}-*.backup.sha256" \
  -mtime "+${RETENTION_DAYS}" -print -delete

echo "[$(date -u +%FT%TZ)] Backup job completed successfully"
