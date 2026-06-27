#!/bin/bash
set -e

BACKUP_DIR="./database_backup"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
DB_NAME="${DB_DATABASE:-ridoo}"

mkdir -p "$BACKUP_DIR"
mysqldump -u "${DB_USERNAME:-root}" -p"${DB_PASSWORD:-secret}" "$DB_NAME" > "$BACKUP_DIR/ridoo_${TIMESTAMP}.sql"
echo "Backup saved to $BACKUP_DIR/ridoo_${TIMESTAMP}.sql"
