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
2. Make necessary changes to `docker-compose.yml` and files in `volumes/`
3. `docker-compose up -d`

If you want ot run the whole cofacts on the laptop, you may find this note useful:
http://bit.ly/run-cofacts

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
5 0 1 * * docker run --rm -v /var/www/cofacts:/var/www/cofacts -v /etc/letsencrypt:/etc/letsencrypt -v /etc/ssl/certs:/etc/ssl/certs -v /var/log:/var/log certbot/certbot certonly --webroot -w /var/www/cofacts -d cofacts-api.g0v.tw -m <your@email> --agree-tos --non-interactive >> /var/log/cron.log 2>&1
0 1 1 * * cd /home/docker/rumors-deploy; /usr/local/bin/docker-compose restart nginx >> /var/log/cron.log 2>&1
5 0 * * * cd /home/docker/rumors-deploy; /usr/local/bin/docker-compose exec -T api node build/scripts/cleanupUrls.js >> /var/log/cron.log 2>&1
```

## Available Scripts

There are some handy scripts under `scripts/` directory:

### `check-url-resolver.sh`

Prints URL resolver stat from currently running url-resolver

### `update-line-bot-token.sh`

You should [install jq](https://stedolan.github.io/jq/download/) first.
sudo apt-get install jq

Use `heroku authorizations:create` to create a token that [expires at a specific time or never expires](https://help.heroku.com/PBGP6IDE/how-should-i-generate-an-api-key-that-allows-me-to-use-the-heroku-platform-api).

Get `CHANNEL_ID`, `CHENNEL_SECRET` form [line developer console](https://developers.line.biz/console/).

Get `APP_NAME` form heroku.