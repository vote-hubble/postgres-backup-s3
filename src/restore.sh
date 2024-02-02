#! /bin/sh

set -eu
set -o pipefail

source ./env.sh

echo "Restoring ${POSTGRES_DATABASE}..."
echo "WARNING! This is a destructive operation."

if [ -z "$PASSPHRASE" ]; then
  file_type=".dump"
else
  file_type=".dump.gpg"
fi

if [ $# -eq 1 ]; then
  echo "Restoring from backup with timestamp: $1"
  timestamp="$1"
  restore_source_file="/backups/${POSTGRES_DATABASE}_${timestamp}${file_type}"
else
  echo "Finding latest backup..."
  restore_source_file=$(find /backups -type f -name "*${file_type}" | sort | tail -n 1)
fi

if [ -n "$PASSPHRASE" ]; then
  echo "Decrypting backup..."
  gpg --decrypt --batch --passphrase "$PASSPHRASE" "$restore_source_file" > "${POSTGRES_DATABASE}-restore.dump"
else
  echo "Preparing backup for usage..."
  ln -s "/backups/${restore_source_file}" "${POSTGRES_DATABASE}-restore.dump"
fi

echo "Starting data restore from backup..."
pg_restore -h $POSTGRES_HOST \
  -p $POSTGRES_PORT \
  -U $POSTGRES_USER \
  -d $POSTGRES_DATABASE \
  --clean --if-exists --verbose \
  "${POSTGRES_DATABASE}-restore.dump"

echo "Restored. Cleaning up..."
rm "${POSTGRES_DATABASE}-restore.dump"

echo "Restore of ${POSTGRES_DATABASE} completed successfully!"
