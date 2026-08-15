# 17. Sharing, deploying, backing up, and restoring an iHRIS database

This chapter answers a common real-world situation:

> “I already have an iHRIS database. How do I securely give it to another
> administrator so they can deploy and use it? How do I return to a previous
> database if menus or functions disappear? How do I automate backups?”

The examples assume the iHRIS 5.1 Docker stack in this tutorial, with HAPI FHIR
using PostgreSQL database `hapi` and database user `admin`. Change container,
database, user, and path names to match your environment.

## 17.1 First understand what must be handed over

A database file alone may not reproduce the system. A complete iHRIS release
has several matching parts:

| Item | Why it matters |
|---|---|
| PostgreSQL/HAPI FHIR backup | Employees, roles, FHIR configuration and resource history |
| iHRIS application version | The backend/frontend code that understands the data |
| Country configuration version | Profiles, pages, questionnaires, roles, reports and workflows |
| Keycloak backup/configuration | Users, clients, groups and authentication settings |
| Uploaded files/documents | Attachments may live outside PostgreSQL |
| Deployment configuration | Image versions, service names, ports and volumes |
| Secret inventory | Identifies required secrets without exposing them in the package |
| Search/reindex procedure | Elasticsearch is normally rebuilt or restored separately |
| Release manifest | Proves which versions belong together |

If you restore a 2025 database into a different 2026 application/configuration,
menus or workflows can still be missing or incompatible. Restore or deploy a
**tested matching version set**.

## 17.2 Never share a live HR database casually

iHRIS backups can contain names, identifiers, employment history, contact
details, qualifications, disciplinary information, and authentication-related
data. Treat every backup as highly sensitive.

Do not upload a real backup to:

- a public or private GitHub repository;
- an unprotected Google Drive/Dropbox link;
- WhatsApp, ordinary email, or public file-transfer sites;
- a developer laptop without full-disk encryption and approval;
- a shared server directory readable by other users.

Before sharing, obtain authorization and record:

- data owner and approving officer;
- sender and named recipient;
- purpose and allowed environment;
- transfer method;
- encryption and key-sharing method;
- checksum;
- retention/deletion deadline;
- whether production personal data is truly required.

Prefer an anonymized or synthetic database for development and training.

## 17.3 Create a PostgreSQL backup from Docker

Create a protected directory:

```bash
sudo install -d -m 700 -o "$USER" -g "$USER" /var/backups/ihris
cd /path/to/iHRIS
```

Create a PostgreSQL custom-format backup:

```bash
docker compose exec -T db \
  pg_dump -U admin -d hapi \
  --format=custom --compress=6 \
  > /var/backups/ihris/hapi-$(date -u +%Y%m%dT%H%M%SZ).backup
```

Why use custom format?

- `pg_restore` can inspect and selectively restore it;
- it is compressed;
- restoration is more flexible than plain SQL;
- it supports parallel restore in suitable environments.

Confirm that the command succeeded and file is not empty:

```bash
ls -lh /var/backups/ihris
file /var/backups/ihris/hapi-*.backup
```

List the archive contents without restoring it:

```bash
docker compose exec -T db pg_restore -l \
  < /var/backups/ihris/hapi-YYYYMMDDTHHMMSSZ.backup \
  | head -50
```

The file existing is not enough. Check the exit status and logs in automation.

## 17.4 Native PostgreSQL backup

If PostgreSQL is installed directly on Linux:

```bash
sudo -u postgres pg_dump \
  --format=custom --compress=6 \
  --dbname=hapi \
  --file=/var/backups/ihris/hapi-$(date -u +%Y%m%dT%H%M%SZ).backup
```

If the database is remote, use a `.pgpass` file owned by the backup user with
permission `0600`; do not put the password directly in the cron command.

Example `.pgpass` format:

```text
database-host:5432:hapi:backup_user:REPLACE_WITH_SECRET
```

