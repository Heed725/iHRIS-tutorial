# iHRIS 5 Beginner Tutorial

A practical, beginner-friendly guide to understanding, installing, deploying,
customizing, inspecting, securing, backing up, and troubleshooting iHRIS 5.
The worked example is **iHRIS Rwanda**, but the same method can be adapted for
another country.

> This tutorial is based on the iHRIS 5.1.0 source tree. iHRIS is a flexible
> platform, so a country implementation is a configured project—not merely a
> translated copy of the default application.

## Start here

| Your goal | Read this |
|---|---|
| Understand iHRIS and its software | [Architecture](docs/01-architecture.md) |
| Run it on a laptop or test server | [Docker installation](docs/02-docker-installation.md) |
| Build an iHRIS Rwanda implementation | [Rwanda customization](docs/03-rwanda-customization.md) |
| Know which files to edit | [Important files](docs/04-important-files.md) |
| Inspect employees and other data | [Checking data](docs/05-checking-data.md) |
| Put it on a production server | [Production deployment](docs/06-production-deployment.md) |
| Fix common failures | [Troubleshooting](docs/07-troubleshooting.md) |
| Back up, secure, and maintain it | [Operations and security](docs/08-operations-security.md) |
| Learn FHIR from the beginning | [FHIR practical guide](docs/09-fhir-practical-guide.md) |
| Set up a programmer workflow | [Development workflow](docs/10-development-workflow.md) |
| Import existing HR data | [Migration and bulk import](docs/11-migration-bulk-import.md) |
| Build reports and dashboards | [Reports and Elasticsearch](docs/12-reports-dashboards.md) |
| Configure users and permissions | [Keycloak and access control](docs/13-keycloak-access-control.md) |
| Integrate another system | [APIs and integrations](docs/14-apis-integrations.md) |
| Test before production | [Testing and quality assurance](docs/15-testing-quality-assurance.md) |
| Follow a complete implementation plan | [Rwanda project blueprint](docs/16-rwanda-project-blueprint.md) |
| Share, restore, and automate database backups | [Database handover and recovery](docs/17-database-handover-backup-restore.md) |

## What is iHRIS?

iHRIS is a human-resources information system designed for managing health
workforce information. A typical record includes a worker, identifiers,
employment role, facility, location, qualifications, training, licenses, and
other country-specific HR data.

iHRIS 5 stores its main information as **FHIR R4 resources**. FHIR is a health
data standard. Instead of thinking only in SQL tables, learn these core types:

- `Practitioner`: the person or employee.
- `PractitionerRole`: the employee's job, facility, period, and role.
- `Location`: country, province, district, facility, or another place.
- `Organization`: ministry, hospital, program, employer, or department.
- `Basic`: custom iHRIS data that does not use a standard FHIR resource.
- `Questionnaire` and `QuestionnaireResponse`: data-entry forms and responses.
- `CodeSystem` and `ValueSet`: controlled lists such as cadres, status, gender,
  contract type, qualification, and reason for separation.
- `StructureDefinition`: validation rules and profiles.
- `Parameters`: iHRIS configuration stored as FHIR data.

## The most important beginner idea

There are three different things that people often call “the database”:

1. **PostgreSQL** is the physical database used by HAPI FHIR.
2. **HAPI FHIR** is the supported API and data layer used to create/search
   resources.
3. **Elasticsearch** is a search/reporting index. It is not the authoritative
   employee database.

Use the FHIR API for normal data inspection and changes. Use PostgreSQL for
backup, restore, database administration, and carefully controlled diagnosis.
Do not manually edit HAPI FHIR tables to “fix” an employee.

## Quick local installation

Install Docker Desktop (Windows/macOS) or Docker Engine with Compose (Linux),
allocate at least 4 GB RAM, then:

```bash
git clone https://github.com/iHRIS/iHRIS.git
cd iHRIS
docker compose up -d
docker compose ps
```

Open:

```text
iHRIS:        http://localhost:3000
FHIR server:  http://localhost:8080/fhir
Elasticsearch http://localhost:9200
Kibana:       http://localhost:5601
```

The iHRIS 5.1 Docker documentation lists the demonstration login as
`admin@ihris.org` / `ihris`. Treat it as a development-only credential and
change it before exposing any system to a network.

Check all services:

```bash
docker compose ps
docker compose logs --tail=100 ihris
docker compose logs --tail=100 fhir
curl http://localhost:8080/fhir/metadata
curl http://localhost:9200/_cluster/health?pretty
```

Stop without deleting data:

```bash
docker compose stop
```

Start again:

```bash
docker compose start
```

Do **not** casually use `docker compose down -v`; `-v` removes named volumes and
can destroy your database and search data.

## Repository roadmap

