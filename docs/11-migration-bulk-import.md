# 11. Data migration and bulk import

Migration is usually the highest-risk part of a national HRIS project. Treat it
as a controlled data-engineering project, not a single Excel upload.

## 11.1 Preserve the source

Create a read-only original snapshot with checksum, owner, extraction time and
record count. Work on copies. Never “clean” the only copy of the legacy data.

## 11.2 Profile the data

For every column record:

- meaning and owner;
- data type and allowed values;
- missing percentage;
- distinct values;
- duplicates;
- min/max dates and numeric ranges;
- examples of malformed values;
- sensitivity/classification;
- target FHIR path;
- transformation rule.

## 11.3 Build a mapping specification

| Legacy column | Example | Target | Rule |
|---|---|---|---|
| Employee No | 00125 | `Practitioner.identifier` | preserve leading zeros |
| First Name | Aline | `Practitioner.name.given` | trim spaces, retain accents |
| Facility Code | HF-20 | `PractitionerRole.location` | resolve approved Location ID |
| Cadre | Nurse | `PractitionerRole.code` | map to official coding |
| Start Date | 01/02/2020 | `period.start` | confirm day/month convention |

Do not guess ambiguous date formats. `01/02/2020` can mean two different dates.

## 11.4 Normalize reference data first

Load and validate terminology, organizations and locations before employees.
Every facility/cadre in employee rows should map to exactly one approved target.
Create a rejection, not a guess, when no exact mapping exists.

## 11.5 Deterministic identifiers

Choose a stable rule for FHIR resource IDs or maintain a crosswalk table:

```text
legacy_employee_key → Practitioner UUID
legacy_job_key      → PractitionerRole UUID
facility_code       → Location UUID
```

Keep the crosswalk protected and versioned as migration evidence. Re-running an
import should update or skip known records, not duplicate them.

## 11.6 Validation stages

1. File/schema validation: columns, encoding, delimiter, sheet names.
2. Field validation: required values, length, formats and dates.
3. terminology validation: each code maps once.
4. relational validation: facilities and supervisors exist.
5. business validation: employment periods and statuses make sense.
6. FHIR validation: generated resources conform to profiles.
7. duplicate validation: identifier and person-matching policy.

Produce separate accepted and rejected outputs with reasons and row numbers.

## 11.7 Small pilot first

Use fictional data during development, then an approved small sample. Check:

- source row count versus generated resources;
- individual field accuracy;
- names and Unicode characters;
- historical roles;
- reports and location filters;
- duplicates on a second run;
- rollback/cleanup procedure.

## 11.8 FHIR batch versus transaction

- `batch`: entries are processed independently; some may succeed and others
  fail.
- `transaction`: all entries should succeed or the entire transaction fails.

Large imports may need controlled chunks. Keep chunk manifest, request bundle,
response bundle, timestamps and checksums. Check every entry response; HTTP 200
for the outer request does not prove every business expectation was met.

## 11.9 Reconciliation

Reconcile at multiple levels:

```text
total people
active people
people by district/facility
people by cadre/status/gender
missing identifier count
rejected row count by reason
duplicate count
roles without person/location
```

Have HR/business owners verify samples, not only programmers.

## 11.10 Cutover

Freeze or track source-system changes, take final backups, rerun extraction,
migrate in an approved window, reconcile, obtain sign-off, then enable users.
Maintain rollback criteria and a deadline after which rollback becomes a formal
data-reconciliation incident rather than a simple technical reversal.

## 11.11 Privacy

Minimize copies, encrypt transfers, restrict access, delete temporary files
under an approved schedule, and never use production employee data in public
GitHub repositories or developer screenshots.
