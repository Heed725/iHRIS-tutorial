# 3. Building an iHRIS Rwanda implementation

This is a method and example—not an assertion about Rwanda's current official
HR codes or administrative model. Obtain authoritative lists and approval from
the responsible Rwanda institutions before production use.

## Phase 1: requirements before coding

Create a requirements workbook covering:

- employee identifiers and uniqueness rules;
- names and demographic fields;
- provinces, districts, sectors, cells, villages, facilities and organizations;
- cadres, professions, posts, grades and specialties;
- employment status, contract type and payroll status;
- education, licenses, training and continuing professional development;
- transfers, promotions, leave, discipline, separation and retirement;
- user roles and location-based permissions;
- review and approval rules;
- required reports and exports;
- Kinyarwanda/English/French labels;
- integrations and data migration;
- privacy, retention and audit requirements.

Assign an owner to every code list. A developer should not invent national
codes.

## Phase 2: create a country site

For a source-based deployment, keep the upstream core separate from the Rwanda
site:

```bash
cd ihris-backend
cp -r ihris-backend-site ihris-rwanda
cd ihris-rwanda
cp config/baseConfig.json.example config/baseConfig.json
```

Use environment-specific configuration. Never commit production secrets.

Suggested country project layout:

```text
ihris-rwanda/
├── config/
│   ├── baseConfig.json.example
│   └── README.md
├── ig/input/fsh/
│   ├── RwandaIdentifiers.fsh
│   ├── RwandaLocations.fsh
│   ├── RwandaTerminology.fsh
│   ├── RwandaPractitioner.fsh
│   ├── RwandaPractitionerRole.fsh
│   └── RwandaQuestionnaires.fsh
├── resources/
│   ├── roles/
│   ├── pages/
│   └── reports/
├── locales/
│   ├── en.json
│   ├── rw.json
│   └── fr.json
├── routes/
├── modules/workflows/
└── public/images/
```

## Phase 3: configure endpoints and branding

Important local parameters include:

```text
app:site:path
app:core:path
fhir:base
redis:url
elasticsearch:base
kibana:base
keycloak:baseURL
keycloak:realm
auth:secret
```

In Docker, use internal service names. In production, inject secrets through
protected environment variables such as:

```text
IHRIS_FHIR__BASE=http://fhir:8080/fhir
IHRIS_REDIS__URL=redis://redis
IHRIS_ELASTICSEARCH__BASE=http://es:9200
```

Change the site title, approved logo, colors, footer, navigation and languages
only after the data model and roles are agreed.

## Phase 4: model Rwanda terminology

Create stable code systems rather than storing free-text variants:

```fsh
CodeSystem: RwandaEmploymentStatus
Id: rwanda-employment-status
Title: "Rwanda Employment Status"
* ^status = #active
* #active "Active"
* #leave "On Leave"
* #secondment "Secondment"
* #separated "Separated"

ValueSet: RwandaEmploymentStatusVS
Id: rwanda-employment-status-vs
Title: "Rwanda Employment Status Value Set"
* include codes from system RwandaEmploymentStatus
```

Replace illustrative codes with officially approved ones. Once codes are used
in production, avoid casually renaming or recycling them.

## Phase 5: define identifiers

Decide which identifier is primary and which are optional. Examples might
include HR employee number, professional council registration, payroll number,
or national identifier. Do not expose sensitive identifiers in reports or APIs
without authorization.

Document for each identifier:

- issuing authority;
- format and validation;
- whether it must be unique;
- whether it can change;
- who may view/edit it;
- duplicate-resolution procedure.

## Phase 6: load the location hierarchy

Use `Location` resources with parent relationships. A conceptual hierarchy is:

```text
Rwanda
└── Province or City
    └── District
        └── Sector
            └── Health facility
```

Your approved hierarchy may differ. Give each location a stable identifier;
do not link employees only by display name. Test moves, renamed facilities,
inactive facilities and duplicate names in different districts.

## Phase 7: profiles and questionnaires

Profiles specify valid data; questionnaires collect it. Start small:

1. Personal information.
2. Employee identifiers.
3. Current employment/position.
4. Facility assignment.
5. Contact information.
6. Education and professional registration.

Then add workflows for transfer, promotion, training, leave, separation and
other approved processes. Each workflow should define initiator, reviewer,
approver, rejection/correction route, audit entry, and resulting FHIR changes.

## Phase 8: roles and permissions

The source includes role resources such as admin, HR manager, HR officer, data
clerk and location-based roles. Create a Rwanda role matrix before editing JSON:

| Action | National admin | Province HR | District HR | Facility clerk | Auditor |
|---|---:|---:|---:|---:|---:|
| View employee | Yes | Assigned | Assigned | Assigned | Yes |
| Create draft | Yes | Yes | Yes | Yes | No |
| Approve | Yes | Policy | Policy | No | No |
| Export | Restricted | Restricted | Restricted | No | Read-only |
| Delete | Exceptional | No | No | No | No |

Apply least privilege and test permissions using separate test accounts.

## Phase 9: translations

Copy the English locale, add Kinyarwanda and French keys, then translate labels
with HR/domain reviewers. Keep keys stable. Test long translations on mobile,
validation messages, dates, exports, email templates and printable documents.

## Phase 10: build and load configuration

```bash
cd ig
sushi -s .

cd ../../tools
npm install
node load.js --server http://localhost:8080/fhir ../ihris-rwanda/ig/fsh-generated/resources/*.json
node load.js --server http://localhost:8080/fhir ../ihris-rwanda/resources/*.json
```

Paths vary with your repository layout. Always point to a test server first.
Review generated JSON and SUSHI errors before loading.

## Phase 11: acceptance testing

Test at least:

- create, search, edit and view an employee;
- duplicate identifier rejection;
- facility/location filtering;
- transfer and promotion history;
- inactive/separated staff;
- role restrictions and attempted unauthorized actions;
- reports against manually verified totals;
- Kinyarwanda, English and French UI;
- bulk import with valid and invalid rows;
- backup and full restore;
- loss/restart of each container;
- browser and mobile layouts;
- performance with realistic data volume.

Do not import national data until sign-off, data-protection review, backup
verification and rollback rehearsal are complete.
