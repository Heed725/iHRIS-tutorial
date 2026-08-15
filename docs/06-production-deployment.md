# 6. Production deployment

## Recommended topology

Use a Linux server or managed container platform. Put a reverse proxy in front
of iHRIS, terminate TLS there, and expose only HTTPS. Keep PostgreSQL, Redis,
FHIR administration, Elasticsearch and Kibana on private networks unless a
specific protected access path is required.

```text
Internet → firewall/load balancer → HTTPS reverse proxy → iHRIS backend
                                                   ├→ FHIR → PostgreSQL
                                                   ├→ Redis
                                                   └→ Elasticsearch/Kibana
```

## Separate environments

Maintain development, staging and production. Never test schema/config changes
for the first time against production. Use different databases, credentials,
URLs, encryption keys and identity-provider clients.

## Deployment checklist

1. Pin image and application versions.
2. Provision persistent volumes with monitored disk capacity.
3. Generate strong unique secrets.
4. Configure TLS certificates and automatic renewal.
5. Configure the firewall and private service network.
6. Disable or restrict public access to ports 5432, 6379, 8080, 9200 and 5601.
7. Configure Keycloak/identity provider with correct redirect URIs.
8. Disable self-registration unless explicitly approved.
9. Enable brute-force protection/MFA according to policy.
10. Load signed/tested country resources.
11. Create least-privilege administrator accounts.
12. Configure automated backups and off-server retention.
13. Add service, certificate, disk, memory and backup monitoring.
14. Run security, performance, restore and acceptance tests.
15. Document rollback and incident-response procedures.

## Reverse-proxy example concept

An Nginx virtual host should redirect HTTP to HTTPS, proxy requests to iHRIS on
the private network, set forwarding headers, enforce suitable upload/time-out
limits, and apply organization-approved TLS/security headers. Do not copy an
internet snippet unchanged; test WebSocket/session behavior and Keycloak
redirects for your actual host name.

## Secrets

The example `baseConfig.json.example` contains development placeholders and
example credentials. Production secrets must be replaced. Prefer a platform
secret store or root-readable environment file outside Git. Rotate any secret
that was ever committed or publicly exposed.

## Database migration and initial load

For existing data:

1. inventory and profile source fields;
2. map codes to approved FHIR terminology;
3. clean duplicates and invalid dates;
4. generate deterministic/stable identifiers;
5. load a small sample into staging;
6. reconcile counts and individual cases;
7. run full staging migration;
8. record rejected rows and corrections;
9. rehearse production cutover and rollback;
10. take a final pre-cutover backup;
11. migrate during an approved change window;
12. reconcile and obtain sign-off.

Never silently discard rejected employees.

## Release method

Build an immutable, versioned artifact. Promote the same tested artifact from
staging to production, changing only protected environment configuration.
Record release version, FSH/resource package version, database backup ID,
operator, approval, deployment time, validation results and rollback decision.
