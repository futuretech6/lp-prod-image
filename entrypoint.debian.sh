#!/bin/bash
set -e

echo "[*] Current workspace is $WORKSPACE."

TARGET_DIR=${WORKSPACE:-/workspace}

# Check if TARGET_DIR is mounted
if mountpoint -q "$TARGET_DIR"; then
    HOST_UID=$(stat -c "%u" $TARGET_DIR)
    HOST_GID=$(stat -c "%g" $TARGET_DIR)
    USERNAME=prod
    GROUPNAME=prod

    echo "[*] $TARGET_DIR is mounted. Creating user $GROUPNAME:$USERNAME."

    groupadd -g "$HOST_GID" $GROUPNAME || true
    useradd -u "$HOST_UID" -g "$HOST_GID" -m -s /bin/bash $USERNAME || true

    usermod -aG sudo "$USERNAME"
    echo "$USERNAME ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

    exec gosu "$USERNAME" "$@"
else
    echo "[!] $TARGET_DIR is not mounted. Continuing as root."
    exec "$@"
fi
