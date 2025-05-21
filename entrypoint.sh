#!/bin/bash
set -e

echo "[*] Current workspace is $WORKSPACE."

TARGET_DIR=${WORKSPACE:-/workspace}

# Check if TARGET_DIR is mounted
if mountpoint -q "$TARGET_DIR"; then
    HOST_UID=$(stat -c "%u" $TARGET_DIR)
    HOST_GID=$(stat -c "%g" $TARGET_DIR)
    USERGROUP=prod
    USERNAME=prod

    echo "[*] $TARGET_DIR is mounted. Creating user $USERGROUP:$USERNAME."

    groupadd -g "$HOST_GID" $USERGROUP || true
    useradd -u "$HOST_UID" -g "$HOST_GID" -m -s /bin/bash $USERNAME || true

    usermod -aG wheel "$USERNAME"  # "wheel" is the default group for sudoers in CentOS
    echo "$USERNAME ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

    exec gosu "$USERNAME" "$@"
else
    echo "[!] $TARGET_DIR is not mounted. Continuing as root."
    exec "$@"
fi
