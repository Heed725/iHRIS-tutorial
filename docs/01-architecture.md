# 1. Understanding the iHRIS architecture

## Request and data flow

When a user opens iHRIS, the browser loads the Vue frontend. The frontend calls
the Node/Express backend. The backend validates the session and permissions,
then reads or writes FHIR resources through HAPI FHIR. PostgreSQL persists HAPI
FHIR data. Redis supports sessions/caching. Elasticsearch and Kibana support
search, reporting and dashboards.

```text
Browser → Vue interface → Node/Express backend → HAPI FHIR → PostgreSQL
                              │                    │
                              ├→ Redis             └→ FHIR resources
                              └→ Elasticsearch → Kibana
```

Authentication may be handled by local/passport routes or Keycloak depending
on the implementation. iHRIS also supports configurable modules and workflows.

## Components in beginner language

### Vue and Vuetify

Vue renders pages and forms. Vuetify supplies visual components. Editing Vue
changes the user interface; it does not change the meaning of stored data.

### Node.js and Express

The backend serves the compiled frontend, proxies/handles FHIR operations,
applies authorization, processes questionnaires, runs workflows, builds
reports, and integrates with supporting services.

### HAPI FHIR R4

HAPI FHIR is the main application data API. A request such as:

```http
GET /fhir/Practitioner?identifier=EMP001
```

returns a FHIR `Bundle`, not a simple SQL row. The employee is normally spread
across related resources.

### PostgreSQL

HAPI FHIR stores resource versions, indexes and references in PostgreSQL.
Direct SQL is useful for database health and backup but unsafe for ordinary
business-data edits.

### Redis

Redis provides fast temporary/session storage. Losing Redis may log users out;
it should not be treated as the permanent employee database.

### Elasticsearch and Kibana

Elasticsearch stores report/search indexes. Kibana visualizes indexed data.
If a dashboard is empty while FHIR contains records, the indexing pipeline may
be the problem.

### FSH and SUSHI

FHIR Shorthand (`.fsh`) is a readable language for defining profiles,
extensions, terminology, examples and implementation-guide resources. SUSHI
compiles `.fsh` into FHIR JSON. Edit the source FSH and rebuild; do not treat
generated JSON as the only source of truth.

### Keycloak

Keycloak is an identity and access-management server. It handles users,
sessions, clients and authentication policies, while iHRIS FHIR role/task
resources describe application permissions. Understand both layers.

## The employee relationship

A simple employee may look like:

```text
Practitioner/123
├── identifier: EMP001
├── name: Example Employee
├── gender and birth date
├── PractitionerRole/456 → job + facility + employment period
├── Basic/... → country-specific HR records
└── QuestionnaireResponse/... → submitted workflow/form data
```

This is why deleting only the Practitioner can fail or leave orphan data.

## Source code versus runtime data

| Source-controlled configuration | Runtime data |
|---|---|
| FSH profiles and terminology | Employee records |
| Page/report definitions | Questionnaire responses |
| Roles and task definitions | User activity/audit events |
| Vue components/translations | Current facilities/positions |
| Docker/deployment configuration | Search indexes and sessions |

Keep source configuration in Git. Back up runtime data separately.
