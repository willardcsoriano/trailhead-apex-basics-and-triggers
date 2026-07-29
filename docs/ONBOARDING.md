# Trailhead Salesforce Apex Basics & Database - Onboarding Guide

This document outlines the step-by-step commands required to initialize the project, authenticate your Salesforce Trailhead Playground, set up metadata tracking, and execute the development and pull request workflow for the **Apex Basics & Database** badge.

**Trailhead Playground Username:** see your password manager / Trailhead account entry — intentionally not stored in this file.

**Commands in this document last verified against:** `@salesforce/cli` v2.143.6, 2026-07-28. If your installed version differs, spot-check each command with `sf <command> --help` before relying on it — see `docs/troubleshooting/` for why this matters.

---

## Table of Contents

- [1. Initialize SFDX Project Structure](#1-initialize-sfdx-project-structure)
- [2. Connect and Authenticate Trailhead Playground](#2-connect-and-authenticate-trailhead-playground)
- [3. Configure Target Org & Retrieve Baseline Metadata](#3-configure-target-org-retrieve-baseline-metadata)
- [4. Workflow per Trailhead Unit](#4-workflow-per-trailhead-unit)
  - [Step 4.1: Create Unit Feature Branch](#step-41-create-unit-feature-branch)
  - [Step 4.2: Regenerate Manifest & Retrieve Unit Metadata](#step-42-regenerate-manifest-retrieve-unit-metadata)
  - [Step 4.3: Commit and Submit Pull Request](#step-43-commit-and-submit-pull-request)
  - [Step 4.4: Merge & Cleanup](#step-44-merge-cleanup)

## 1. Initialize SFDX Project Structure

Run the following command to generate the standard Salesforce project structure in the current directory:

```bash
sf template generate project --name . --output-dir .
```

> **Verified against installed CLI:** `sf project generate` (the command previously documented here, with a `--bare` flag) is deprecated and `--bare` no longer exists as of `@salesforce/cli` v2.143.6 — the command silently redirects to `sf template generate project`. Before trusting any command in this document, confirm it against `sf <command> --help` on the CLI actually installed; see `docs/troubleshooting/` for the incident this was caught in.

---

## 2. Connect and Authenticate Trailhead Playground

Run the following command in your terminal to authenticate your Trailhead Playground org:

```bash
sf org login web -a trailhead-playground
```

Verify that your org is connected and active:

```bash
sf data query --query "SELECT Id, Name, OrganizationType FROM Organization" --target-org trailhead-playground
```

---

## 3. Configure Target Org & Retrieve Baseline Metadata

Set `trailhead-playground` as the default target org for the workspace:

```bash
sf config set target-org trailhead-playground
```

Generate the initial project manifest (`package.xml`) from your org:

```bash
sf project generate manifest --from-org trailhead-playground --output-dir manifest
```

Retrieve the baseline org metadata into `force-app`:

```bash
sf project retrieve start --manifest manifest/package.xml --target-org trailhead-playground
```

Stage and commit the baseline metadata to `master`. Use a message distinct from the project-structure commit created in Step 1 — bundling scaffolding and org-specific metadata into one commit mixes two different concerns:

```bash
git add .
git commit -m "chore: retrieve baseline org metadata"
git push -u origin master
```

---

## 4. Workflow per Trailhead Unit

For each unit within the **Apex Basics & Database** module:

### Step 4.1: Create Unit Feature Branch
```bash
git checkout master
git pull origin master
git checkout -b unit-0X-<unit-title-slug>
```

### Step 4.2: Regenerate Manifest & Retrieve Unit Metadata
After completing guided activities, Apex coding, or hands-on challenges in the Salesforce Setup GUI / Developer Console, run the combined command to regenerate the project manifest from your org, retrieve metadata, and write a JSON audit log to `docs/`:

```bash
mkdir -p docs && sf project generate manifest --from-org trailhead-playground --output-dir manifest && CMD="sf project retrieve start --manifest manifest/package.xml --target-org trailhead-playground --json" && $CMD | jq --arg command "$CMD" --arg timestamp "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" --arg branch "$(git branch --show-current)" '{command: $command, timestamp: $timestamp, branch: $branch, result: .}' > docs/unit-0X-retrieval-log.json
```

### Step 4.3: Commit and Submit Pull Request
Stage the retrieved changes and commit using conventional commit syntax:

```bash
git add force-app manifest docs
git commit -m "feat(apex-basics): <description-of-changes>"
git push -u origin unit-0X-<unit-title-slug>
gh pr create --title "<Unit Title>" --body "Consolidated metadata and Apex code for Unit 0X."
```

### Step 4.4: Merge & Cleanup
Merge the PR and clean up stale branches:

```bash
gh pr merge --merge --delete-branch
git checkout master
git pull origin master
```
