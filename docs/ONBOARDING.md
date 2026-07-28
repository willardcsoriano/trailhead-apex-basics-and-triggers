# Trailhead Salesforce Apex Basics & Database - Onboarding Guide

This document outlines the step-by-step commands required to initialize the project, authenticate your Salesforce Trailhead Playground, set up metadata tracking, and execute the development and pull request workflow for the **Apex Basics & Database** badge.

**Trailhead Playground Username:** `soriano.willard@wise-hawk-9vytqq.com`

---

## 1. Initialize SFDX Project Structure

Run the following command to generate the standard Salesforce project structure in the current directory:

```bash
sf project generate --name . --bare
```

---

## 2. Connect and Authenticate Trailhead Playground

Run the following command in your terminal to authenticate your Trailhead Playground org (`soriano.willard@wise-hawk-9vytqq.com`):

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

Stage and commit the baseline metadata to `master`:

```bash
git add .
git commit -m "chore: initialize sfdx project structure and baseline metadata"
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
