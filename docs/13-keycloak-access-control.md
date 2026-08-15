# 13. Keycloak, roles and access control

## 13.1 Two authorization layers

Keycloak answers “who is this user and how did they authenticate?” iHRIS
roles/tasks answer “what may this user do to which resources?” Hiding a button
in Vue is not security; the backend must deny the unauthorized request.

## 13.2 Keycloak concepts

- realm: isolated identity domain, such as the iHRIS deployment;
- client: an application such as frontend/backend;
- user: human or service identity;
- role/group: identity grouping or granted capability;
- redirect URI: approved location after authentication;
- access token: short-lived signed authorization credential;
- refresh token: obtains new access tokens and needs strong protection.

## 13.3 Production configuration

Replace all example users, passwords, client secrets and session secrets. Set
the exact HTTPS redirect/origin URLs. Disable unused flows, enforce password
policy, consider MFA, enable brute-force protection, configure email/reset
flows, and protect the administration console.

## 13.4 Role design

Prefer business roles:

```text
National HR administrator
National report viewer
Province HR manager
District HR officer
Facility data clerk
Auditor
Integration service account
```

Do not grant “admin” merely because a user needs one report.

## 13.5 Location-based access

A district officer should normally see assigned district data, not national
data. Test boundary cases: facilities moved between districts, user assigned to
two locations, parent/child hierarchy, inactive location, and records with no
location.

## 13.6 Permission testing matrix

For every role, test allowed and denied actions against:

- list/search;
- view details;
- create draft;
- update;
- submit/review/approve/reject;
- export/report;
- delete/archive;
- user management;
- configuration changes;
- API access.

Use separate accounts. A test that only confirms allowed actions is incomplete.

## 13.7 Service accounts

Integrations should use non-human accounts with minimum scopes, protected
credentials, rotation, identifiable audit entries, rate limits and an owner.
Never share a national administrator login with an integration script.

## 13.8 User lifecycle

Document request, approval, provisioning, role assignment, periodic review,
role change, suspension, departure and deletion/retention. Disable accounts
promptly when staff leave; preserve audit history according to policy.

## 13.9 Troubleshooting tokens

Check issuer, audience/client, expiry, clock synchronization, signature/key,
realm URL and proxy headers. Do not paste a real token into public decoder sites
or GitHub issues; tokens can grant live access.
