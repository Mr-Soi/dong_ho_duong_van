\
param(
  [switch]$Import
)

$compose = "docker-compose.prod.yml"
$envfile = ".env.prod"

if ($Import) {
  docker compose -f $compose --env-file $envfile run --rm --no-deps import
}

docker compose -f $compose --env-file $envfile up -d caddy web
docker compose -f $compose --env-file $envfile ps
