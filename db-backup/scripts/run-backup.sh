#!/bin/bash
set -e

WORK_DIR="/backup/work"
META_DIR="/backup/meta"
BACKUP_TYPE="${BACKUP_TYPE:-full}"
BACKUP_NUMBER="${BACKUP_NUMBER:-5}"
BACKUP_TIME="${BACKUP_TIME:-86400}"

backup_once() {
    echo "[BACKUP] Starting backup type: $BACKUP_TYPE"

    if [ "$BACKUP_TYPE" = "full" ]; then
        echo "[BACKUP] Running full backup"
        /scripts/run-full.sh
        BACKUP_DIR="$WORK_DIR/full"
    elif [ "$BACKUP_TYPE" = "incremental" ]; then
        echo "[BACKUP] Running incremental backup"
        /scripts/run-incremental.sh
        INC_COUNT=$(cat "$META_DIR/inc_count" 2>/dev/null || echo 1)
        BACKUP_DIR="$WORK_DIR/inc_$INC_COUNT"
    else
        echo "[BACKUP] ERROR: Invalid BACKUP_TYPE. Use 'full' or 'incremental'"
        return 1
    fi

    BACKUP_COUNT=$(ls -1 /backup/*.tar.gz 2>/dev/null | wc -l)
    echo "[BACKUP] Current backup count: $BACKUP_COUNT"

    if [ "$BACKUP_COUNT" -ge "$BACKUP_NUMBER" ]; then
        OLDEST_BACKUP=$(ls -t /backup/*.tar.gz 2>/dev/null | tail -1)
        if [ -n "$OLDEST_BACKUP" ]; then
            echo "[BACKUP] Removing oldest backup: $OLDEST_BACKUP"
            rm -f "$OLDEST_BACKUP"
        fi
    fi

    TS=$(date +"%Y-%m-%d_%H-%M-%S")
    BACKUP_NAME="backup_${BACKUP_TYPE}_$TS.tar.gz"
    BACKUP_PATH="/backup/$BACKUP_NAME"

    echo "[BACKUP] Creating tar.gz: $BACKUP_PATH"
    tar -czf "$BACKUP_PATH" -C "$WORK_DIR" "$(basename "$BACKUP_DIR")"

    if [ -n "$SFTP_HOST" ] && [ -n "$SFTP_USER" ] && [ -n "$SFTP_PASS" ]; then
        SFTP_PORT="${SFTP_PORT:-22}"
        SFTP_PATH="${SFTP_PATH:-/}"
        SFTP_BACKUP_NUMBER="${SFTP_BACKUP_NUMBER:-$BACKUP_NUMBER}"

        echo "[BACKUP] Sending to SFTP: $SFTP_HOST:$SFTP_PATH"
        if [ -f "$BACKUP_PATH" ]; then
            echo "[BACKUP] File exists: $BACKUP_PATH"
            set +e
            SFTP_FILE_LIST=$(sshpass -p "$SFTP_PASS" sftp -q -oBatchMode=no -oStrictHostKeyChecking=no -P "$SFTP_PORT" "$SFTP_USER@$SFTP_HOST" <<EOF 2>&1
cd "$SFTP_PATH"
ls -1 backup_*.tar.gz
bye
EOF
)
            SFTP_EXIT=$?
            if [ $SFTP_EXIT -ne 0 ] && ! printf '%s\n' "$SFTP_FILE_LIST" | grep -q -E "No such file|Couldn't stat remote file"; then
                echo "[BACKUP] ERROR: Failed to list remote SFTP files"
                echo "[BACKUP] SFTP list output: $SFTP_FILE_LIST"
            else
                mapfile -t REMOTE_FILES < <(printf '%s\n' "$SFTP_FILE_LIST" \
                    | sed 's/^sftp> //' \
                    | grep -v '^$' \
                    | grep -v -E "^(cd |ls |bye$)|No such file|Couldn't stat remote file" \
                    | grep -E '^backup_.*\.tar\.gz$' \
                    | sort)
                REMOTE_COUNT=${#REMOTE_FILES[@]}
                echo "[BACKUP] Remote backup files found: $REMOTE_COUNT"
                while [ "$REMOTE_COUNT" -ge "$SFTP_BACKUP_NUMBER" ] && [ "$REMOTE_COUNT" -gt 0 ]; do
                    OLDEST_REMOTE_FILE="${REMOTE_FILES[0]}"
                    echo "[BACKUP] Removing oldest remote backup: $OLDEST_REMOTE_FILE"
                    SFTP_REMOVE_OUTPUT=$(sshpass -p "$SFTP_PASS" sftp -q -oBatchMode=no -oStrictHostKeyChecking=no -P "$SFTP_PORT" "$SFTP_USER@$SFTP_HOST" <<EOF 2>&1
cd "$SFTP_PATH"
rm "$OLDEST_REMOTE_FILE"
bye
EOF
)
                    echo "[BACKUP] SFTP remove output: $SFTP_REMOVE_OUTPUT"
                    REMOTE_FILES=("${REMOTE_FILES[@]:1}")
                    REMOTE_COUNT=${#REMOTE_FILES[@]}
                done
            fi

            SFTP_OUTPUT=$(sshpass -p "$SFTP_PASS" sftp -oBatchMode=no -oStrictHostKeyChecking=no -P "$SFTP_PORT" "$SFTP_USER@$SFTP_HOST" <<EOF 2>&1
cd "$SFTP_PATH"
put "$BACKUP_PATH"
bye
EOF
)
            SFTP_EXIT=$?
            set -e
            echo "[BACKUP] SFTP exit code: $SFTP_EXIT"
            echo "[BACKUP] SFTP output: $SFTP_OUTPUT"
            if [ $SFTP_EXIT -eq 0 ]; then
                echo "[BACKUP] SFTP upload done"
            else
                echo "[BACKUP] SFTP upload failed"
            fi
        else
            echo "[BACKUP] ERROR: Backup file not found: $BACKUP_PATH"
        fi
    else
        echo "[BACKUP] SFTP variables not set, skipping upload"
    fi

    echo "[BACKUP] Done"
}

if [ "$BACKUP_TIME" -gt 0 ]; then
    echo "[BACKUP] Starting periodic backups every $BACKUP_TIME seconds"
    while true; do
        backup_once
        echo "[BACKUP] Sleeping $BACKUP_TIME seconds before the next backup"
        sleep "$BACKUP_TIME"
    done
else
    backup_once
fi