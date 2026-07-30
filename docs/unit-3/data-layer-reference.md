# Salesforce Data Layer — A Reference Guide

An introduction to the four mechanisms for reading, writing, and searching
data on the Salesforce Platform. Each tool serves a distinct purpose; together
they form the data layer of any Apex application.

This guide assumes familiarity with basic programming concepts but no prior
Salesforce knowledge.

---

## 1. Overview

Salesforce stores data in objects (tables) composed of fields (columns) and
records (rows). The platform exposes four distinct interfaces for interacting
with this data:

| Tool | Classification | Primary use |
|------|---------------|-------------|
| DML | Apex statement | Create, update, and delete records from within Apex code |
| SOQL | Apex query expression | Read records by field criteria |
| SOSL | Apex search expression | Full-text search across multiple objects |
| `sf data` CLI | Terminal command | Ad-hoc inspection from outside the org |

The first three are embedded in Apex — they appear inside `.cls` class files
and execute on Salesforce servers. The fourth is a developer tool that runs on
your local machine.

---

## 2. DML — Data Manipulation Language

### 2.1 What it is

DML statements modify records. They are Apex keywords, not a separate language.

### 2.2 Available statements

| Statement | Behaviour |
|-----------|-----------|
| `insert` | Creates new records |
| `update` | Modifies existing records |
| `upsert` | Creates or updates depending on whether a record exists |
| `delete` | Removes records |
| `undelete` | Restores records from the Recycle Bin |
| `merge` | Combines up to three records into one |

### 2.3 Syntax

```apex
// Insert a single record
Account a = new Account(Name='Acme');
insert a;

// Insert multiple records in bulk (recommended)
List<Account> accounts = new List<Account>{
    new Account(Name='Acme'),
    new Account(Name='Globex')
};
insert accounts;
```

### 2.4 Bulk DML

One DML statement operating on a list counts as one statement toward governor
limits, regardless of how many records are in the list. Always prefer passing
a `List<sObject>` to a single DML call over calling DML inside a loop.

```apex
// Good — one DML statement for the entire list
insert accountList;

// Bad — one DML statement per record
for (Account a : accountList) {
    insert a;
}
```

### 2.5 Governor limit

A single Apex transaction may perform at most 150 DML statements. Bulk
operations are the primary defence against this limit.

---

## 3. SOQL — Salesforce Object Query Language

### 3.1 What it is

SOQL retrieves records by field criteria. It is read-only. Syntactically
similar to SQL `SELECT` but operates on Salesforce objects, not database
tables.

### 3.2 Syntax

```apex
// Embedded in Apex, surrounded by square brackets
List<Contact> cons = [SELECT FirstName, LastName FROM Contact WHERE Department = 'Finance'];

// Or as a string with Database.query()
List<Contact> cons = Database.query('SELECT FirstName, LastName FROM Contact');
```

### 3.3 Key differences from SQL

| Concept | SQL | SOQL |
|---------|-----|------|
| Wildcard | `SELECT *` | Not supported; list fields explicitly |
| Join syntax | `JOIN ... ON` | Dot notation for parent/child relationships |
| Aggregate functions | `COUNT`, `SUM`, `AVG`, etc. | `COUNT()` only in SOQL; others require Apex |
| LIMIT clause | Optional | Supported but SOQL also has a built-in auto-limit |

### 3.4 Filtering with WHERE

```apex
// Equality
[SELECT Name FROM Account WHERE Industry = 'Technology']

// Comparison operators
[SELECT Name FROM Account WHERE AnnualRevenue > 1000000]

// String matching
[SELECT Name FROM Contact WHERE LastName LIKE 'Smi%']

// Set-based filtering
[SELECT Name FROM Contact WHERE Id IN :idSet]
```

### 3.5 SOQL outside Apex

The `sf data query` CLI command sends a SOQL string to the org and prints
results. It is identical to embedded SOQL in syntax.

```bash
sf data query --query "SELECT Id, Name FROM Account LIMIT 10" --target-org trailhead-playground
```

---

## 4. SOSL — Salesforce Object Search Language

### 4.1 What it is

SOSL performs full-text search across one or more objects simultaneously. It
returns records where the search term appears in any searchable text field
(name, email, phone, description, etc.).

### 4.2 Syntax

```apex
// Embedded in Apex, surrounded by square brackets
List<List<sObject>> results = [FIND 'Acme' IN ALL FIELDS RETURNING Account, Contact];
```

The return type is a list of lists — one inner list per object specified.

### 4.3 When to use SOSL over SOQL

| Use SOQL when | Use SOSL when |
|---------------|---------------|
| You know which object and field to query | You don't know which field holds the value |
| You need precise filtering with operators | You need broad search across multiple objects |
| You want structured, predictable results | You want Google-like search behaviour |

### 4.4 SOSL outside Apex

```bash
sf data search --query "FIND {Acme} IN ALL FIELDS RETURNING Account, Contact" --target-org trailhead-playground
```

---

## 5. `sf data` CLI Commands

### 5.1 Purpose

These commands run against an authenticated org from the terminal. They are
read-only and stateless — no `.cls` files are created, nothing is committed.

### 5.2 Available commands

| Command | What it sends | Returns |
|---------|--------------|---------|
| `sf data query` | A SOQL string | Matching records |
| `sf data search` | A SOSL string | Matching records grouped by object |
| `sf data get record` | An object type and ID | A single record |
| `sf data create record` | An object type and field values | Creates a record and returns its ID |
| `sf data update record` | An object type, ID, and field values | Updates a record |
| `sf data delete record` | An object type and ID | Deletes a record |

### 5.3 Examples

```bash
# Query records
sf data query --query "SELECT Id, Name FROM Account LIMIT 5" -o trailhead-playground

# Get a single record by ID
sf data get record --sobject Account --record-id 001xxxxxxxxxxxx -o trailhead-playground

# Search across objects
sf data search --query "FIND {Smith} IN ALL FIELDS RETURNING Contact, Lead" -o trailhead-playground
```

---

## 6. Anonymous Apex

### 6.1 What it is

The Developer Console's **Execute Anonymous** window (Ctrl+E) runs Apex code
immediately without saving a class. It supports DML, SOQL, SOSL, and
`System.debug()`.

### 6.2 When to use it

- Testing DML or SOQL syntax before writing a class
- One-time data fixes
- Debugging with `System.debug()`

### 6.3 Limitations

- Cannot define new classes or methods
- Code is not saved or versioned
- Runs in the current user's context with their permissions

---

## 7. Summary — Which Tool for Which Task

| Task | Tool |
|------|------|
| Create/update/delete records in Apex code | DML statements |
| Read records by field criteria in Apex code | SOQL |
| Search records across objects in Apex code | SOSL |
| Inspect records from the terminal | `sf data query` / `sf data search` |
| Test a one-off snippet without saving a file | Anonymous Apex (Ctrl+E) |
| Commit business logic to the repository | Apex class (`.cls` file) containing DML, SOQL, or SOSL |
