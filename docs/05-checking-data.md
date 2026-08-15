# 5. Checking data safely

## Start with the FHIR API

Confirm the server and FHIR version:

```bash
curl http://localhost:8080/fhir/metadata
```

Count resources without downloading all records:

```bash
curl 'http://localhost:8080/fhir/Practitioner?_summary=count'
curl 'http://localhost:8080/fhir/PractitionerRole?_summary=count'
curl 'http://localhost:8080/fhir/Location?_summary=count'
```

Search:

```bash
curl 'http://localhost:8080/fhir/Practitioner?identifier=EMP001'
curl 'http://localhost:8080/fhir/Practitioner?name=Example&_count=20'
curl 'http://localhost:8080/fhir/Location?name=Kigali&_count=20'
```

Fetch one resource after obtaining its UUID:

```bash
curl http://localhost:8080/fhir/Practitioner/UUID
```

Find roles for that person:

```bash
curl 'http://localhost:8080/fhir/PractitionerRole?practitioner=Practitioner/UUID'
```

Use URL encoding when parameters contain spaces or special characters. With
authentication, use a protected token or prompted credentials; avoid placing
production secrets in scripts and shell history.

## Understand a search result

FHIR search returns a `Bundle`:

```json
{
  "resourceType": "Bundle",
  "type": "searchset",
  "total": 1,
  "entry": [
    { "resource": { "resourceType": "Practitioner", "id": "..." } }
  ]
}
```

Check `total`, `entry`, and pagination links. `_count=20` means page size, not a
guaranteed total limit.

## Check through the iHRIS interface

Use the People page to search by identifier and name. Open the employee and
verify personal information, current role, facility and history. Then compare
with the FHIR response when diagnosing discrepancies.

## Check PostgreSQL without editing

Container health:

```bash
docker compose exec db pg_isready -U admin -d hapi
```

Open a SQL console:

```bash
docker compose exec db psql -U admin -d hapi
```

Inside PostgreSQL, use diagnostic commands such as:

```sql
\l
\dt
SELECT now();
```

Do not write hand-crafted `UPDATE` or `DELETE` statements against HAPI tables.
FHIR resource versioning and indexes can be corrupted or made inconsistent.

## Check Elasticsearch

```bash
curl http://localhost:9200/_cluster/health?pretty
curl http://localhost:9200/_cat/indices?v
```

Interpret common states:

- green: primary and replica shards assigned;
- yellow: primaries available, some replicas unavailable—common on a
  single-node development cluster;
- red: some primary shards unavailable; investigate immediately.

If FHIR has the employee but a report does not, check iHRIS logs and index
refreshing before changing the employee record.

## Data-quality checks

Regularly check:

- missing or duplicate employee identifiers;
- practitioners without roles;
- roles pointing to missing/inactive locations;
- overlapping active employment periods;
- invalid dates or end date before start date;
- free text where a controlled code should be used;
- inactive facilities with active workers;
- records not visible because of location-based permission;
- FHIR counts that disagree with report/index counts.

Perform corrections through approved FHIR/UI workflows and keep audit history.
