# 14. APIs and system integrations

## 14.1 Start with an integration contract

Define owner, purpose, data fields, source of truth, direction, frequency,
identifier mapping, authentication, authorization, retry, duplicate handling,
audit, privacy, monitoring and support before coding.

## 14.2 Common patterns

- real-time FHIR REST request;
- scheduled incremental synchronization;
- approved CSV/XLSX transfer;
- event/message-based integration;
- read-only reporting replica/export;
- one-time controlled migration.

Choose the simplest pattern meeting the requirement.

## 14.3 Idempotency

Repeating the same message should not create a duplicate employee. Use stable
identifiers, conditional create/update where supported, an integration event ID
and a processed-message log.

## 14.4 Incremental synchronization

FHIR supports search based on update time on many servers:

```text
GET /fhir/Practitioner?_lastUpdated=gt2026-08-01T00:00:00Z
```

Confirm support in capability/search metadata. Store a safe watermark, allow
an overlap window, deduplicate results and handle pagination. Do not advance the
watermark until processing and persistence succeed.

## 14.5 Retry policy

Retry transient network/5xx/429 errors with exponential backoff and jitter.
Do not automatically retry invalid 400/422 payloads forever. Send permanent
failures to a review queue with sanitized diagnostics.

## 14.6 Identifier matching

Match by an approved stable identifier system+value, not only name and birth
date. Maintain crosswalks when systems use different keys. Require manual
review for ambiguous matches.

## 14.7 API protection

- HTTPS;
- service account with least privilege;
- short-lived token or managed credential;
- secret rotation;
- IP/network restriction where appropriate;
- request size and rate limits;
- validation against profiles;
- audit and correlation IDs;
- no sensitive payloads in logs.

## 14.8 Example integration flow

```text
Payroll sends changed worker
→ integration validates schema
→ maps payroll ID to Practitioner
→ validates official codes/location
→ builds FHIR transaction
→ iHRIS accepts or returns OperationOutcome
→ integration records result
→ reconciliation compares both systems
```

## 14.9 Monitoring

Track last success, records received/accepted/rejected, latency, retry queue,
oldest pending message, duplicate rate and reconciliation difference. Every
integration alert needs an operational owner.

## 14.10 Avoid tight coupling

Do not let another system write directly to HAPI PostgreSQL tables. Integrate
through FHIR or a documented protected backend endpoint so validation,
authorization, audit and versioning remain intact.