## 17.5 Create a release manifest

Place a non-secret text manifest beside the backup:

```text
System: iHRIS Rwanda
Backup UTC: 2026-08-15T06:00:00Z
iHRIS application/image: ihris/ihris:<PINNED-TAG-OR-DIGEST>
HAPI FHIR: 6.1.0
PostgreSQL major version: <VERSION>
Elasticsearch/Kibana: 7.17.6
Country configuration release: rwanda-config-1.0.0
Database name: hapi
Expected FHIR base path: /fhir
Keycloak realm export included: yes/no
Uploaded file archive included: yes/no
Backup SHA-256: <CHECKSUM>
Created by: <AUTHORIZED OPERATOR>
Change/request reference: <TICKET>
```

Generate a checksum:

```bash
sha256sum /var/backups/ihris/hapi-YYYYMMDDTHHMMSSZ.backup \
  > /var/backups/ihris/hapi-YYYYMMDDTHHMMSSZ.backup.sha256
```

The recipient verifies it after transfer:

```bash
sha256sum -c hapi-YYYYMMDDTHHMMSSZ.backup.sha256
```

## 17.6 Encrypt before transfer

One option is GPG symmetric encryption:

```bash
gpg --symmetric --cipher-algo AES256 \
  --output hapi-YYYYMMDDTHHMMSSZ.backup.gpg \
  hapi-YYYYMMDDTHHMMSSZ.backup
```

For repeatable organizational use, recipient public-key encryption or a managed
key-management service is preferable. Send the decryption key through a
separate approved channel. Never place the encrypted file and password in the
same email/message.

After confirming the encrypted copy, transfer through approved SFTP/SCP,
managed object storage with restricted short-lived access, or encrypted media.

Example SCP over an approved private/VPN route:

```bash
scp hapi-YYYYMMDDTHHMMSSZ.backup.gpg \
  authorized-admin@new-server:/srv/ihris-handover/
```

## 17.7 What the recipient should receive

```text
ihris-handover/
├── hapi-YYYYMMDDTHHMMSSZ.backup.gpg
├── hapi-YYYYMMDDTHHMMSSZ.backup.gpg.sha256
├── RELEASE-MANIFEST.txt
├── RESTORE-RUNBOOK.md
├── country-config-source-or-release/
├── deployment-compose-and-proxy-files/
├── keycloak-export-encrypted/        if required
└── uploaded-files-encrypted/         if required
```

Do not include `.env` or plaintext secrets. Deliver required production secrets
through a protected secret-management procedure.

## 17.8 Deploying the shared database on another server

### Step 1: provision the new server

Install the tested Docker/Compose versions, configure firewall, storage, DNS,
TLS, time synchronization, backup destination and monitoring. Do not expose
PostgreSQL, Redis, Elasticsearch or raw FHIR administration publicly.

### Step 2: deploy matching application configuration

Use the release manifest to check out/pull the matching iHRIS and Rwanda
configuration versions. Create environment secrets independently. Do not start
live traffic yet.

### Step 3: start only the database first

```bash
cd /srv/ihris
docker compose up -d db
docker compose exec db pg_isready -U admin -d hapi
```

### Step 4: decrypt and verify backup

```bash
gpg --output hapi.backup \
  --decrypt hapi-YYYYMMDDTHHMMSSZ.backup.gpg

sha256sum hapi.backup
```

Compare the hash to the approved manifest. Keep file permissions restricted:

```bash
chmod 600 hapi.backup
```

### Step 5: restore into an empty database

For a new disposable target, confirm you are on the correct server before any
drop operation:

```bash
hostname
pwd
docker compose ps
```

Stop applications that could reconnect/write:

```bash
docker compose stop ihris fhir
```

Terminate existing connections, then recreate the target database:

