#!/bin/bash
set -e

TS=$(date +"%Y-%m-%d_%H-%M-%S")

WORK_DIR="/backup/work"
DEST_DIR="/backup/fullchain"
DEST="$DEST_DIR/fullchain_$TS.tar.gz"

echo "[CHAIN] Creating fullchain..."

mkdir -p "$DEST_DIR"

if [ ! -d "$WORK_DIR/full" ]; then
    echo "[CHAIN] ERROR: no FULL found"
    exit 1
fi

tar -czf "$DEST" -C "$WORK_DIR" .

echo "[CHAIN] Cleaning workdir..."
rm -rf "$WORK_DIR"
rm -f /backup/meta/inc_count

MAX=${FULLCHAIN_QUANTITIES:-2}

ls -t "$DEST_DIR"/*.tar.gz 2>/dev/null | tail -n +$((MAX+1)) | xargs -r rm -f

echo "[CHAIN] Done"