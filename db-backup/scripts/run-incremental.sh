#!/bin/bash
set -e

WORK_DIR="/backup/work"
META="/backup/meta"

INC_COUNT=$(cat "$META/inc_count" 2>/dev/null || echo 0)
NEXT_INC=$((INC_COUNT + 1))

INC_DIR="$WORK_DIR/inc_$NEXT_INC"

mkdir -p "$INC_DIR"

if [ "$INC_COUNT" -eq 0 ]; then
    BASE_DIR="$WORK_DIR/full"
else
    BASE_DIR="$WORK_DIR/inc_$INC_COUNT"
fi

echo "[INC] Base: $BASE_DIR"

if [ ! -d "$BASE_DIR" ]; then
    echo "[INC] ERROR: base not found"
    exit 1
fi

mariabackup \
  --backup \
  --host="$DB_HOST" \
  --port="${DB_PORT:-3306}" \
  --user="$DB_USER" \
  --password="$DB_PASSWORD" \
  --datadir=/var/lib/mysql \
  --incremental-basedir="$BASE_DIR" \
  --target-dir="$INC_DIR"

echo "[INC] Done ($NEXT_INC)"