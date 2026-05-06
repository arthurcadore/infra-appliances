#!/bin/bash
set -e

INC_MAX=${INC_QUANTITIES:-3}
SLEEP_TIME=${INC_INTERVAL_SECONDS:-60}

META_DIR="/backup/meta"

mkdir -p "$META_DIR"

while true; do

    INC_COUNT=$(cat "$META_DIR/inc_count" 2>/dev/null || echo -1)

    echo "[LOOP] Current inc_count=$INC_COUNT"

    if [ "$INC_COUNT" -lt 0 ]; then
        echo "[LOOP] No backup → FULL"
        /scripts/run-full.sh

    elif [ "$INC_COUNT" -lt "$INC_MAX" ]; then
        echo "[LOOP] Running incremental ($INC_COUNT/$INC_MAX)"
        /scripts/run-incremental.sh

    else
        echo "[LOOP] Finalizing fullchain"
        /scripts/run-fullchain.sh
    fi

    sleep "$SLEEP_TIME"

done