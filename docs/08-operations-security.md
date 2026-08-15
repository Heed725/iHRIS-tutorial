# 8. Backups, security and maintenance

## Back up all important state

A complete recovery plan includes:

- PostgreSQL/HAPI FHIR database;
- country configuration source and Git history;
- deployed environment configuration (encrypted/protected);
- Keycloak realm/database and client configuration;
- uploaded documents and other persistent files;
- TLS and signing material through secure key backup procedures;
- Elasticsearch only if rebuilding it is not reliable/fast enough;
- an inventory of image/application versions.

Redis sessions are usually disposable, but document your use of Redis before
assuming this.

## PostgreSQL backup in the example Docker stack

```bash
mkdir -p backups
docker compose exec -T db pg_dump -U admin -d hapi -Fc > backups/hapi-$(date +%F-%H%M).backup
```

Check that the file is non-empty and copy it to protected off-server storage.
On Windows PowerShell, use a backup method that preserves binary output, or run
`pg_dump` directly with PostgreSQL client tools.

## Restore rehearsal

Never wait for an emergency to test restore. Restore into an isolated test
environment, start HAPI FHIR against the restored database, verify counts and
sample employees, test iHRIS login/search, and document elapsed recovery time.

## Security baseline

- HTTPS only for users and external integrations.
- Private network for PostgreSQL, Redis, FHIR administration, Elasticsearch
  and Kibana.
- Strong unique secrets stored outside Git.
- Least-privilege roles and location constraints.
- MFA for privileged users when supported/approved.
- Brute-force protection and session limits.
- Timely supported security updates after staging tests.
- Centralized logs with protected access and retention.
- Audit privileged operations and review them.
- Encrypt backups and control restoration permission.
- Remove demo accounts and disable unused services/routes.
- Regularly review users, service accounts, integrations and exports.

## Monitoring

Monitor:

- public HTTPS availability and certificate expiry;
- iHRIS/FHIR response time and error rate;
- container restarts;
- PostgreSQL connections, size and backup success;
- disk and inode usage;
- Elasticsearch cluster state/indexing failures;
- Redis availability;
- CPU, RAM and JVM heap;
- authentication failures and privileged actions;
- data synchronization/index lag.

An alert is useful only if it has an owner and response procedure.

## Upgrade procedure

1. Read iHRIS and dependency release notes.
2. Inventory current versions and custom changes.
3. Create and verify backups.
4. Reproduce production in staging.
5. Upgrade one controlled version set.
6. Run automated and acceptance tests.
7. Rehearse rollback.
8. Approve a change window.
9. deploy and monitor.
10. validate counts, login, search, workflows and reports.

Do not independently upgrade HAPI FHIR, Elasticsearch, Kibana, Node, Keycloak
or the iHRIS application without checking compatibility.

## Routine schedule

Daily: health checks, failed jobs, backup results, disk and security alerts.

Weekly: restore sample/check backup integrity, review error logs, index health,
inactive accounts and unusual exports.

Monthly: patch review, permission review, capacity trend, certificate status,
data-quality report and documentation update.

Quarterly: full restore rehearsal, disaster-recovery exercise, privileged-access
review, vulnerability assessment and country configuration release review.

For a complete database handover, deployment, cron backup, previous-database
recovery, and validation procedure, continue to
[Database handover and recovery](17-database-handover-backup-restore.md).
