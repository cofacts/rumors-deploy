# rumors-deploy

Deployment scripts for g0v rumors project

## Configuration

We provides 2 versions of docker-compose.yml:

- `docker-compose.sample.yml`: Minimal setup to get all Cofacts service running on a single computer.
- `docker-compose.production.yml`: The actual setup (with secrets redacted) that is running on cofacts.g0v.tw . The differences are:
  - `nginx` is added as a reverse-proxy and serves https certificates.
  - `line-bot-zh` will be connected to AWS Cloudwatch logs, so you may need to [setup AWS credential accordingly](https://wdullaer.com/blog/2016/02/28/pass-credentials-to-the-awslogs-docker-logging-driver-on-ubuntu/).

Before moving to next step, you are expected to create your own `docker-compose.yml` using the above mentioned file as reference.

Explanation of each environment variables are in `.env.sample` of the corresponding [repository](https://github.com/cofacts/).

## Prerequisites

1. docker & docker-compose
2. git

## Deploy steps

0. `su` to appropriate user (for instance, `docker`)
1. Clone this repo on production server
2. Make a duplicate of `env-files.sample` directory and rename to `env-files`
2. Make necessary changes to `docker-compose.yml` and files in `volumes/`
3. `docker-compose up -d`

If you want ot run the whole Cofacts on the laptop, you may find this note useful:
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
