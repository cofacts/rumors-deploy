# rumors-deploy
Deployment scripts for g0v rumors project

## Configuration

We provides 2 versions of docker-compose.yml:
- `docker-compose.sample.yml`: Minimal setup to get all Cofacts service running on a single computer.
- `docker-compose.production.yml`: The actual setup (with secrets redacted) that is running on cofacts.g0v.tw . The differences are:
    - We run productin LINE bot service on heroku, thus there is no `line-bot` and `redis` in `docker-compose.production.yml`
    - Additionally, `nginx` is added as a reverse-proxy and serves https certificates.

Before moving to next step, you are expected to create your own `docker-compose.yml` using the above mentioned file as reference.

Explanation of each environment variables are in `.env.sample` of the corresponding [repository](https://github.com/cofacts/).

## Prerequisites

1. docker & docker-compose
2. git

## Deploy steps

0. `su` to appropriate user (for instance, `docker`)
1. Clone this repo on production server
2. Make necessary changes to files in `volumes/`
3. `docker-compose up -d`

## Updating any image

After image change:
```
$ docker-compose pull <name>
$ docker-compose up --no-deps -d <name>
```

After changings file in `volumes/`:

```
$ docker-compose restart <name>
```

where `<name>` can be `nginx`, `site`, `api` and `db`.

## Crontab setup

`crontab -e` and add:
```
0 0 1 * * docker run --rm -v /var/www/cofacts:/var/www/cofacts -v /etc/letsencrypt:/etc/letsencrypt -v /etc/ssl/certs:/etc/ssl/certs -v /var/log:/var/log certbot/certbot certonly --webroot -w /var/www/cofacts -d cofacts.g0v.tw -m <your@email> --agree-tos --non-interactive >> /var/log/cron.log 2>&1
0 0 1 * * docker run --rm -v /var/www/cofacts:/var/www/cofacts -v /etc/letsencrypt:/etc/letsencrypt -v /etc/ssl/certs:/etc/ssl/certs -v /var/log:/var/log certbot/certbot certonly --webroot -w /var/www/cofacts -d cofacts-api.g0v.tw -m <your@email> --agree-tos --non-interactive >> /var/log/cron.log 2>&1
0 0 2 * * cd /home/docker/rumors-deploy;  docker-compose restart nginx
```

## Available Scripts

There are some handy scripts under `scripts/` directory:

### `check-url-resolver.sh`

Prints URL resolver stat from currently running url-resolver
