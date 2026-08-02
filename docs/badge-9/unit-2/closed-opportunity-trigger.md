# Badge 9 Unit 2 — Closed Opportunity Trigger

> **Status: Pending** — Challenge not yet submitted.

## Challenge

Create a bulkified Apex trigger that adds a follow-up task to an opportunity
when its stage is _Closed Won_. The trigger must handle 200+ records in a single
transaction.

- **Trigger name:** `ClosedOpportunityTrigger`
- **Object:** Opportunity
- **Events:** `after insert`, `after update`
- **Condition:** `StageName == 'Closed Won'`
- **Operation:** Create a `Task` with:
  - `Subject`: `'Follow Up Test Task'`
  - `WhatId`: the Opportunity ID
- **Requirement:** Must be bulkified — one DML statement for the entire list, no SOQL or DML inside loops

---

## Concepts — Bulkification

A trigger is **bulkified** when it can process 200+ records without hitting
governor limits. The two rules:

1. **No SOQL or DML inside a loop.** Collect everything into a `List`, then
   perform one query or one DML statement after the loop.
2. **Operate on `Trigger.new` in bulk.** `Trigger.new` already contains every
   record in the transaction — iterate it, but don't query inside it.

### Why `after` and not `before`

| Event | Works? | Reason |
|---|---|---|
| `after insert` | Yes | Tasks need the Opportunity Id to exist. Before insert, the Id is null. |
| `after update` | Yes | Same — Id exists, we're linking via `WhatId`. |

---

## Trigger Code

The trigger is identical regardless of path:

```apex
// AFTER trigger: Opportunity.Id already exists, so WhatId can reference it.
// Bulk-safe: one list-collect pass, one DML at the end. No SOQL or DML in loop.
trigger ClosedOpportunityTrigger on Opportunity(after insert, after update) {

    // Collect tasks in a list — insert once at the end.
    List<Task> tasks = new List<Task>();

    // Trigger.new holds every record in this transaction. Iterating it
    // does not consume a SOQL query — it's in-memory.
    for (Opportunity opp : Trigger.new) {

        // Guard: only fire for Closed Won opportunities.
        // Trigger.old is null on insert, so skip the "already was Closed Won" check
        // on insert — all inserted records are new by definition.
        if (opp.StageName == 'Closed Won') {
            tasks.add(new Task(
                Subject = 'Follow Up Test Task',
                WhatId = opp.Id
            ));
        }
    }

    // One DML statement for the entire list. Governor limit: 1 of 150.
    if (!tasks.isEmpty()) {
        insert as user tasks;
    }
}
```

---

## Path A — Source-driven (VS Code + CLI)

### Step 1: Write the trigger file

Create `force-app/main/default/triggers/ClosedOpportunityTrigger.trigger` with
the trigger code above.

Create `force-app/main/default/triggers/ClosedOpportunityTrigger.trigger-meta.xml`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<ApexTrigger xmlns="http://soap.sforce.com/2006/04/metadata">
    <apiVersion>63.0</apiVersion>
    <status>Active</status>
</ApexTrigger>
```

### Step 2: Deploy

```bash
sf project deploy start -d force-app/main/default/triggers -o trailhead-playground
```

### Step 3: Retrieve into version control

```bash
sf project retrieve start -m ApexTrigger:ClosedOpportunityTrigger -o trailhead-playground
```

---

## Path B — Declarative (GUI only)

### Step 1: Open Developer Console

Gear icon (⚙️) → **Developer Console**

### Step 2: Create the trigger

1. **File** → **New** → **Apex Trigger**
2. **Name:** `ClosedOpportunityTrigger`
3. **sObject:** `Opportunity`
4. Click **Submit**
5. Replace the generated template with the trigger code above
6. **File** → **Save** (Ctrl+S)

### Step 3: Verify

**Debug** → **Open Execute Anonymous Window** (Ctrl+E). Check **Open Log**,
paste the Happy Path test below, click **Execute**.

### Step 4: Submit

Back in Trailhead, scroll to the bottom of the unit, click **Check Challenge**.

---

## Test Payloads

Each test is **self-deleting** and **idempotent** — run in any order, any number
of times. All paths use the Developer Console's Execute Anonymous Window
(`Ctrl+E`). Check **Open Log** before executing.

The logs are intentionally verbose: every step writes to `USER_DEBUG` so the log
alone tells the full story.

### Happy Path — Insert with Closed Won

This is the primary scenario: a new Opportunity with `StageName = 'Closed Won'`
is inserted. The trigger should create exactly one Task linked to it.

```apex
// === idempotency guard ===
List<Opportunity> leftovers = [SELECT Id FROM Opportunity
                               WHERE Name = '[Test] Closed Opportunity Trigger - Insert'
                               WITH USER_MODE];
if (leftovers.size() > 0) {
    delete as user leftovers;
    System.debug('CLEANUP: deleted ' + leftovers.size() + ' leftover opportunity(s)');
} else {
    System.debug('CLEANUP: no leftovers to delete');
}

// === arrange ===
System.debug('ARRANGE: creating Opportunity with StageName=Closed Won');
Opportunity opp = new Opportunity(
    Name = '[Test] Closed Opportunity Trigger - Insert',
    StageName = 'Closed Won',
    CloseDate = System.today().addMonths(1)
);
insert as user opp;
System.debug('ARRANGE: inserted Opportunity Id=' + opp.Id);

