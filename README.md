# rumors-deploy
Deployment scripts for g0v rumors project

## Prerequisites on production server

1. docker & docker-compose
2. git

## Deploy steps

1. Clone the repo to production server
2. Make necessary changes to files in `volumes/`
3. `docker-compose up -d`

## Updating any image

After image change: `docker-compose up --no-deps -d <name>`
After file in `volumes/` change: `docker-compose restart <name>`

where `<name>` can be `nginx`, `site`, `api` and `db`.

## Testing on local machine

Edit `/etc/hosts` to add:

```
127.0.0.1 rumors.g0v.tw
127.0.0.1 api.rumors.g0v.tw
```

Then `docker-compose up`, and visit `rumors.g0v.tw`.