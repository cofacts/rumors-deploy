# rumors-deploy
Deployment scripts for g0v rumors project

## Prerequisites on production server

1. docker & docker-compose
2. git

## Deploy steps

0. `su` to appropriate user (for instance, `docker`)
1. Clone this repo on production server
2. Make necessary changes to files in `volumes/`
3. `docker-compose up -d`
4. `crontab -e` and add
```
0 0 1 * * docker run --rm -v /var/www/cofacts:/var/www/cofacts -v /etc/letsencrypt:/etc/letsencrypt -v /etc/ssl/certs:/etc/ssl/certs -v /var/log:/var/log certbot/certbot certonly --webroot -w /var/www/cofacts -d cofacts.g0v.tw -m <your@email> --agree-tos --non-interactive >> /var/log/cron.log 2>&1
0 0 1 * * docker run --rm -v /var/www/cofacts:/var/www/cofacts -v /etc/letsencrypt:/etc/letsencrypt -v /etc/ssl/certs:/etc/ssl/certs -v /var/log:/var/log certbot/certbot certonly --webroot -w /var/www/cofacts -d cofacts-api.g0v.tw -m <your@email> --agree-tos --non-interactive >> /var/log/cron.log 2>&1
0 0 2 * * cd /home/docker/rumors-deploy;  docker-compose restart nginx
```

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


## Testing on local machine

Edit `/etc/hosts` to add:

```
127.0.0.1 cofacts.g0v.tw
127.0.0.1 cofacts-api.g0v.tw
```

Then `docker-compose up`, and visit `cofacts.g0v.tw`.
