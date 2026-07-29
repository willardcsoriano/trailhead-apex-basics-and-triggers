# Troubleshooting: Org Alias Mismatch and Baseline Metadata Retrieval

## Overview

This document records what happened immediately after resolving the SSH OAuth login hang (see `sf-org-login-web-remote-ssh-hang.md` in this same folder): the org ended up authenticated under an alias that didn't match the one hardcoded throughout `docs/ONBOARDING.md`, and the baseline metadata retrieval that follows login had never actually been run despite the manifest already reflecting org metadata. Both are resolved. The alias was fixed by adding a second alias pointing at the same authenticated username, and the retrieval was run successfully — 859 components across 3094 files were pulled into `force-app`, with 104 expected, non-fatal warnings for org metadata that exists in the org's schema but isn't actually retrievable (soft-deleted references, restricted Survey-type flows, and similar).

---

## Table of Contents

- [Overview](#overview)
- [Alias mismatch](#alias-mismatch)
- [Baseline retrieval had never run](#baseline-retrieval-had-never-run)
- [State after this fix](#state-after-this-fix)

## Alias mismatch

`docs/ONBOARDING.md` step 2 specifies logging in with `sf org login web -a trailhead-playground`. During troubleshooting of the SSH login hang, the working login command used instead was `sf org login web --alias my-org --set-default` — a different alias chosen for the troubleshooting session, not the one the rest of the onboarding doc's commands (`--target-org trailhead-playground`) expect. This meant every subsequent onboarding-doc command copy-pasted as written would have failed with an unresolvable alias.

**Fix:** rather than re-authenticating, a second alias was pointed at the same already-authenticated org:

```bash
USERNAME=$(sf org display --target-org my-org --json | jq -r '.result.username')
sf alias set trailhead-playground="$USERNAME"
```

Note: `sf alias set <alias>=<org-id>` does **not** work for this purpose — the CLI's local auth store is keyed by username, not org ID, so aliasing directly to an org ID produces `NamedOrgNotFoundError: No authorization information found` even though the alias itself is created successfully. The alias value must be the username (or another alias that already resolves to a username).

Both `my-org` and `trailhead-playground` now resolve to the same connected org; `my-org` remains the default (`--set-default` was used at login).

## Baseline retrieval had never run

`force-app` was empty prior to this — confirmed with `find force-app -type f`, zero results — despite `manifest/package.xml` already containing a full 1207-line org-generated manifest from a prior (since-expired) authenticated session. Generating the manifest and retrieving the metadata it describes are separate steps; only the manifest generation had happened.

**Command run:**

```bash
sf project retrieve start --manifest manifest/package.xml --target-org trailhead-playground
```

**Result:** `status: Succeeded`, 859 `fileProperties` (distinct metadata components) retrieved into `force-app`, expanding to 3094 files on disk once component `-meta.xml` sidecars and folder structures are counted. The command also reported 104 `messages` — all non-fatal — of the form `Entity of type 'ListView' named '<Object>.<ListView>' cannot be found`, plus a handful of `Unable to retrieve file ... You don't have access to view or run flows of type Survey` and a couple of soft-deleted template references. These are expected: the manifest was generated with wildcard members (`<members>*</members>`) against the org's full metadata description, which includes standard list views, record types, and flows tied to clouds/features (Field Service, Surveys, and similar) that exist in the org's schema but aren't licensed, enabled, or accessible to this user. This is normal for a `--from-org` wildcard manifest against a stock Trailhead Playground and does not indicate a failed retrieval.

## State after this fix

- `force-app` is populated and matches what's actually in the org.
- Both org aliases work interchangeably.
- Nothing from this retrieval has been committed yet — per `docs/ONBOARDING.md` step 3, the next step is staging and committing `force-app`, `manifest`, and any docs changes. Note that the onboarding doc's suggested commit message (`chore: initialize sfdx project structure and baseline metadata`) was already used for the original scaffold commit; a distinct message (for example, `chore: retrieve baseline org metadata`) should be used here to avoid two commits sharing an identical message.
