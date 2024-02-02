if [ -z "$S3_BUCKET" ]; then
  echo "You need to set the S3_BUCKET environment variable."
  exit 1
fi

if [ -z "$S3_PREFIX" ]; then
  echo "You need to set the S3_PREFIX environment variable."
  exit 1
fi

if [ -z "$POSTGRES_DATABASE" ]; then
  echo "You need to set the POSTGRES_DATABASE environment variable."
  exit 1
fi

if [ -z "$POSTGRES_HOST" ]; then
  # https://docs.docker.com/network/links/#environment-variables
  if [ -n "$POSTGRES_PORT_5432_TCP_ADDR" ]; then
    POSTGRES_HOST=$POSTGRES_PORT_5432_TCP_ADDR
    POSTGRES_PORT=$POSTGRES_PORT_5432_TCP_PORT
  else
    echo "You need to set the POSTGRES_HOST environment variable."
    exit 1
  fi
fi

if [ -z "$POSTGRES_USER" ]; then
  echo "You need to set the POSTGRES_USER environment variable."
  exit 1
fi

if [ -z "$POSTGRES_PASSWORD" ]; then
  echo "You need to set the POSTGRES_PASSWORD environment variable."
  exit 1
else
  export PGPASSWORD=$POSTGRES_PASSWORD
fi

echo -e "[default]\naccess_key = ${S3_ACCESS_KEY_ID?}\nsecret_key = ${S3_SECRET_ACCESS_KEY?}\nhost_base = ${S3_ENDPOINT?}\nhost_bucket = %(bucket)s.${S3_ENDPOINT?}\nuse_https = True\ncache_file = /root/s3.cache\n" > /root/.s3cfg
