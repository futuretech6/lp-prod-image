#!/bin/bash
set -e

echo "Current workspace is $WORKSPACE."

TARGET_DIR=${WORKSPACE:-/workspace}

HOST_UID=$(stat -c "%u" $TARGET_DIR)
HOST_GID=$(stat -c "%g" $TARGET_DIR)
USERGROUP=prod
USERNAME=prod

groupadd -g "$HOST_GID" $USERGROUP || true
useradd -u "$HOST_UID" -g "$HOST_GID" -m -s /bin/bash $USERNAME || true

usermod -aG wheel "$USERNAME"  # "wheel" is the default group for sudoers in CentOS
echo "$USERNAME ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

exec gosu "$USERNAME" "$@"
