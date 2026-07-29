# Troubleshooting: Onboarding Doc Hardening Pass

## Overview

This document records a deliberate hardening pass over `docs/ONBOARDING.md`, done after the `--bare` flag drift incident (see `sf-org-login-web-remote-ssh-hang.md` and `org-alias-mismatch-and-baseline-retrieval.md` in this folder) exposed that the doc could silently go stale. Three changes were made: the exact CLI version the document's commands were last verified against is now recorded up front, so a future version mismatch is a quick eyeball-check instead of a surprise; the Trailhead Playground username was removed from plaintext in a permanently-committed file; and a duplicate commit message between the project-structure commit and the baseline-metadata commit was resolved so the two concerns stay in separate commits, consistent with this project's one-concern-per-commit convention.

---

## Table of Contents

- [Overview](#overview)
- [Change 1: recorded the verified CLI version](#change-1-recorded-the-verified-cli-version)
- [Change 2: removed the plaintext username](#change-2-removed-the-plaintext-username)
- [Change 3: fixed the duplicate commit message](#change-3-fixed-the-duplicate-commit-message)
- [Result](#result)

## Change 1: recorded the verified CLI version

Added a line near the top of `ONBOARDING.md`: `Commands in this document last verified against: @salesforce/cli v2.143.6, 2026-07-28`, with a pointer to spot-check with `sf <command> --help` if the installed version differs. Without this, there was no signal in the document itself that its commands could be stale — the `--bare` flag was wrong for an unknown amount of time before anyone noticed.

## Change 2: removed the plaintext username

`ONBOARDING.md` previously stated the Trailhead Playground login username directly, twice, in a file that is committed to git permanently. Replaced both occurrences with a pointer to check the password manager / Trailhead account instead. This does not affect any command in the document — none of them require the username to be typed in; `sf org login web` authenticates interactively in the browser.

## Change 3: fixed the duplicate commit message

Step 3 of the original document instructed committing the baseline metadata retrieval with the message `chore: initialize sfdx project structure and baseline metadata` — identical to the message actually used for the earlier, separate project-structure commit (`b5ac216`). Following the document as written a second time would have produced two commits with the same subject line describing two different things (tooling scaffold vs. org-specific metadata snapshot). Changed the documented message to `chore: retrieve baseline org metadata` and added a note explaining why the two commits should stay separate.

## Result

`docs/ONBOARDING.md` now carries its own drift checkpoint (the verified-version line), no longer commits a secret-adjacent identifier to git history going forward, and its commit instructions match the one-concern-per-commit convention already used elsewhere in this project's git history.
