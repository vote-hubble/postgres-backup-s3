#! /bin/sh

set -eu
set -o pipefail

source ./env.sh
mkdir -p backups

echo "Backing up ${POSTGRES_DATABASE}..."

file_name="${POSTGRES_DATABASE}_$(date +"%Y-%m-%dT%H:%M:%S").dump"

echo "Starting..."
pg_dump --format=custom \
  -h $POSTGRES_HOST \
  -p $POSTGRES_PORT \
  -U $POSTGRES_USER \
  -d $POSTGRES_DATABASE \
  $PGDUMP_EXTRA_OPTS \
  > /backups/${file_name}
echo "Finished..."

if [ -n "$PASSPHRASE" ]; then
  echo "Encrypting..."
  gpg --symmetric --batch --passphrase "$PASSPHRASE" "/backups/${file_name}"
  rm "/backups/${file_name}"
  echo "Encryption complete!"
fi

source ./prune.sh
source ./sync.sh
source ./notify.sh "Database backup completed - ${file_name}"

echo "Backup of ${POSTGRES_DATABASE} completed successfully!"
