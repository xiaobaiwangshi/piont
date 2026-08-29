#!/bin/bash
set -euo pipefail

SCRIPT_DIR="/private/var/www/wsl_doc/knowledge-base/"
SSH_KEY="${HOME}/.ssh/id_rsa_huoshan_muxin"

if [ ! -r "${SSH_KEY}" ]; then
    echo "[ERROR] SSH key 不存在或不可读: ${SSH_KEY}" >&2
    exit 1
fi

rsync -rzvt --no-perms --no-owner --no-group \
-e "ssh -i ${SSH_KEY}" \
"${SCRIPT_DIR}/" \
root@115.190.113.50:/var/www/html/knowledge/
