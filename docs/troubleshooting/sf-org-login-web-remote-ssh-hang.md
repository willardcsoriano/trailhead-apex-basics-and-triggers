# Troubleshooting: Salesforce CLI OAuth Login Hang on Remote SSH VM

## Overview

This document records non-obvious blockers hit while working on this project and how they were resolved, so the fix doesn't have to be rediscovered from scratch next time. The first entry covers `sf org login web` (and the now-removed `sf org login device`) hanging indefinitely on the Salesforce OAuth authorization page when the CLI runs on a remote dev VM accessed via VS Code Remote-SSH. The root cause was a mismatched `localhost` OAuth callback: the CLI's local listener runs on the VM, but the browser completing the login runs on the local machine, so the post-authorization redirect had nothing to connect to. The fix was forwarding the CLI's local callback port through VS Code's Remote-SSH port forwarding before retrying the login.

---

## Table of Contents

- [Overview](#overview)
- [Blocker: `sf org login web` hangs forever on remote SSH dev VM](#blocker-sf-org-login-web-hangs-forever-on-remote-ssh-dev-vm)
  - [Symptom](#symptom)
  - [Attempts (chronological)](#attempts-chronological)
  - [Root cause](#root-cause)
  - [Solution](#solution)
  - [Follow-up: forwarded port going stale](#follow-up-forwarded-port-going-stale)
  - [Fallback (if SSH port forwarding is unavailable, e.g. blocked by server policy)](#fallback-if-ssh-port-forwarding-is-unavailable-eg-blocked-by-server-policy)
  - [References](#references)

## Blocker: `sf org login web` hangs forever on remote SSH dev VM

**Environment:** `sf` CLI (`@salesforce/cli` v2.143.6, npm-installed) running in a terminal on a remote dev VM, accessed from a local macOS machine via VS Code Remote-SSH. Target org: a Trailhead Playground (see `docs/ONBOARDING.md` for the login username).

### Symptom

Running the standard login command opened a browser page that either failed to resolve or spun forever on Salesforce's `RemoteAccessAuthorizationPage.apexp` (the OAuth "Allow Access" consent screen), with no error and no completion.

### Attempts (chronological)

1. **`sf org login web --alias my-org --set-default --instance-url https://<guessed-subdomain>.my.salesforce.com`**
   Guessed an instance URL from the Trailhead Playground username's domain pattern. Result: browser couldn't resolve the host at all ("We can't connect to the server"). The guessed instance URL was simply wrong — Playground usernames don't reliably map to a predictable My Domain hostname.

2. **`sf org login web --alias my-org --set-default`** (no `--instance-url`, letting it default to `login.salesforce.com` and redirect naturally)
   Reached the real org's OAuth consent page (`.../setup/secur/RemoteAccessAuthorizationPage.apexp?...`), but the page hung indefinitely with no error.

3. **`sf org login device --alias my-org --set-default`**
   Attempted as an alternative flow. The CLI reported this is not a valid `sf` command and silently substituted `org login web` instead — meaning this "attempt" was actually a repeat of #2. Root cause: Salesforce removed OAuth 2.0 Device Flow support for the default CLI connected app in 2025; `sf org login device` no longer exists in current CLI versions.

4. **`sf update`**
   Attempted to rule out a CLI bug by updating. Failed with `not updatable` — this install is npm-managed, so `sf update` (for the standalone installer) doesn't apply. The correct command is `npm update --global @salesforce/cli`.

5. **Diagnostics: checked for a local port conflict**
   Ran `lsof -i :1717` / `ss -tlnp` on the VM (port `1717` is the CLI's default local OAuth callback port). Port was free — ruled out a stale process holding the port.

6. **Checked the environment** (`hostname`, `$SSH_CONNECTION`)
   Confirmed the CLI was running on a remote VM reached over an active SSH connection, not on the same machine as the browser.

### Root cause

`sf org login web` starts a short-lived local HTTP server on the machine running the CLI (default `localhost:1717`) to catch the OAuth redirect after the user clicks **Allow**. When the CLI runs on a remote VM but the browser completing the login is on a different (local) machine, the redirect to `http://localhost:1717/...` resolves against the *local* machine's `localhost` — where nothing is listening — so the browser hangs waiting for a server that was never there. This is unrelated to the org, the username, the guessed instance URL, or the CLI version; it's a topology mismatch between where the CLI runs and where the browser runs.

### Solution

Forward the CLI's local callback port through VS Code Remote-SSH so the local browser's `localhost:1717` actually tunnels to the listener on the VM:

1. In VS Code, open the **Ports** panel (bottom panel, next to Terminal/Output/Debug Console — or Command Palette → "Forward a Port").
2. Forward port `1717` manually (don't rely solely on auto-detection).
3. In the VS Code integrated terminal (running on the remote VM), run:
   ```bash
   sf org login web --alias my-org --set-default
   ```
4. Complete the login in the browser as normal and click **Allow**. The redirect now tunnels through the forwarded port to the CLI process on the VM, and the command completes.

### Follow-up: forwarded port going stale

After the fix worked once, toggling the forwarded port off and back on was needed to get a clean login on a subsequent attempt. Likely cause: the VS Code SSH tunnel object can go stale (e.g. after an earlier login attempt was interrupted with Ctrl+C, tearing down the CLI's listener mid-tunnel) while the Ports panel still shows it as active. If a login hangs again despite the port being forwarded, stop the forward and re-add it before retrying — this forces VS Code to renegotiate a fresh tunnel against whatever is currently listening on `1717`.

### Fallback (if SSH port forwarding is unavailable, e.g. blocked by server policy)

Authenticate on a machine where the CLI and browser are co-located (e.g. a local install of `sf`), then transfer the authenticated session to the remote VM:

```bash
# on the machine with co-located browser + CLI, after a successful login:
sf org display --target-org my-org --verbose --json
# copy the "sfdxAuthUrl" value from the output, then on the remote VM:
echo "force://<sfdxAuthUrl value>" | sf org login sfdx-url --set-alias my-org --set-default --sfdx-url-stdin
```

Treat the `sfdxAuthUrl` value as a credential — it grants full CLI access to the org. Don't paste it into chat, commit it, or store it outside of this one-time transfer.

### References

- [Default Salesforce CLI OAuth 2.0 Device Flow Removal](https://help.salesforce.com/s/articleView?id=005135030&language=en_US&type=1)
- [A Practical Guide to SSH Tunnels: Local and Remote Port Forwarding](https://labs.iximiuz.com/tutorials/ssh-tunnels)
