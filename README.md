# rumors-deploy

Deployment scripts for g0v rumors project

## Configuration

We provide a single `docker-compose.sample.yml` file which contains definitions for both local development and production deployments using Docker Compose **Profiles**.

- **`dev` profile**: Minimal setup to get Cofacts services running locally on a single computer.
- **`prod` profile**: The actual setup that is running on cofacts.g0v.tw. It includes:
  - `nginx` added as a reverse-proxy to serve HTTPS certificates.
  - Logging configured to use GCP Logging.

Before moving to the next step, you are expected to create your own `docker-compose.yml` by copying the sample file. You should also copy `.env.sample` to `.env` to configure variables used within the `docker-compose.yml` itself (like GCP logging configurations).

Explanation of individual service environment variables can be found in the `.env.sample` of the corresponding [repository](https://github.com/cofacts/).

## Prerequisites

1. docker & docker-compose (Modern version that supports profiles and healthchecks)
2. git

## Deploy steps

0. `su` to appropriate user (for instance, `docker`)
1. Clone this repo on production server
2. Copy the `env-files.sample` directory to `env-files` and populate with your actual environment values:
   ```bash
   cp -r env-files.sample env-files
   # Edit files in env-files/ with your actual configuration values
   ```
3. Copy the sample files to create your active configuration:
   ```bash
   cp docker-compose.sample.yml docker-compose.yml
   cp .env.sample .env
   # Edit .env with your GCP project and meta ID if using production logging
   ```
4. Make necessary changes to `docker-compose.yml` and files in `volumes/`.
5. Start the services for your desired environment using the `--profile` flag:
   ```bash
   # For local development
   docker compose --profile dev up -d

   # For production
   docker compose --profile prod up -d
   ```

If you want to run the whole Cofacts on the laptop, you may find this note useful:
<http://bit.ly/run-cofacts>

## Updating any image

After image change:

```bash
docker-compose pull <name>
docker-compose up --no-deps -d <name>
```

After changings file in `volumes/`:

```bash
docker-compose restart <name>
```

where `<name>` can be `nginx`, `site`, `api` and `db`.

## Crontab setup

`crontab -e` and add:

```text
0 0 1 * * docker run --rm -v /var/www/cofacts:/var/www/cofacts -v /etc/letsencrypt:/etc/letsencrypt -v /etc/ssl/certs:/etc/ssl/certs -v /var/log:/var/log certbot/certbot certonly --webroot -w /var/www/cofacts -d cofacts.g0v.tw -m <your@email> --agree-tos --non-interactive >> /var/log/cron.log 2>&1
5 0 1 * * docker run --rm -v /var/www/cofacts:/var/www/cofacts -v /etc/letsencrypt:/etc/letsencrypt -v /etc/ssl/certs:/etc/ssl/certs -v /var/log:/var/log certbot/certbot certonly --webroot -w /var/www/cofacts -d cofacts-api.g0v.tw -m <your@email> --agree-tos --non-interactive >> /var/log/cron.log 2>&1
0 1 1 * * cd /home/docker/rumors-deploy; /usr/local/bin/docker-compose restart nginx >> /var/log/cron.log 2>&1
5 0 * * * cd /home/docker/rumors-deploy; /usr/local/bin/docker-compose exec -T api node build/scripts/cleanupUrls.js >> /var/log/cron.log 2>&1
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
