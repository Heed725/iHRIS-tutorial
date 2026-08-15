# 4. Important files and what to edit

## Top-level files

| Path | Purpose | Edit? |
|---|---|---|
| `docker-compose.yml` | Local services, ports, volumes, images and environment | Copy/override for your deployment |
| `README.md` | Upstream overview | Read first |
| `mkdocs.yml` | Documentation website navigation/theme | When publishing docs |
| `resources/` | Starter roles, pages, reports, workflows and demo bundles | Copy country-specific resources |
| `tools/` | Resource loaders and administration utilities | Use carefully |

## Backend

| Path | Purpose | Beginner guidance |
|---|---|---|
| `ihris-backend/app.js` | Core Express setup | Understand before modifying |
| `ihris-backend/routes/` | Core backend endpoints | Prefer country-site routes |
| `ihris-backend/modules/fhir/` | FHIR access/config/security logic | Core; avoid casual edits |
| `ihris-backend/modules/workflows/` | Core workflow processors | Extend in site project |
| `ihris-backend/ihris-backend-site/` | Site template | Copy for Rwanda |
| `.../config/baseConfig.json.example` | Local configuration template | Copy; replace defaults/secrets |
| `.../routes/` | Site-specific routes | Add integrations here |
| `.../modules/workflows/` | Site-specific workflow logic | Add approved workflows |
| `.../locales/` | Backend/localized text | Add `rw`, `en`, `fr` |
| `.../public/` | Compiled frontend and static assets | Generated/copied output |

## Frontend

| Path | Purpose | Edit? |
|---|---|---|
| `ihris-frontend/src/App.vue` | Root Vue application | Rarely |
| `src/router/index.js` | Frontend routes | For new screens |
| `src/views/` | Full pages | For custom views |
| `src/components/fhir/` | Generic FHIR inputs | Core; test heavily |
| `src/components/ihris/` | iHRIS UI components | Extend carefully |
| `src/locales/*.json` | Translations | Yes |
| `public/` | favicon, flags and static assets | Yes |
| `vue.config.js` | Vue build configuration | Only when needed |

After frontend changes:

```bash
cd ihris-frontend
npm install
npm run lint
npm run build
```

Copy the built distribution into the country backend public directory according
to your selected build/deployment process.

## FHIR definitions

| Path | Purpose |
|---|---|
| `ig/input/fsh/*.fsh` | Human-editable FHIR Shorthand source |
| `ig/sushi-config.yaml` | SUSHI implementation-guide configuration |
| `ig/fsh-generated/resources/` | Generated JSON; rebuild from FSH |
| `resources/Basic-ihris-role-*.json` | Application roles |
| `resources/demo/` | Demonstration data; do not use as national truth |
| `resources/keycloak/realm.json` | Example Keycloak realm export |

## Files not to edit directly

- `node_modules/`
- compiled hashed files under backend `public/js` and `public/css`
- `package-lock.json` by hand
- generated FSH JSON without also updating source FSH
- PostgreSQL HAPI tables for routine employee changes
- Elasticsearch index documents as the authoritative source

## Configuration precedence

iHRIS configuration can come from local configuration, environment variables,
command-line values and signed remote FHIR Parameters. Environment names begin
with `IHRIS_`; double underscore represents a nested separator. For example:

```text
fhir:base                 → IHRIS_FHIR__BASE
redis:url                 → IHRIS_REDIS__URL
elasticsearch:base       → IHRIS_ELASTICSEARCH__BASE
```

Keep a documented configuration matrix for development, staging and
production. Values should differ, but the deployed code artifact should be the
same.
