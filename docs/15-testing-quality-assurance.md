# 15. Testing and quality assurance

## 15.1 Test levels

- unit tests: one JavaScript function/component;
- profile validation: one FHIR resource;
- integration tests: backend with FHIR/Redis/search/Keycloak;
- end-to-end tests: browser user journey;
- migration tests: source-to-FHIR conversion and reconciliation;
- security tests: authentication, permissions and abuse cases;
- performance tests: realistic load/volume;
- restore tests: recover system and verify data;
- UAT: approved business users confirm requirements.

## 15.2 Test data

Use synthetic employees covering:

- normal record;
- multiple given names and Unicode;
- missing optional fields;
- duplicate identifier attempt;
- two historical roles;
- active plus ended role;
- location with same name in two districts;
- invalid date sequence;
- transferred employee;
- separated employee;
- user outside permitted location.

Never publish real employee data in test fixtures.

## 15.3 Core employee scenario

1. clerk creates a draft;
2. required-field validation runs;
3. reviewer corrects/rejects or submits;
4. authorized approver approves;
5. Practitioner and PractitionerRole are correct;
6. employee is searchable;
7. report includes them exactly once by its definition;
8. unauthorized facility user cannot view them;
9. audit shows responsible actions;
10. export follows permissions.

## 15.4 Negative testing

Attempt invalid/malicious actions: missing identifier, duplicate ID, invalid
code, wrong location, expired token, clerk calling admin endpoint, oversized
upload, malformed JSON, script content in text, direct object ID from another
district and deletion without approval.

Expected failure should be safe, understandable and audited—not a server crash
or leaked stack trace.

## 15.5 Performance baseline

Measure login, employee search, record open/save, report load/export, bulk
import throughput and indexing delay. Use realistic volumes and concurrent
users. Observe CPU, memory, JVM heap, database connections, disk I/O and
Elasticsearch health.

## 15.6 UAT evidence

Each case should have ID, requirement, preconditions, steps, expected result,
actual result, evidence, tester, date, status and defect link. “Users tested it”
is not adequate release evidence.

## 15.7 Release gate

Do not release until critical tests pass, high-risk defects are resolved or
formally accepted, migration reconciliation is approved, backup/restore works,
permissions are verified, monitoring is ready, training/support material is
available and rollback is rehearsed.
