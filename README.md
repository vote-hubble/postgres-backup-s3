<img src="https://cdn.hubble.vote/branding/mono-dark/logo-title.png" width="250px" alt="Hubble logo" />

Hubble is the all-in-one solution for your campaigns contact management, financial accounting, and communication needs.
With Hubble you can manage your campaign for local, state, or national office all in one place.

# Postgres Data Doctor

This project uses docker to periodically backup a PostgreSQL database following the 3-2-1 backup strategy. Backups are saved to a mounted directory, and then synced an off-site S3 bucket. Restoring from a backup is also supported.

This project is a fork of @eeshugerman's [postgres-backup-s3](https://github.com/eeshugerman/postgres-backup-s3), which was a fork and re-structuring of @schickling's [postgres-backup-s3](https://github.com/schickling/dockerfiles/tree/master/postgres-backup-s3) and [postgres-restore-s3](https://github.com/schickling/dockerfiles/tree/master/postgres-restore-s3).

@jmadkins made the decision not to merge these changes into @eeshugerman's repo since it was a drastic change in implementation.

# Usage

## Backup

```yaml
services:
  postgres:
    image: postgres:16
    environment:
      POSTGRES_USER: user
      POSTGRES_PASSWORD: password

  doctor:
    image: vote-hubble/psql-data-doctor:16
    environment:
      CRON_SCHEDULE: "0 4 * * *"
      S3_REGION: nyc1
      S3_ACCESS_KEY_ID: key
      S3_SECRET_ACCESS_KEY: secret
      S3_BUCKET: my-bucket
      S3_PREFIX: backups
      S3_ENDPOINT: https://nyc3.digitaloceanspaces.com
      POSTGRES_HOST: postgres
      POSTGRES_DATABASE: dbname
      POSTGRES_USER: user
      POSTGRES_PASSWORD: password
      PASSPHRASE: passphrase # optional
```

- The `CRON_SCHEDULE` variable controls backup frequency.
- If `PASSPHRASE` is provided, the backup will be encrypted using GPG.
- Run `docker exec <container name> sh backup.sh` to trigger a backup ad-hoc.
- Set `CALLBACK_URL` to send a message to Slack

## Restore

> [!CAUTION]
> DATA LOSS! All database objects will be dropped and re-created.

```sh
# from latest backup
docker exec <container name> sh restore.sh
# from specific backup
docker exec <container name> sh restore.sh <timestamp>
```

# Development

## Build the image locally

`ALPINE_VERSION` determines Postgres version compatibility. See [`build-and-push-images.yml`](.github/workflows/build-and-push-images.yml) for the latest mapping.

```sh
DOCKER_BUILDKIT=1 docker build --build-arg ALPINE_VERSION=3.16 .
```

## Run a simple test environment with Docker Compose

```sh
cp template.env .env
# fill out your secrets/params in .env
docker compose up -d
```
