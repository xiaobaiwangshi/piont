#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SSH_KEY="${HOME}/.ssh/id_rsa_huoshan_muxin"

if [ ! -r "${SSH_KEY}" ]; then
    echo "[ERROR] SSH key 不存在或不可读: ${SSH_KEY}" >&2
    exit 1
fi

rsync -rzvt --no-perms --no-owner --no-group \
-e "ssh -i ${SSH_KEY}" \
--rsync-path="sudo -u www-data rsync" \
--exclude-from="${SCRIPT_DIR}/exclude.txt" \
"${SCRIPT_DIR}/" \
root@115.190.113.50:/var/www/html/ww_server/
