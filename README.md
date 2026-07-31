# Trailhead Salesforce — Apex Basics & Database + Apex Triggers

This repository tracks Salesforce org metadata and documentation for two Trailhead badges:

| Badge | Trailhead ID | Status |
|-------|-------------|--------|
| **Apex Basics & Database** | badge8 | Unit 5 in progress |
| **Apex Triggers** | badge9 | Not started |

---

## Badge 1 — Apex Basics & Database

| Unit | Title | Status |
|------|-------|--------|
| 1 | Get Started with Apex | ✅ Done |
| 2 | Use sObjects | ✅ Done (quiz only) |
| 3 | Manipulate Records with DML | ✅ Done |
| 4 | Write SOQL Queries | ✅ Done |
| 5 | Write SOSL Queries | 🔄 In progress |

### Documentation

| Unit | Guide |
|------|-------|
| 1 | [step-by-step.md](docs/badge-8-apex-basics/unit-1/step-by-step.md) · [blocker-log.md](docs/badge-8-apex-basics/unit-1/blocker-log.md) |
| 3 | [data-layer-reference.md](docs/badge-8-apex-basics/unit-3/data-layer-reference.md) · [account-handler.md](docs/badge-8-apex-basics/unit-3/account-handler.md) |
| 4 | [contact-search.md](docs/badge-8-apex-basics/unit-4/contact-search.md) |
| 5 | [contact-and-lead-search.md](docs/badge-8-apex-basics/unit-5/contact-and-lead-search.md) |

### Foundational Docs

| Doc | What it covers |
|-----|---------------|
| [metadata-vs-data.md](docs/metadata-vs-data.md) | Why the repo only contains schema, not records |
| [data-layer-reference.md](docs/unit-3/data-layer-reference.md) | DML, SOQL, SOSL, and the `sf` CLI explained |
| [ONBOARDING.md](docs/ONBOARDING.md) | Project setup and retrieval workflow |

---

## Badge 2 — Apex Triggers

| Unit | Title | Status |
|------|-------|--------|
| 1 | TBD | Not started |

---

## Repository Structure

- `force-app/` — Apex classes and org metadata retrieved from the playground
- `manifest/` — `package.xml` defining what metadata to retrieve
- `docs/` — Module documentation, onboarding guides, and retrieval logs

## Onboarding

For step-by-step instructions on connecting your org and retrieving metadata, see [ONBOARDING.md](docs/ONBOARDING.md).
