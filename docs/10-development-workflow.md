# 10. Development workflow for beginners

## 10.1 Keep upstream and country work separate

Do not make hundreds of undocumented edits directly inside a downloaded iHRIS
ZIP. Use Git and separate concerns:

```text
upstream iHRIS core     → tracked source/version
Rwanda configuration   → country FSH/resources/site code
deployment repository  → Compose, proxy, monitoring templates
secrets                 → protected platform secret store, never Git
```

## 10.2 Clone and create a branch

```bash
git clone https://github.com/iHRIS/iHRIS.git
cd iHRIS
git switch -c feature/rwanda-employee-identifier
git status
```

Make one logical change per branch. A good commit describes an outcome:

```bash
git add ig/input/fsh/RwandaIdentifiers.fsh
git commit -m "Add Rwanda employee identifier profile"
```

## 10.3 Developer loop

For configuration:

1. edit `.fsh` or country resource source;
2. run SUSHI;
3. inspect warnings/errors;
4. load into a disposable FHIR server;
5. test the UI and FHIR output;
6. add automated tests or a reproducible checklist;
7. commit source, not secrets or runtime data.

For frontend:

```bash
cd ihris-frontend
npm ci
npm run lint
npm run test:unit
npm run serve
```

Use `npm ci` when the lockfile is authoritative and unchanged. Use `npm install`
when intentionally changing dependencies, then review lockfile changes.

For backend:

```bash
cd ihris-backend
npm ci
npm test
```

Run the site/backend with the command defined by its package scripts and inspect
logs in development mode.

## 10.4 Country configuration versioning

Version the Rwanda configuration as a release package, for example:

```text
rwanda-config 0.1.0  initial prototype
rwanda-config 0.2.0  district hierarchy and cadres
rwanda-config 1.0.0  approved production baseline
rwanda-config 1.0.1  corrected label, no data-model break
```

Record which application, FHIR, configuration, Keycloak realm and deployment
versions are compatible.

## 10.5 Configuration promotion

Never manually recreate configuration by clicking separately in each
environment. Build a repeatable loader or package:

```text
source → build → validate → load development → test → load staging → approve → load production
```

Use stable resource IDs so updates modify intended configuration rather than
creating duplicates.

## 10.6 Logging during development

Log request correlation IDs, resource types/IDs, operation results and error
diagnostics. Do not log passwords, authorization headers, private identifiers,
full employee bodies or reset links. Development logging can be verbose;
production logging must be controlled and retained securely.

## 10.7 Code review checklist

- Does the change meet an approved requirement?
- Does it modify core code when a site extension would work?
- Are FHIR IDs/canonical URLs stable and unique?
- Are official codes used rather than invented text?
- Are permissions enforced on the server, not only hidden in the UI?
- Are errors handled without exposing secrets?
- Are migration and rollback instructions present?
- Do tests cover valid, invalid and unauthorized cases?
- Are translation keys complete?
- Could the change affect existing production resources?

## 10.8 Debugging with breakpoints

Use browser developer tools for Vue network requests and console errors. For
Node, use the debugger/inspector or structured logs. Identify the failing layer:

```text
UI rendering → frontend request → backend route → authorization → FHIR request → database/index
```

Do not “fix” a frontend error by changing database rows.

## 10.9 Definition of done

A feature is not done when it works once on a developer laptop. It is done when
requirements, code/config, tests, permissions, translations, documentation,
migration, monitoring and rollback are complete and reviewed.
