# 16. Complete iHRIS Rwanda project blueprint

This chapter turns the technical tutorial into an implementation program. It is
illustrative; governance and official requirements must be agreed locally.

## Stage 0: mandate and governance

Create a steering group, product owner, HR/data owners, technical lead,
security/privacy owner, infrastructure owner and support lead. Approve scope,
budget, hosting, legal basis, data sharing, success measures and change control.

Deliverables: charter, RACI, risk register, communication plan and decision log.

## Stage 1: discovery

Interview national, province, district and facility users. Observe current HR
work. Inventory paper forms, spreadsheets, databases, reports, integrations,
codes, identifiers and pain points.

Deliverables: current-state diagrams, prioritized requirements, data inventory,
report catalogue, user-role catalogue and initial migration assessment.

## Stage 2: data governance and model

Agree authoritative sources and owners for employee IDs, facilities, cadres,
organizations and geography. Define data-quality rules, retention, correction,
duplicate resolution, approval and audit.

Deliverables: data dictionary, terminology catalogue, identifier policy,
location hierarchy and profile/questionnaire design.

## Stage 3: technical foundation

Provision development/staging, Git repositories, CI, issue tracking, secrets,
Keycloak, monitoring and backup storage. Pin compatible iHRIS/HAPI/search
versions.

Deliverables: architecture, environments, automated deployment baseline,
security baseline and recovery plan.

## Stage 4: minimum viable implementation

Build branding/translations, locations, identifiers, personal information,
current employment, core roles and essential reports. Avoid implementing every
legacy form before users can test a coherent employee workflow.

Deliverables: Rwanda configuration 0.x, test data, administrator manual and
demonstration.

## Stage 5: workflows and reports

Implement approval, transfer, promotion, leave, training, license, separation
and other approved workflows in priority order. Build reports only from signed
definitions.

Deliverables: workflow specifications, role matrix, tested processors,
dashboards, exports and audit review procedure.

## Stage 6: migration

Extract, profile, map, clean and validate legacy data. Run pilot and full
staging rehearsals. Track every rejected row. Reconcile by total, geography,
cadre, status and sample employee.

Deliverables: mapping document, scripts, crosswalk, rejection register,
reconciliation report, cutover/rollback runbook.

## Stage 7: security and operational readiness

Conduct access review, threat modeling, vulnerability remediation, performance
test, backup restore, disaster-recovery exercise and support training.

Deliverables: security sign-off, monitoring dashboard, on-call/escalation,
backup evidence and operations manual.

## Stage 8: pilot

Choose representative pilot sites. Train users, provide rapid support, measure
data quality and workflow completion, and record change requests. Keep scope
controlled so the pilot tests the product rather than continuously redesigning
it.

Deliverables: pilot report, defects, adoption metrics, revised training and
go/no-go decision.

## Stage 9: phased rollout

Roll out by approved geographic/organizational waves. For each wave complete
readiness, accounts, training, data migration, validation, go-live support and
post-go-live review.

## Stage 10: continuous improvement

Operate a release calendar. Monitor quality, usage, report accuracy, security,
capacity and support. Review codes and locations through governance rather than
ad hoc developer edits.

## Example work breakdown

| Workstream | Example outputs |
|---|---|
| Governance | charter, RACI, approvals, policy |
| Product | requirements, backlog, UAT |
| Data | dictionary, terminology, migration, quality |
| Engineering | FSH, workflows, frontend, integrations |
| Infrastructure | hosting, TLS, secrets, monitoring, backup |
| Security | threat model, permissions, audit, testing |
| Change | communication, training, help desk, rollout |

## Go-live checklist

- approved production version and configuration;
- full backup and tested restore;
- signed migration reconciliation;
- DNS/TLS and identity provider verified;
- least-privilege accounts created;
- monitoring and alert routing active;
- support staff and escalation available;
- user training completed;
- rollback criteria and decision owner confirmed;
- change window and communication approved.

## First 24 hours

Monitor login failures, response times, container restarts, FHIR errors,
database/search health, indexing lag, rejected workflows, unexpected permission
denials, support tickets and reconciliation metrics. Freeze noncritical changes.

## First 30 days

Review adoption, duplicate/missing IDs, inactive facility assignments, approval
times, report discrepancies, security events, capacity and backup/restore
results. Prioritize fixes through governance and publish a controlled release.