```bash
docker compose exec -T db psql -U admin -d postgres \
  -c "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname='hapi' AND pid <> pg_backend_pid();"

docker compose exec -T db dropdb -U admin --if-exists hapi
docker compose exec -T db createdb -U admin hapi
```

Restore:

```bash
docker compose exec -T db pg_restore \
  -U admin -d hapi \
  --no-owner --no-privileges --exit-on-error \
  < hapi.backup
```

The drop/recreate commands are destructive. Use them only on the confirmed
target during an approved restore. If the database/user differs, substitute
the correct values.

### Step 6: start the FHIR server and validate it

```bash
docker compose up -d fhir
docker compose logs -f --tail=200 fhir
```

In another terminal:

```bash
curl http://localhost:8080/fhir/metadata
curl 'http://localhost:8080/fhir/Practitioner?_summary=count'
curl 'http://localhost:8080/fhir/PractitionerRole?_summary=count'
curl 'http://localhost:8080/fhir/Location?_summary=count'
```

### Step 7: start remaining services

```bash
docker compose up -d redis es kibana ihris
docker compose ps
docker compose logs --tail=200 ihris
```

### Step 8: rebuild/validate search and reports

Elasticsearch is a derived reporting/search store in many iHRIS deployments.
Use the reindex/refresh process supported by the exact iHRIS/HAPI version.
Do not assume restoring PostgreSQL automatically recreates every Elasticsearch
document. Validate FHIR counts against iHRIS reports and dashboards.

### Step 9: restore identity and uploaded files

Restore/import the compatible Keycloak realm/database and uploaded files using
their separate runbooks. Update Keycloak HTTPS URLs/redirect URIs for the new
host. Test accounts and permissions before allowing users.

### Step 10: acceptance checks

- login works over HTTPS;
- employee count matches the source manifest;
- sample employees show personal data and roles correctly;
- locations/organizations are present;
- menus, questionnaires, roles and workflows appear;
- location-based access works;
- reports reconcile with FHIR;
- attachments open;
- audit/history is available;
- a new test record can be created and found;
- automated backup succeeds on the new server.

## 17.9 Restoring a previous database when menus/functions disappear

iHRIS menus and functions may depend on FHIR configuration resources such as
`Parameters`, `Basic` page/role/task/report resources, `Questionnaire`,
`StructureDefinition`, `CodeSystem`, `ValueSet`, and `Library` workflow
resources. They may also depend on matching backend/frontend code.

Before restoring an old database, diagnose:

1. Did an application/configuration release change?
2. Were configuration resources deleted or overwritten?
3. Is the logged-in user missing a role/task?
4. Did FSH/resource loading fail?
5. Is the menu missing for everyone or one user?
6. Are browser assets old/cached?
7. Is FHIR healthy and reachable?
8. Are configuration resources present in FHIR?

Example read-only counts/searches:

```bash
curl 'http://localhost:8080/fhir/Parameters?_summary=count'
curl 'http://localhost:8080/fhir/Basic?_summary=count'
curl 'http://localhost:8080/fhir/Questionnaire?_summary=count'
curl 'http://localhost:8080/fhir/StructureDefinition?_summary=count'
```

If only one approved configuration package is missing, reloading that exact
tested package can be safer than rolling back the whole employee database.
However, do not blindly reload starter resources into production; stable IDs
and package compatibility must be known.

If a full rollback is approved:

1. block user access/enter maintenance mode;
2. create a fresh safety backup of the broken current database;
3. preserve relevant logs and release/configuration versions;
4. verify the previous backup checksum and restore-test status;
5. deploy the application/configuration version matching that backup;
6. restore PostgreSQL using the approved procedure;
7. restore matching Keycloak/files if needed;
8. rebuild search indexes;
9. validate menus, employees, roles, reports and audit history;
10. document data entered between backup time and rollback time.

Restoring yesterday's database loses or forks changes made after that backup.
Business owners must decide how to reconcile those changes.

## 17.10 Automated daily Docker backup with cron

