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

### 1.1 Unified Comparison — DML, SOQL, SOSL

| | DML | SOQL | SOSL |
|---|-----|------|------|
| Purpose | Write records | Read records | Search records |
| Creates records | `insert` | No | No |
| Updates records | `update`, `upsert` | No | No |
| Deletes records | `delete` | No | No |
| Reads by field criteria | No | `WHERE Industry = 'Tech'` | No |
| Full-text search | No | No | `FIND {Acme}` |
| Cross-object search | No | No | Yes |
| Operators | None | `=`, `>`, `LIKE`, `IN` | None |
| Bulk support | Yes — list of sObjects | Yes — list returned | Yes — list of lists |
| Governor limit | 150 DML statements | 100 queries | 20 searches |
| Used with `sf data` CLI | `sf data create/update/delete record` | `sf data query` | `sf data search` |

There is no lower-level data API in Apex. DML, SOQL, and SOSL are the
primitives. Everything else — `Database.insert()`, `Database.query()` —
ultimately translates to one of the three.

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

### 4.3 SOQL vs SOSL

Both are read-only. The difference is precision vs breadth.

| | SOQL | SOSL |
|---|------|------|
| Targets | One object at a time | Multiple objects at once |
| Matches on | Specific fields you name | Any searchable text field |
| Operators | `=`, `>`, `LIKE`, `IN` | None — plain text match |
| Returns | `List<Contact>` | `List<List<sObject>>` — one list per object |
| When to use | You know the object and field | You don't know what field holds the value |

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

---

## 8. The `sf` CLI in Practice

The `sf` CLI connects your local environment (VS Code, terminal) to your
Trailhead Playground. This section covers how the four data-layer tools
map to everyday CLI workflows.

### 8.1 The loop — write, deploy, test, commit

```
┌─ Write .cls file in VS Code ────────────────────────────────────┐
│                                                                  │
│  public class MyClass {                                          │
│      public static void run() {                                  │
│          List<Account> accts = [SELECT Name FROM Account];// SOQL│
│          for (Account a : accts) {                               │
│              a.Description = 'Updated';                          │
│          }                                                       │
│          update accts;                            // DML         │
│      }                                                           │
│  }                                                               │
│                                                                  │
├─ Deploy to org ─────────────────────────────────────────────────┤
│  sf project deploy start -d force-app -o trailhead-playground   │
│                                                                  │
├─ Inspect data ──────────────────────────────────────────────────┤
│  sf data query -q "SELECT Name FROM Account"                    │
│                                                                  │
├─ Commit to git ─────────────────────────────────────────────────┤
│  git add force-app && git commit -m "feat: add MyClass"         │
└──────────────────────────────────────────────────────────────────┘
```

### 8.2 Common commands

| Task | Command |
|------|---------|
| Deploy all Apex classes | `sf project deploy start -d force-app -o trailhead-playground` |
| Retrieve all metadata | `sf project retrieve start --manifest manifest/package.xml -o trailhead-playground` |
| Run a SOQL query | `sf data query -q "SELECT Id, Name FROM Contact" -o trailhead-playground` |
| Run a SOSL search | `sf data search -q "FIND {Smith} IN ALL FIELDS RETURNING Contact" -o trailhead-playground` |
| Create a record | `sf data create record -s Contact -v "FirstName=Joe LastName=Smith" -o trailhead-playground` |
| Update a record | `sf data update record -s Contact -i 003xxxxx -v "Title=Manager" -o trailhead-playground` |
| Delete a record | `sf data delete record -s Contact -i 003xxxxx -o trailhead-playground` |

### 8.3 Where does Anonymous Apex fit?

Anonymous Apex (Ctrl+E in the Dev Console) and the CLI solve the same problem
from different angles. Choose whichever is faster:

| Scenario | Use CLI | Use Anonymous Apex |
|----------|---------|-------------------|
| Quick data look | `sf data query` | Not needed |
| Test a DML snippet before writing a class | Not ideal — single-line only | Paste the snippet, execute |
| Run multi-step logic with variables and loops | No — CLI can't run Apex | Yes |
| One-off record fix | `sf data update record` | Overkill |

The division: CLI for inspection, Anonymous Apex for experimentation. Both
interact with the same org; neither replaces the other.

