# Main Master Repository

## What do to

Clone this reposotory on your device then clone to this folder other Master-* prefix repositories

## How to run

First clone [ELK-Monitoring](https://github.com/yachoo2606/Master-ELK-monitoring) and [Master-Service-Registry](https://github.com/yachoo2606/Master-Service-Registry) and [Master-Producer](https://github.com/yachoo2606/master_producer) then run docker compose to create docker network where service registry and producers will works

Then run:

```
docker compose --env-file ELK-monitoring/.env down -v && docker compose --env-file ELK-monitoring/.env build --no-cache && docker compose --env-file ELK-monitoring/.env up --force-recreate -d
```
