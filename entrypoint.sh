#!/bin/bash
set -e

echo "[*] Current workspace is $WORKSPACE."

TARGET_DIR=${WORKSPACE:-/workspace}

USERNAME=prod
GROUPNAME=prod
CURRENT_UID=$(id -u "$USERNAME" 2>/dev/null)
CURRENT_GID=$(id -g "$USERNAME" 2>/dev/null)

# Check if TARGET_DIR is mounted
if mountpoint -q "$TARGET_DIR"; then
    HOST_UID=$(stat -c "%u" $TARGET_DIR)
    HOST_GID=$(stat -c "%g" $TARGET_DIR)

    if [ "$CURRENT_UID:$CURRENT_GID" != "$HOST_UID:$HOST_GID" ]; then
        echo "[*] Current UID:GID ($CURRENT_UID:$CURRENT_GID) does not match host UID:GID ($HOST_UID:$HOST_GID) of $TARGET_DIR."
        echo "    Changing user $USERNAME:$GROUPNAME to $HOST_UID:$HOST_GID..."

        usermod -u "$HOST_UID" "$USERNAME"
        groupmod -g "$HOST_GID" "$GROUPNAME"

        echo "[*] ID changed."
    else
        echo "[*] User ID and group ID matched. Continuing as $USERNAME."
    fi
else
    echo "[!] $TARGET_DIR is not mounted. Continuing as $USERNAME."
fi

exec gosu "$USERNAME" "$@"
