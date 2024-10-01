#! /bin/sh

set -eu
set -o pipefail

source ./env.sh
mkdir -p backups

echo "Backing up ${POSTGRES_DATABASE}..."

file_name="${POSTGRES_DATABASE}_$(date +"%Y-%m-%dT%H:%M:%S").dump"

pg_dump --format=custom -h $POSTGRES_HOST -p $POSTGRES_PORT -U $POSTGRES_USER -d $POSTGRES_DATABASE \
  $PGDUMP_EXTRA_OPTS > /backups/${file_name}

echo "Finished!"

if [ -n "$PASSPHRASE" ]; then
  echo "Encrypting backup..."

  gpg --symmetric --batch --passphrase "$PASSPHRASE" "/backups/${file_name}"
  rm "/backups/${file_name}"

  echo "Encryption complete!"
fi

echo "Saving to S3..."

s3cmd put --host=$S3_ENDPOINT --region=$S3_REGION --host-bucket=$S3_BUCKET \
    --no-mime-magic --no-preserve --verbose \
    /backups/${file_name}.gpg "s3://${S3_BUCKET}/${S3_PREFIX}/"

if [ -n "$CALLBACK_URL" ]; then
  curl -d "[Backup] Completed ${file_name}" $CALLBACK_URL
fi

echo "Backup of ${POSTGRES_DATABASE} completed successfully!"