```text
iHRIS/
├── docker-compose.yml          Local multi-service environment
├── ihris-backend/              Node.js/Express server and iHRIS logic
│   ├── app.js                  Backend application entry point
│   ├── routes/                 Core HTTP/API routes
│   ├── modules/                FHIR, security, reports and workflows
│   └── ihris-backend-site/     Template for a country/site backend
├── ihris-frontend/             Vue 2 and Vuetify user interface
│   ├── src/components/         Reusable UI components
│   ├── src/views/              Application screens
│   ├── src/locales/            Translations
│   └── public/                 Logos, flags and static assets
├── ig/input/fsh/               FHIR Shorthand definitions
├── resources/                  Roles, pages, reports and starter resources
├── tools/                      Resource loading and administration scripts
└── docs/                       Upstream administrator/developer/user docs
```

## A safe learning plan

1. Run the unmodified stack locally.
2. Inspect FHIR resources with read-only `GET` requests.
3. Copy the backend-site template into a country project.
4. Create Rwanda identifiers, locations, terminology, profiles, pages and
   questionnaires in source-controlled files.
5. Build FSH with SUSHI.
6. load resources into a disposable test FHIR server.
7. test one complete employee lifecycle.
8. add authentication, TLS, backups and monitoring.
9. deploy to staging and conduct user acceptance testing.
10. promote the tested release to production.

## Suggested 12-week beginner course

| Week | Practical outcome |
|---:|---|
| 1 | Understand containers, services, FHIR and the repository structure |
| 2 | Run iHRIS locally and diagnose startup failures |
| 3 | Read Practitioner, PractitionerRole and Location resources |
| 4 | Create a separate Rwanda site/configuration repository |
| 5 | Model identifiers, terminology and administrative locations |
| 6 | Build profiles and questionnaires with FSH/SUSHI |
| 7 | Configure pages, roles, tasks and approval workflows |
| 8 | Prepare and validate a small migration dataset |
| 9 | Build reports, reconcile counts and test permissions |
| 10 | Configure authentication, TLS, secrets and backups |
| 11 | Conduct performance, security and restore testing |
| 12 | Deploy staging, complete UAT and rehearse production cutover |

Each week should finish with evidence: commands used, screenshots, sample FHIR
resources, test results, a Git commit and a short operations note. Do not learn
directly on the live national database.

## Example: what “iHRIS Rwanda” means

Do not begin by renaming the logo. Begin with requirements:

- Who owns the system: ministry, agency, or facility network?
- Which administrative levels are required?
- What is the official employee identifier?
- Which cadres, professions, grades, employment statuses and contract types
  are authoritative?
- Which languages are required: Kinyarwanda, English, French, or others?
- Which roles may view, create, edit, approve, export, or delete data?
- What is the review/approval workflow?
- Which reports are legally and operationally required?
- Which systems must integrate with iHRIS?
- What are the retention, hosting, privacy, and disaster-recovery rules?

Then implement these requirements as FHIR terminology, profiles,
questionnaires, page/report configuration, role/task resources, translations,
and deployment configuration. The full worked approach is in
[Rwanda customization](docs/03-rwanda-customization.md).

## Never commit these values

- Production passwords
- Database connection passwords
- Keycloak administrator passwords
- OAuth client secrets or refresh tokens
- JWT/session secrets
- Private signing keys
- TLS private keys
- Real employee exports
- Production `.env` files or backup archives

The iHRIS template contains example/default credentials and placeholder secrets.
Copy the template, replace every secret, and inject production values using a
secret manager or protected environment variables.

## Useful commands cheat sheet

```bash
# containers
docker compose ps
docker compose logs -f ihris
docker compose restart ihris

# FHIR capability statement
curl http://localhost:8080/fhir/metadata

# count/search practitioners
curl 'http://localhost:8080/fhir/Practitioner?_summary=count'
curl 'http://localhost:8080/fhir/Practitioner?name=Alice&_count=20'
curl 'http://localhost:8080/fhir/Practitioner?identifier=EMP001'

# roles for one practitioner
curl 'http://localhost:8080/fhir/PractitionerRole?practitioner=Practitioner/UUID'

# build FHIR Shorthand
cd ig
sushi -s .

# load generated resources (from tools directory after npm install)
node load.js --server http://localhost:8080/fhir ../ig/fsh-generated/resources/*.json

# PostgreSQL backup from Docker
docker compose exec -T db pg_dump -U admin -d hapi -Fc > hapi.backup
```

## Version warning

This guide explains the iHRIS 5.1.0 layout, whose supplied Compose file pins
HAPI FHIR 6.1.0 and Elasticsearch/Kibana 7.17.6. Newer releases can change
configuration keys, Java/Node requirements, authentication, container names,
or upgrade procedures. Pin tested versions and read release notes before
upgrading.

## License and attribution

This tutorial is an independent learning guide based on the open-source iHRIS
project. Consult the upstream iHRIS repository and license before distributing
a modified implementation.
