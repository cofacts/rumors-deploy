# rumors-deploy

Deployment scripts for g0v rumors project

## Configuration

We provide a minimal setup in `docker-compose.sample.yml` to get all Cofacts services running on a single computer for local execution and testing.

Explanation of each environment variables are in `.env.sample` of the corresponding [repository](https://github.com/cofacts/).

## Prerequisites

1. docker & docker-compose
2. git

## Deploy steps

0. `su` to appropriate user (for instance, `docker`)
1. Clone this repo on production server
2. Copy the `env-files.sample` directory to `env-files` and populate with your actual environment values:
   ```bash
   cp -r env-files.sample env-files
   # Edit files in env-files/ with your actual configuration values
   ```
3. Copy `docker-compose.sample.yml` to `docker-compose.yml` and make necessary changes to it and files in `volumes/` 
4. `docker compose up -d`

If you want ot run the whole Cofacts on the laptop, you may find this note useful:
<http://bit.ly/run-cofacts>

## Updating any image

After image change:

```bash
docker compose pull <name>
docker compose up --no-deps -d <name>
```

After changings file in `volumes/`:

```bash
docker compose restart <name>
```

where `<name>` can be `site`, `api` and `db`.

## Crontab setup

`crontab -e` and add:

```text
5 0 * * * cd /home/docker/rumors-deploy; /usr/local/bin/docker compose exec -T api node build/scripts/cleanupUrls.js >> /var/log/cron.log 2>&1
```

Optional mongodb backup

```text
0 0 * * * docker run -it --rm -v <key-file-for-gcs>:/home/db-backup/key.json \
  --env GCP_PROJECT_ID=<project-id> \
  --env GCS_BUCKET=<bucket> \
  --env MONGOURI=mongodb+srv://<username>:<password>@<host>/<db> \
  cofacts/mongodb-gsutil
```

To see [cofacts/mongodb-gsutil](https://github.com/cofacts/mongodb-gsutil).
