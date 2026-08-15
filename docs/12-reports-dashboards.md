# 12. Reports, Elasticsearch and Kibana

## 12.1 Define the question before the chart

“Number of nurses” is ambiguous. It might mean people whose current primary
role is nurse, active role records, positions, or full-time equivalents. Every
report needs a written definition, inclusion/exclusion rules, time basis,
grouping, authorized audience and source fields.

## 12.2 Source of truth and index

FHIR/PostgreSQL is authoritative. Elasticsearch is optimized for search and
reporting. A report can be wrong even when the FHIR record is correct because
the index is stale, mapping changed, or transformation omitted a field.

## 12.3 Diagnose missing report data

1. Find the employee in FHIR by exact identifier.
2. Fetch associated PractitionerRole and Location.
3. confirm fields match the report definition.
4. inspect Elasticsearch health and relevant index.
5. check iHRIS indexing/report logs.
6. compare index document to FHIR resource.
7. refresh/reindex through the supported process.

Do not edit Elasticsearch manually as a permanent correction.

## 12.4 Elasticsearch checks

```bash
curl 'http://localhost:9200/_cluster/health?pretty'
curl 'http://localhost:9200/_cat/indices?v&s=index'
curl 'http://localhost:9200/_cat/nodes?v'
```

Protect these endpoints in production. They reveal internal data and permit
powerful operations when security is not configured.

## 12.5 Index mappings

Mappings control whether a field is analyzed text, exact keyword, date,
number, boolean or nested object. Common report problems include:

- aggregating a text field instead of its keyword form;
- date imported as inconsistent text;
- changed field path after profile update;
- location display used instead of stable code/reference;
- multiple roles producing duplicate person counts;
- null/missing values excluded without explanation.

## 12.6 Reconciliation report

Build an administrator-only comparison that shows:

| Metric | FHIR count | Search/report count | Difference |
|---|---:|---:|---:|
| Active practitioners | | | |
| Active roles | | | |
| Assigned facilities | | | |
| Missing employee ID | | | |

Run after migration, configuration changes, reindexing and upgrades.

## 12.7 Kibana dashboard safety

Kibana access can expose sensitive workforce data. Use authentication,
role-based spaces/permissions, TLS, private networking and export controls.
Avoid displaying personal identifiers when aggregate information answers the
question.

## 12.8 Report acceptance test

For each report:

1. create a known test dataset;
2. manually calculate expected values;
3. test no filter, each filter and combined filters;
4. test date boundaries and inactive roles;
5. test users with different location permissions;
6. test CSV/XLSX/PDF exports;
7. confirm labels, totals, percentages and rounding;
8. verify zero/no-data states;
9. check performance with realistic volume;
10. document report version and definition.
