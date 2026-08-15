# 9. FHIR practical guide for an iHRIS programmer

FHIR can look difficult because it uses healthcare terminology, but the basic
pattern is consistent: each object is a typed **resource**, every saved resource
has an `id`, resources link using references, and the server is accessed through
HTTP.

## 9.1 Resource addresses

```text
GET  /fhir/Practitioner/abc       read one employee
GET  /fhir/Practitioner?...       search employees
POST /fhir/Practitioner           create with server-assigned ID
PUT  /fhir/Practitioner/abc       create/update a known ID
DELETE /fhir/Practitioner/abc     delete, subject to rules/references
```

For learning, perform `GET` requests first. Use an isolated test server for
`POST`, `PUT` and `DELETE`.

## 9.2 Minimal Practitioner

```json
{
  "resourceType": "Practitioner",
  "active": true,
  "identifier": [
    {
      "system": "https://example.gov.rw/hr/employee-id",
      "value": "RW-HR-0001"
    }
  ],
  "name": [
    {
      "use": "official",
      "family": "Example",
      "given": ["Aline"],
      "text": "Aline Example"
    }
  ],
  "gender": "female"
}
```

`system` identifies the issuing namespace; `value` is the identifier inside
that namespace. This is safer than treating every number as globally unique.

## 9.3 Minimal PractitionerRole

```json
{
  "resourceType": "PractitionerRole",
  "active": true,
  "practitioner": { "reference": "Practitioner/PRACTITIONER_UUID" },
  "location": [
    { "reference": "Location/FACILITY_UUID", "display": "Example Hospital" }
  ],
  "period": { "start": "2026-01-01" },
  "code": [
    {
      "coding": [
        {
          "system": "https://example.gov.rw/hr/cadre",
          "code": "nurse",
          "display": "Nurse"
        }
      ]
    }
  ]
}
```

The person and the job are separate. A person can have historical or multiple
roles. Reports must state whether they count people, active roles, or full-time
equivalents.

## 9.4 Searching correctly

```bash
# exact identifier value
curl 'http://localhost:8080/fhir/Practitioner?identifier=RW-HR-0001'

# identifier system plus value
curl 'http://localhost:8080/fhir/Practitioner?identifier=https%3A%2F%2Fexample.gov.rw%2Fhr%2Femployee-id%7CRW-HR-0001'

# name
curl 'http://localhost:8080/fhir/Practitioner?name=Aline&_count=20'

# role by employee reference
curl 'http://localhost:8080/fhir/PractitionerRole?practitioner=Practitioner/UUID'

# active roles
curl 'http://localhost:8080/fhir/PractitionerRole?active=true&_count=100'
```

Search parameter support is declared in `/metadata`. Never assume a parameter
works identically on every FHIR server/version.

## 9.5 Pagination

A Bundle can include `link` entries for `self`, `next` and `previous`. Follow
the exact `next` URL supplied by the server. Do not build the next URL by
guessing page numbers.

## 9.6 HTTP status and OperationOutcome

| Status | Meaning |
|---:|---|
| 200 | Successful read/search/update response |
| 201 | Resource created |
| 204 | Successful operation with no response body |
| 400 | Invalid request/resource |
| 401 | Not authenticated |
| 403 | Authenticated but forbidden |
| 404 | Endpoint/resource not found |
| 409/412 | Conflict or version/precondition issue |
| 422 | Resource failed business/validation rules |
| 500 | Server-side failure |

FHIR errors often arrive as `OperationOutcome`. Read every `issue`, especially
`severity`, `code`, `details`, `diagnostics` and `expression`.

## 9.7 Transactions

A transaction Bundle applies related changes together:

```json
{
  "resourceType": "Bundle",
  "type": "transaction",
  "entry": [
    {
      "resource": { "resourceType": "Practitioner", "id": "p1" },
      "request": { "method": "PUT", "url": "Practitioner/p1" }
    }
  ]
}
```

Use transactions for logically connected changes. Check the returned
transaction-response Bundle entry by entry.

## 9.8 History and concurrency

FHIR resources have `meta.versionId` and `meta.lastUpdated`. HAPI maintains
versions. When multiple people can edit the same record, consider conditional
updates or `If-Match` behavior to prevent silently overwriting newer data.

## 9.9 Profiles and validation

A base Practitioner permits many structures. A Rwanda profile can require the
official HR identifier and constrain extensions/codes. Validate test instances
against profiles before migration. A valid JSON document is not necessarily a
valid country HR record.

## 9.10 Safe practice exercises

1. Fetch `/metadata` and identify FHIR version.
2. Count Practitioners and PractitionerRoles.
3. Find a test employee by identifier.
4. follow the PractitionerRole reference to its Location.
5. identify resource `id`, `versionId` and `lastUpdated`.
6. export the related test records to a local JSON file.
7. create a fictional employee in a disposable server.
8. update the fictional employee and inspect history.
9. delete only that fictional employee after checking references.

Never practice writes using real employee identifiers.
