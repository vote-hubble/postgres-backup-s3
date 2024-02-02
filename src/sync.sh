#! /bin/sh

set -eu
set -o pipefail

source ./env.sh

echo "Syncing local backups with S3..."

s3cmd sync --host=$S3_ENDPOINT --region=$S3_REGION --host-bucket=$S3_BUCKET \
  --no-mime-magic --no-preserve --progress --stats --verbose \
  /backups/ "s3://${S3_BUCKET}/${S3_PREFIX}/"