// === assert ===
System.debug('ASSERT: querying Tasks linked to the new Opportunity');
List<Task> tasks = [SELECT Id, Subject, WhatId
                    FROM Task
                    WHERE WhatId = :opp.Id
                    WITH USER_MODE];
System.debug('ASSERT: found ' + tasks.size() + ' task(s)');
for (Task t : tasks) {
    System.debug('ASSERT:   Task: ' + t.Subject + ' | WhatId=' + t.WhatId);
}
System.assertEquals(1, tasks.size(),
    'ClosedOpportunityTrigger should create exactly one Task');
System.assertEquals('Follow Up Test Task', tasks[0].Subject,
    'Task Subject should be "Follow Up Test Task"');
System.assertEquals(opp.Id, tasks[0].WhatId,
    'Task WhatId should reference the Opportunity');
System.debug('PASS: Task "' + tasks[0].Subject + '" created for Opportunity ' + opp.Id);

// === self-deleting ===
// Tasks are not master-detail with Opportunity — delete explicitly.
System.debug('TEARDOWN: deleting Task and Opportunity');
delete as user tasks;
delete as user opp;
System.debug('TEARDOWN: cleanup complete');
```

### Negative Path — Not Closed Won

This test proves the guard clause works: when StageName is not _Closed Won_, the
trigger must not create a task.

```apex
// === idempotency guard ===
List<Opportunity> leftovers = [SELECT Id FROM Opportunity
                               WHERE Name = '[Test] Closed Opportunity Trigger - Skip'
                               WITH USER_MODE];
if (leftovers.size() > 0) {
    delete as user leftovers;
    System.debug('CLEANUP: deleted ' + leftovers.size() + ' leftover opportunity(s)');
} else {
    System.debug('CLEANUP: no leftovers to delete');
}

// === arrange ===
System.debug('ARRANGE: creating Opportunity with StageName=Prospecting (not Closed Won)');
Opportunity opp = new Opportunity(
    Name = '[Test] Closed Opportunity Trigger - Skip',
    StageName = 'Prospecting',
    CloseDate = System.today().addMonths(1)
);
insert as user opp;
System.debug('ARRANGE: inserted Opportunity Id=' + opp.Id);

// === assert ===
System.debug('ASSERT: querying Tasks — should find none');
List<Task> tasks = [SELECT Id, Subject
                    FROM Task
                    WHERE WhatId = :opp.Id
                    WITH USER_MODE];
System.assertEquals(0, tasks.size(),
    'No Task should be created when StageName is not Closed Won');
System.debug('PASS: no Task created for non-Closed-Won Opportunity');

// === self-deleting ===
System.debug('TEARDOWN: deleting Opportunity Id=' + opp.Id);
delete as user opp;
System.debug('TEARDOWN: cleanup complete');
```

### Bulk Test — 200+ Records

This test proves the trigger is truly bulkified — 200 records in one transaction,
one DML for all Tasks. Exceeds no governor limits.

```apex
// === idempotency guard ===
List<Opportunity> leftovers = [SELECT Id FROM Opportunity
                               WHERE Name LIKE '[Test] Closed Opp Trigger - Bulk%'
                               WITH USER_MODE];
if (leftovers.size() > 0) {
    delete as user leftovers;
    System.debug('CLEANUP: deleted ' + leftovers.size() + ' leftover opportunity(s)');
} else {
    System.debug('CLEANUP: no leftovers to delete');
}

// === arrange ===
Integer recordCount = 200;
System.debug('ARRANGE: creating ' + recordCount + ' Opportunities with StageName=Closed Won');
List<Opportunity> opps = new List<Opportunity>();
for (Integer i = 0; i < recordCount; i++) {
    opps.add(new Opportunity(
        Name = '[Test] Closed Opp Trigger - Bulk ' + i,
        StageName = 'Closed Won',
        CloseDate = System.today().addMonths(1)
    ));
}
insert as user opps;
System.debug('ARRANGE: inserted ' + opps.size() + ' Opportunities');
System.debug('ARRANGE: DML statements used so far: ' + Limits.getDmlStatements());

// === assert ===
System.debug('ASSERT: counting Tasks created');
Integer taskCount = [SELECT COUNT() FROM Task
                     WHERE WhatId IN :opps
                     WITH USER_MODE];
System.assertEquals(recordCount, taskCount,
    'Should have created exactly ' + recordCount + ' Tasks (one per Opportunity)');
System.debug('PASS: ' + taskCount + ' Tasks created for ' + recordCount + ' Opportunities');

// === self-deleting ===
System.debug('TEARDOWN: deleting Tasks and Opportunities');
List<Task> tasks = [SELECT Id FROM Task WHERE WhatId IN :opps WITH USER_MODE];
delete as user tasks;
delete as user opps;
System.debug('TEARDOWN: deleted ' + tasks.size() + ' Tasks and ' + opps.size() + ' Opportunities');
```

### Reading the log

After running a test, open the log and check **Debug Only**. Each phase is
tagged so the output is self-documenting.

---

## What This Trigger Does and Does Not Do

| Scope | Behavior |
|---|---|
| Creates Task on Closed Won insert | Yes — one Task per Opportunity |
| Creates Task on Closed Won update | Yes — fires when Stage changes to Closed Won |
| Handles 200+ records at once | Yes — one list-collect pass, one DML |
| Multiple Closed Won updates | Creates a new Task each time — no deduplication |
| Tasks are self-deleting test data? | Yes — every test payload deletes its own Tasks and Opportunities |
