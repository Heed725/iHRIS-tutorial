# 2. Installing iHRIS with Docker

Docker is the easiest learning and staging method because it starts the related
services together.

## Requirements

- 64-bit Windows, Linux, or macOS
- Docker Desktop or Docker Engine + Compose plugin
- At least 4 GB RAM assigned to Docker; 6–8 GB is more comfortable
- At least 20 GB free disk space for images, logs and data
- Git and a web browser

Confirm:

```bash
docker --version
docker compose version
git --version
```

## Clone and start

```bash
git clone https://github.com/iHRIS/iHRIS.git
cd iHRIS
docker compose pull
docker compose up -d
```

`docker compose up -d` reads `docker-compose.yml`, creates a network and named
volumes, then starts the services in the background.

## Wait for readiness

```bash
docker compose ps
docker compose logs --tail=100 fhir
docker compose logs --tail=100 ihris
```

Containers being “Up” does not guarantee that applications are ready. HAPI
FHIR and Elasticsearch can take longer to initialize.

## Test every layer

```bash
curl -I http://localhost:3000
curl http://localhost:8080/fhir/metadata
curl http://localhost:9200
curl http://localhost:9200/_cluster/health?pretty
curl -I http://localhost:5601
```

If `curl` is unavailable on Windows, use `curl.exe` or open the URLs in a
browser.

## Understand the supplied ports

| Host port | Service | Purpose |
|---:|---|---|
| 3000 | iHRIS | Main application |
| 8080 | HAPI FHIR | FHIR API/test interface |
| 5432 | PostgreSQL | Database; expose only for local troubleshooting |
| 9200 | Elasticsearch | Search API; do not expose publicly |
| 5601 | Kibana | Dashboards; protect in production |

## Important Compose environment variables

The 5.1 file connects the iHRIS container to service names on the internal
Docker network:

```yaml
IHRIS_FHIR__BASE: http://fhir:8080/fhir
IHRIS_REDIS__URL: redis://redis
IHRIS_ELASTICSEARCH__BASE: http://es:9200
IHRIS_KIBANA__BASE: http://kibana:5601
```

Inside a container, `localhost` means that same container. Use `fhir`, `db`,
`redis`, `es`, and `kibana` to reach sibling services.

## Day-to-day commands

```bash
docker compose ps
docker compose logs -f --tail=200 ihris
docker compose restart ihris
docker compose stop
docker compose start
docker compose down
```

`docker compose down` removes containers and the network but normally retains
named volumes. `docker compose down -v` also removes volumes. Do not use `-v`
unless you intentionally want to erase the environment and have a backup.

## Update a test installation

```bash
git status
git pull
docker compose pull
docker compose up -d
```

For production, do not blindly pull latest images. Pin versions, back up first,
read migration notes, test the upgrade in staging, and keep a rollback plan.

## Native installation

The source also documents native installation with Node.js, Redis, Tomcat,
PostgreSQL, HAPI FHIR, SUSHI and search services. Use native installation only
when you understand service management, filesystem permissions, Java/Node
versions, reverse proxies, firewalls, TLS and backups. Docker is easier for a
beginner and produces a repeatable environment.
