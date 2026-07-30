# Metadata vs Data in Salesforce

A foundational distinction that determines what is versioned in this
repository and what is not.

---

## 1. The Two Layers of a Salesforce Org

Every Trailhead Playground — and every production org — consists of two
layers that operate at different speeds:

| Layer | What it contains | Change frequency | Versioned? |
|-------|-----------------|-------------------|------------|
| **Metadata** | Objects, fields, Apex classes, flows, layouts | Developer-paced (hours/days) | Yes — in this repo |
| **Data** | Records — Contacts, Accounts, Opportunities | User-paced (seconds/minutes) | No — lives in the org's database |

The same separation exists in any database-backed application: you version
the SQL schema and stored procedures, not the data rows.

---

## 2. Metadata — Everything in This Repository

### 2.1 Definition

Metadata describes the _structure_ of the org. It answers: _what can exist
in this org?_ Every file retrieved by `sf project retrieve start` is
metadata. Every file in `force-app/` is metadata.

### 2.2 What counts as metadata

| Category | Examples | Directory in `force-app/` |
|----------|----------|--------------------------|
| Apex classes | `StringListTest`, `StringListVariations` | `classes/` |
| Apex triggers | Code that fires on record changes | `triggers/` |
| Objects | `Account`, `Contact`, `CustomObject__c` | `objects/` |
| Fields | `Account.Industry`, `Contact.Department` | `objects/.../fields/` |
| Layouts | Page layouts for records | `layouts/` |
| Flows | Low-code automation | `flows/` |
| Profiles & permissions | `Admin`, `Standard User` | `profiles/` |
| Tabs, apps, flexipages | UI metadata | `tabs/`, `applications/` |
| Email templates | `SupportCaseResponse` | `email/` |

### 2.3 How metadata moves

```
┌─ Write in VS Code ──→  deploy ──→  Org
│
├─ Build in Dev Console ──→  retrieve ──→  force-app/ ──→  git commit
│
└─ Metadata is always the artifact. Data is never in the pipeline.
```

---

## 3. Data — What Lives in the Org Only

### 3.1 Definition

Data consists of the _records_ that populate the structure defined by
metadata. It answers: _what currently exists in the org?_ Data is never
retrieved by `sf project retrieve start`.

### 3.2 Examples

| Object | Example record |
|--------|---------------|
| Account | `Acme Inc.`, `Globex Corporation` |
| Contact | `Joe Smith`, `Kathy Smith` |
| Opportunity | `Acme - Q3 Deal`, `Globex - Renewal` |
| Case | `Login issue #4839` |

### 3.3 How data moves

Data is accessed via queries, not file retrieval:

```bash
# Inspect data from the CLI
sf data query -q "SELECT FirstName, LastName FROM Contact" -o trailhead-playground

# Manipulate data from Apex code
List<Contact> cons = [SELECT Name FROM Contact WHERE Department = 'Finance'];
update cons;
```

### 3.4 Exception — Custom Settings and Custom Metadata

Two metadata types blur the line. They are defined as metadata (deployed,
versioned) but behave like data at runtime (queried, read, written to).

| Type | Stored as | Deployed? | Writable at runtime? |
|------|----------|-----------|---------------------|
| Custom Settings | Metadata | Yes | Yes, with restrictions |
| Custom Metadata Types | Metadata | Yes | No — read-only in Apex |

They are the standard pattern for configuration values that need to be
deployed between environments.

---

## 4. Quick Reference

| Question | Answer |
|----------|--------|
| What's in this repo? | Metadata only |
| Where's the data? | In the org's database — run `sf data query` to see it |
| Does deploying overwrite data? | No. Metadata deploys never touch records |
| Does retrieving pull records? | No. `sf project retrieve start` pulls only metadata |
| How do I back up data? | Data Export, `sf data export`, or custom Apex scripts |
