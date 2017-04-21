#!/bin/env bash

set -eu

# Location of the borg repo, passed in via cmd line
BACKUP_REPO=${1:-}

if [[ $BACKUP_REPO == "" ]]; then
  echo "Usage: ./backup.sh <borg_repo>"
  exit 1
fi

# Backup of /extra minus excluded directories
borg create -v --stats                          \
    ${BACKUP_REPO}::'{hostname}-{now:%Y-%m-%d}' \
    /extra                                      \
    --exclude Bitcoin/                          \
    --exclude Bitcoin\ majaraja/                \

# Use the `prune` subcommand to maintain 7 daily, 4 weekly and 6 monthly
# archives of THIS machine. The '{hostname}-' prefix is very important to
# limit prune's operation to this machine's archives and not apply to
# other machine's archives also.
borg prune -v --list $BACKUP_REPO --prefix '{hostname}-' \
    --keep-daily=7 --keep-weekly=4 --keep-monthly=6