This repository includes
[`examples/backup_ihris_docker.sh`](../examples/backup_ihris_docker.sh).
Install it outside the application repository so a Git pull cannot overwrite
operations scripts:

```bash
sudo install -d -m 750 /opt/ihris-ops
sudo install -m 750 examples/backup_ihris_docker.sh \
  /opt/ihris-ops/backup_ihris_docker.sh

sudo install -d -m 700 /var/backups/ihris
```

Edit only these variables in the installed copy:

```bash
COMPOSE_DIR="/srv/ihris"
BACKUP_DIR="/var/backups/ihris"
DB_SERVICE="db"
DB_NAME="hapi"
DB_USER="admin"
RETENTION_DAYS="30"
```

Test manually:

```bash
sudo /opt/ihris-ops/backup_ihris_docker.sh
sudo ls -lh /var/backups/ihris
sudo tail -100 /var/log/ihris-backup.log
```

Open root's crontab:

```bash
sudo crontab -e
```

Run daily at 02:15 server time:

```cron
15 2 * * * /opt/ihris-ops/backup_ihris_docker.sh >> /var/log/ihris-backup.log 2>&1
```

Run weekly verification/listing on Sunday at 04:30:

```cron
30 4 * * 0 /opt/ihris-ops/verify_latest_ihris_backup.sh >> /var/log/ihris-backup-verify.log 2>&1
```

Cron uses a limited environment. The sample scripts set a safe `PATH` and use
absolute directories. Ensure Docker is available to the cron user.

## 17.11 Retention and off-site copies

Local backups do not protect against server theft, disk failure, ransomware or
datacenter loss. Follow a policy such as 3-2-1:

- at least three copies;
- on two storage types/systems;
- at least one off-site/offline or logically isolated copy.

Use daily/weekly/monthly retention appropriate to legal and recovery needs.
Deleting files older than 30 days is safe only when off-site copies and policy
permit it.

## 17.12 Monitoring backup success

Monitor more than cron execution. Alert when:

- no new backup appears by the expected time;
- file size is zero or unexpectedly small/large;
- `pg_dump` returns nonzero;
- checksum/list verification fails;
- backup disk is nearly full;
- off-site upload fails;
- the last successful restore test is too old.

Record backup start/end, source server/database, filename, size, checksum,
status and off-site-copy status—without logging database passwords.

## 17.13 Restore testing schedule

At least monthly or quarterly, depending on policy:

1. choose a recent backup;
2. verify checksum;
3. restore into an isolated server;
4. start compatible HAPI/iHRIS versions;
5. compare resource counts;
6. inspect several employees and roles;
7. test login, search, workflow and report;
8. document restore time and failures;
9. securely destroy the temporary restored environment.

A backup that has never been restored is only an assumption.

## 17.14 Windows note

If iHRIS runs through Docker Desktop on Windows, scheduled backup is more
reliable from WSL/Linux or a dedicated Linux server. Windows shell redirection
can mishandle binary custom-format dumps in some contexts. Alternatively install
matching PostgreSQL client tools and use `pg_dump.exe` with Task Scheduler.

Do not store automated production passwords in a publicly readable `.bat`
file. Use Windows Credential Manager, a protected service account, or an
approved secret solution.

## 17.15 Handover checklist

- [ ] authorization obtained;
- [ ] backup created successfully;
- [ ] archive contents checked;
- [ ] checksum generated;
- [ ] backup encrypted;
- [ ] matching version manifest written;
- [ ] country configuration included;
- [ ] Keycloak/files handled separately;
- [ ] secrets excluded from package;
- [ ] recipient and purpose recorded;
- [ ] approved secure transfer used;
- [ ] recipient verified checksum;
- [ ] restore completed in isolated environment;
- [ ] FHIR/UI/report counts reconciled;
- [ ] new automated backup tested;
- [ ] temporary plaintext copies securely removed;
