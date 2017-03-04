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
127.0.0.1 rumors.g0v.tw
127.0.0.1 api.rumors.g0v.tw
```

Then `docker-compose up`, and visit `rumors.g0v.tw`.
