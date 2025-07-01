#!/bin/bash
set -e

echo "[*] Current workspace is $WORKSPACE."

TARGET_DIR=${WORKSPACE:-/workspace}

USERNAME=prod
GROUPNAME=prod
CURRENT_UID=$(id -u "$USERNAME" 2>/dev/null)
CURRENT_GID=$(id -g "$USERNAME" 2>/dev/null)

# Check if TARGET_DIR or any parent directory is mounted
current_dir="$TARGET_DIR"
is_mounted=false
while [ "$current_dir" != "/" ]; do
    if mountpoint -q "$current_dir"; then
        echo "[*] $current_dir is a mount point."
        is_mounted=true
        break
    fi
    current_dir=$(dirname "$current_dir")
done

# After the loop, check the is_mounted flag
if [ "$is_mounted" = true ]; then
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
