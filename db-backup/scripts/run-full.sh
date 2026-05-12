#!/bin/bash
set -e

WORK_DIR="/backup/work"
FULL_DIR="$WORK_DIR/full"

echo "[FULL] Starting new cycle..."

rm -rf "$WORK_DIR"
mkdir -p "$FULL_DIR"

mariabackup \
  --backup \
  --host="$DB_HOST" \
  --port="${DB_PORT:-3306}" \
  --user="$DB_USER" \
  --password="$DB_PASSWORD" \
  --datadir=/var/lib/mysql \
  --target-dir="$FULL_DIR"

mariabackup --prepare --target-dir="$FULL_DIR"

echo "[FULL] Done"