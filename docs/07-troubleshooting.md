# 7. Troubleshooting iHRIS

Use a layered method. Do not change several components at once.

## First five commands

```bash
docker compose ps
docker compose logs --tail=200 ihris
docker compose logs --tail=200 fhir
curl http://localhost:8080/fhir/metadata
curl http://localhost:9200/_cluster/health?pretty
```

Record the exact error, time, URL, affected user, employee ID, browser, recent
change and whether the problem affects everyone.

## Main page does not open

Check:

```bash
docker compose ps ihris
docker compose logs --tail=300 ihris
curl -v http://localhost:3000
```

Likely causes: container crash, port conflict, backend startup failure, missing
configuration, unreachable FHIR/Redis, permissions, or reverse-proxy error.

## iHRIS starts but shows no pages/configuration

Look for startup log messages showing autoloaded resources. Confirm:

- `resources/` exists inside the expected image/container path;
- FHIR is reachable from inside the iHRIS container;
- generated FSH resources were loaded;
- the configured Parameters resource exists;
- the user has the correct role/tasks.

Test internal DNS/networking:

```bash
docker compose exec ihris node -e "fetch('http://fhir:8080/fhir/metadata').then(r=>console.log(r.status)).catch(console.error)"
```

## FHIR returns connection refused

Check the `fhir` container and PostgreSQL dependency. Inside Docker, use
`http://fhir:8080/fhir`, not `http://localhost:8080/fhir` from the iHRIS
container.

## FHIR returns 401/403

Authentication or authorization failed. Check token expiry, Keycloak client,
role/task assignment, FHIR credentials, proxy headers and clock synchronization.
Do not disable security as a production fix.

## Login loop or invalid redirect URI

Check the public HTTPS URL, Keycloak client redirect URIs, proxy forwarding
headers, cookie security/domain settings, time synchronization and whether the
browser can reach Keycloak.

## Employee exists in FHIR but not reports

Check Elasticsearch health, indexes, iHRIS report refresh/index logs, mappings,
date/terminology fields and location-based filters. Confirm the report query
expects the same profile and field paths as the resource.

## Elasticsearch uses too much memory

The example Compose configuration assigns `-Xms512m -Xmx512m`, but actual
needs depend on data and reports. Check Docker memory, host RAM, swap pressure,
disk, shard count and logs. Do not increase heap beyond available capacity.

## SUSHI build errors

```bash
sushi --version
cd ig
sushi -s .
```

Read the first error, not only the final count. Common causes: duplicate IDs,
invalid canonical URL, unknown parent profile, wrong indentation/syntax,
missing dependency or terminology reference.

## Frontend change not visible

You may have edited Vue source while the backend serves an old compiled build.
Run lint/build, deploy the new `dist` output to the site `public` directory,
restart the backend if required, and hard-refresh the browser. Never edit only
hashed compiled JavaScript files.

## PostgreSQL volume full

Stop nonessential writes, identify volume/log growth, create/verify a backup,
expand storage safely, and investigate retention. Do not delete arbitrary HAPI
tables or volume files.

## Port already in use

Linux:

```bash
ss -ltnp | grep ':3000\|:8080\|:9200\|:5601\|:5432'
```

Windows:

```bat
netstat -ano | findstr :3000
```

Change the host-side Compose port only if needed; internal container ports and
service-to-service URLs usually remain unchanged.

## Safe escalation package

When asking for help, provide sanitized:

- iHRIS/version and deployment method;
- exact command and error;
- `docker compose ps`;
- relevant timestamped logs;
- FHIR `OperationOutcome`;
- configuration keys without secret values;
- recent changes;
- expected versus actual result.

Never paste passwords, tokens, private keys, employee data, or full production
configuration into public issues.
