# Badge 9 Unit 1 — Account Address Trigger

> **Status: Passed** — Challenge checked and approved by Trailhead.

## Challenge

Create an Apex trigger that sets an account's **Shipping Postal Code** to match
the **Billing Postal Code** when the _Match Billing Address_ checkbox is selected.

- **Trigger name:** `AccountAddressTrigger`
- **Object:** Account
- **Events:** `before insert`, `before update`
- **Condition:** `Match_Billing_Address__c == true`
- **Operation:** `ShippingPostalCode = BillingPostalCode`

---

## Concepts — "Paths" and "Payloads"

This doc uses two kinds of "path." Don't mix them up.

### Deployment paths (A vs B)

Two ways to get the trigger into the org. Pick one.

| Path | You work in | The artifact is |
|---|---|---|
| **A — Source-driven** | VS Code + terminal | `.trigger` file → `sf deploy` |
| **B — Declarative** | Browser UI (Developer Console) | Paste code → File → Save |

Both produce the same trigger. The trigger itself does not change.

### Test paths (Happy / Update / Negative)

These are **test scenarios**, not deployment choices. You run them to verify the
trigger behaves correctly in different situations.

| Test scenario | What it proves |
|---|---|
| **Happy Path** | Checkbox on during insert → trigger copies billing to shipping |
| **Update** | Checkbox on during update → trigger re-copies new billing to shipping |
| **Negative Path** | Checkbox off → trigger does nothing; shipping stays as-is |

### What is a "payload"?

A payload is the block of code you paste into the **Execute Anonymous Window**
(`Ctrl+E`) and run. It's called a payload because it's a self-contained unit of
work: it sets up data, makes assertions, and cleans up. Nothing depends on it.
You run it, read the log, and move on.

Each payload is:
- **Self-deleting** — removes its own test data at the end
- **Idempotent** — deletes leftovers at the start, so running it twice is safe
- **Verbose** — every step writes to the log so the output is readable by itself

---

## Trigger Code

The trigger is identical regardless of path:

```apex
// Because this is a BEFORE trigger, mutating Trigger.new commits the field
// change as part of the original DML — no UPDATE statement needed, no
// recursion risk, no extra governor limit consumed.
trigger AccountAddressTrigger on Account(before insert, before update) {

    // Trigger.new is a List<sObject> with exactly the records being operated
    // on. One pass, one context. No SOQL inside the loop.
    for (Account acc : Trigger.new) {

        // Guard clause: only fire when the checkbox is explicitly checked.
        // Records with the field null or false pass through untouched.
        if (acc.Match_Billing_Address__c == true) {
            acc.ShippingPostalCode = acc.BillingPostalCode;
        }
    }
}
```

### Why `before` and not `after`

| Event | Works? | Reason |
|---|---|---|
| `before insert` | Yes | Set the field on the incoming record; no DML needed. The value is committed automatically. |
| `after insert` | No | Would require an additional `update` DML on the same records — infinite recursion risk. |
| `before update` | Yes | Same as insert. Modify `Trigger.new` in place. |
| `after update` | No | Same recursion problem. |

The `before` events let you mutate `Trigger.new` without issuing extra DML — the
platform commits the changes as part of the original operation. This is the
idiomatic pattern for field-sync triggers.

### Why `Trigger.new` and not a SOQL query

`Trigger.new` holds the records _as they are being processed_. No query needed.
The trigger fires in the same transaction that updates the records, so the
in-memory copy is what gets committed.

---

## Path A — Source-driven (VS Code + CLI)

The repo is the source of truth. You write files, deploy them, retrieve to
confirm.

### Step 1: Create the custom field

```bash
sf schema generate field -o Account -l 'Match Billing Address' \
  -n Match_Billing_Address -t Checkbox -d false -o trailhead-playground
```

### Step 2: Write the trigger file

Create `force-app/main/default/triggers/AccountAddressTrigger.trigger` with the
trigger code above.

Create `force-app/main/default/triggers/AccountAddressTrigger.trigger-meta.xml`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<ApexTrigger xmlns="http://soap.sforce.com/2006/04/metadata">
    <apiVersion>63.0</apiVersion>
    <status>Active</status>
</ApexTrigger>
```

### Step 3: Deploy

```bash
sf project deploy start -d force-app/main/default/triggers -o trailhead-playground
```

### Step 4: Retrieve into version control

```bash
mkdir -p docs/badge-9/unit-1
sf project retrieve start -m ApexTrigger:AccountAddressTrigger -o trailhead-playground --json \
  | jq --arg timestamp "$(date -u +'%Y-%m-%dT%H:%M:%SZ')" --arg branch "$(git branch --show-current)" \
  '{command: "sf project retrieve start -m ApexTrigger:AccountAddressTrigger", timestamp: $timestamp, branch: $branch, result: .}' \
  > docs/badge-9/unit-1/retrieval-log.json
```

---

## Path B — Declarative (GUI only)

### Step 1: Create the Match Billing Address custom field

Navigate: **Setup** (gear icon ⚙️) → **Object Manager** → **Account** →
**Fields & Relationships** → **New**

**Step 1 of 4 — Choose the field type**

- Select **Checkbox** → click **Next**

**Step 2 of 4 — Enter the details**

```
Field Label:  Match Billing Address
Field Name:   Match_Billing_Address      (auto-filled from label)
Default Value:  ○ Checked  ● Unchecked
```

Click **Next**.

**Step 3 of 4 — Establish field-level security**

Accept the defaults (visible to all profiles) → click **Next**.

**Step 4 of 4 — Add to page layouts**

Click **Save**.

The field now exists on Account. Its API name is `Match_Billing_Address__c`.

### Step 2: Create the trigger in Developer Console

Open the **Developer Console**: gear icon (⚙️) → **Developer Console**
(a new window or browser tab opens).

1. **File** → **New** → **Apex Trigger**
2. Dialog appears:
   - **Name:** `AccountAddressTrigger`
   - **sObject:** `Account`
3. Click **Submit**
4. An editor opens with a generated template. Replace the entire contents with
   the trigger code from the [Trigger Code](#trigger-code) section above.
5. **File** → **Save** (or `Ctrl+S`)

Saving deploys the trigger directly to the org — live immediately, no separate
deploy step.

### Step 3: Verify with Anonymous Apex

In the Developer Console: **Debug** → **Open Execute Anonymous Window** (or
`Ctrl+E`).

1. Check the box: **Open Log**
2. Paste the Happy Path test:

   ```apex
   // === idempotency guard ===
   List<Account> leftovers = [SELECT Id FROM Account
                              WHERE Name = '[Test] Account Address Trigger - Verify'
                              WITH USER_MODE];
   if (leftovers.size() > 0) {
       delete as user leftovers;
       System.debug('CLEANUP: deleted ' + leftovers.size() + ' leftover account(s)');
   } else {
       System.debug('CLEANUP: no leftovers to delete');
   }

   // === arrange ===
   System.debug('ARRANGE: creating account with BillingPostalCode=94105, ShippingPostalCode=00000, Match_Billing_Address__c=true');
   Account acc = new Account(
       Name = '[Test] Account Address Trigger - Verify',
       BillingPostalCode = '94105',
       ShippingPostalCode = '00000',
       Match_Billing_Address__c = true
   );
   insert as user acc;
   System.debug('ARRANGE: inserted account Id=' + acc.Id);

   // === assert ===
   System.debug('ASSERT: querying persisted record to verify trigger mutated ShippingPostalCode');
   Account inserted = [SELECT BillingPostalCode, ShippingPostalCode
                       FROM Account WHERE Id = :acc.Id WITH USER_MODE];
   System.debug('ASSERT: persisted BillingPostalCode=' + inserted.BillingPostalCode
       + ', ShippingPostalCode=' + inserted.ShippingPostalCode);
   System.assertEquals('94105', inserted.ShippingPostalCode);
   System.debug('PASS: ShippingPostalCode correctly set to ' + inserted.ShippingPostalCode);

   // === self-deleting ===
   System.debug('TEARDOWN: deleting account Id=' + acc.Id);
   delete as user acc;
   System.debug('TEARDOWN: account deleted');
   ```

3. Click **Execute**
4. Under the **Logs** tab (bottom panel), double-click the newest log entry
5. Check **Debug Only** (filters system noise)
6. Look for `USER_DEBUG`: should show `PASS: ShippingPostalCode = 94105`

If you see a red error, the trigger has a syntax issue — return to Step 2, fix
the code, save again, and re-run.

### Step 4: Submit the Trailhead challenge

1. Return to the Trailhead module in your browser
2. Scroll to the bottom of the unit
3. Click **Check Challenge**

Green = pass. Red = Trailhead tells you which assertion failed — fix the trigger
(Step 2, item 5), save, retry.

---

## Test Payloads

Each test is **self-deleting** and **idempotent** — run in any order, any number
of times. All paths use the Developer Console's Execute Anonymous Window
(`Ctrl+E`). Check **Open Log** before executing.

The logs are intentionally verbose: every step writes to `USER_DEBUG` so the log
alone tells the full story. If a test fails, copy the log output — it's
self-contained and readable without the source code.

### Happy Path — Insert with checkbox on

This is the primary scenario: a new Account is created with _Match Billing
Address_ checked. The trigger should overwrite the Shipping Postal Code with
the Billing Postal Code before the record hits the database.

The test deliberately sets Billing to `94105` and Shipping to `00000` — if they
started matching, you couldn't tell whether the trigger worked or they just
happened to be the same. After insert, the code re-queries the database (not
the in-memory reference) to prove the value was persisted.

**Expected log:** `PASS: ShippingPostalCode correctly set to 94105`.

```apex
// === idempotency guard ===
List<Account> leftovers = [SELECT Id FROM Account
                           WHERE Name = '[Test] Account Address Trigger - Insert'
                           WITH USER_MODE];
if (leftovers.size() > 0) {
    delete as user leftovers;
    System.debug('CLEANUP: deleted ' + leftovers.size() + ' leftover account(s)');
} else {
    System.debug('CLEANUP: no leftovers to delete');
}

// === arrange ===
System.debug('ARRANGE: creating account with BillingPostalCode=94105, ShippingPostalCode=00000, Match_Billing_Address__c=true');
Account acc = new Account(
    Name = '[Test] Account Address Trigger - Insert',
    BillingPostalCode = '94105',
    ShippingPostalCode = '00000',
    Match_Billing_Address__c = true
);
insert as user acc;
System.debug('ARRANGE: inserted account Id=' + acc.Id);

// === assert ===
System.debug('ASSERT: querying persisted record to verify trigger mutated ShippingPostalCode');
Account inserted = [SELECT BillingPostalCode, ShippingPostalCode
                    FROM Account WHERE Id = :acc.Id WITH USER_MODE];
System.debug('ASSERT: persisted BillingPostalCode=' + inserted.BillingPostalCode
    + ', ShippingPostalCode=' + inserted.ShippingPostalCode);
System.assertEquals('94105', inserted.ShippingPostalCode,
    'Shipping postal code should match billing after insert');
System.debug('PASS: ShippingPostalCode correctly set to ' + inserted.ShippingPostalCode);

// === self-deleting ===
System.debug('TEARDOWN: deleting account Id=' + acc.Id);
delete as user acc;
System.debug('TEARDOWN: account deleted');
```

### Update — Change billing postal code

This test proves the trigger fires on `before update`, not just `before
insert`. It creates an account the same way as the Happy Path, confirms the
trigger worked the first time, then changes BillingPostalCode from `94105` to
`60601` and updates the record.

If the trigger only worked on insert, the ShippingPostalCode would stay at
`94105` after the update. The assertion verifies it catches up to `60601`.

**Expected log:** `PASS: ShippingPostalCode correctly updated to 60601`.

```apex
// === idempotency guard ===
List<Account> leftovers = [SELECT Id FROM Account
                           WHERE Name = '[Test] Account Address Trigger - Update'
                           WITH USER_MODE];
if (leftovers.size() > 0) {
    delete as user leftovers;
    System.debug('CLEANUP: deleted ' + leftovers.size() + ' leftover account(s)');
} else {
    System.debug('CLEANUP: no leftovers to delete');
}

// === arrange ===
System.debug('ARRANGE: creating account with BillingPostalCode=94105, ShippingPostalCode=00000, Match_Billing_Address__c=true');
Account acc = new Account(
    Name = '[Test] Account Address Trigger - Update',
    BillingPostalCode = '94105',
    ShippingPostalCode = '00000',
    Match_Billing_Address__c = true
);
insert as user acc;
System.debug('ARRANGE: inserted account Id=' + acc.Id);

System.debug('ARRANGE: requery to confirm trigger set ShippingPostalCode to 94105');
Account afterInsert = [SELECT BillingPostalCode, ShippingPostalCode
                       FROM Account WHERE Id = :acc.Id WITH USER_MODE];
System.debug('ARRANGE: after insert — Billing=' + afterInsert.BillingPostalCode
    + ', Shipping=' + afterInsert.ShippingPostalCode);

// === act ===
System.debug('ACT: changing BillingPostalCode from 94105 to 60601');
acc.BillingPostalCode = '60601';
update as user acc;
System.debug('ACT: update committed');

// === assert ===
System.debug('ASSERT: requery to confirm trigger overwrote ShippingPostalCode on update');
Account updated = [SELECT BillingPostalCode, ShippingPostalCode
                   FROM Account WHERE Id = :acc.Id WITH USER_MODE];
System.debug('ASSERT: after update — Billing=' + updated.BillingPostalCode
    + ', Shipping=' + updated.ShippingPostalCode);
System.assertEquals('60601', updated.ShippingPostalCode,
    'Shipping postal code should reflect updated billing after update');
System.debug('PASS: ShippingPostalCode correctly updated to ' + updated.ShippingPostalCode);

// === self-deleting ===
System.debug('TEARDOWN: deleting account Id=' + acc.Id);
delete as user acc;
System.debug('TEARDOWN: account deleted');
```

### Negative Path — Checkbox off

This test proves the trigger's guard clause works: when _Match Billing Address_
is unchecked, the trigger must not touch the Shipping Postal Code at all.

The account is created with Billing `94105` and Shipping `90210`. If the
trigger were broken and ignored the checkbox, Shipping would be overwritten to
`94105`. The assertion uses `System.assertNotEquals` — it explicitly checks
that the two values stayed different.

**Expected log:** `PASS: ShippingPostalCode correctly untouched, remains 90210`.

```apex
// === idempotency guard ===
List<Account> leftovers = [SELECT Id FROM Account
                           WHERE Name = '[Test] Account Address Trigger - No Sync'
                           WITH USER_MODE];
if (leftovers.size() > 0) {
    delete as user leftovers;
    System.debug('CLEANUP: deleted ' + leftovers.size() + ' leftover account(s)');
} else {
    System.debug('CLEANUP: no leftovers to delete');
}

// === arrange ===
System.debug('ARRANGE: creating account with BillingPostalCode=94105, ShippingPostalCode=90210, Match_Billing_Address__c=false');
Account acc = new Account(
    Name = '[Test] Account Address Trigger - No Sync',
    BillingPostalCode = '94105',
    ShippingPostalCode = '90210',
    Match_Billing_Address__c = false
);
insert as user acc;
System.debug('ARRANGE: inserted account Id=' + acc.Id);

// === assert ===
System.debug('ASSERT: querying persisted record — ShippingPostalCode should still be 90210');
Account inserted = [SELECT BillingPostalCode, ShippingPostalCode
                    FROM Account WHERE Id = :acc.Id WITH USER_MODE];
System.debug('ASSERT: persisted BillingPostalCode=' + inserted.BillingPostalCode
    + ', ShippingPostalCode=' + inserted.ShippingPostalCode);
System.assertNotEquals('94105', inserted.ShippingPostalCode,
    'Shipping postal code should NOT change when checkbox is off');
System.debug('PASS: ShippingPostalCode correctly untouched, remains ' + inserted.ShippingPostalCode);

// === self-deleting ===
System.debug('TEARDOWN: deleting account Id=' + acc.Id);
delete as user acc;
System.debug('TEARDOWN: account deleted');
```

### Reading the log

After running a test, open the log and check **Debug Only**. The output reads
like a trace:

```
CLEANUP: no leftovers to delete
ARRANGE: creating account with BillingPostalCode=94105, ShippingPostalCode=00000, Match_Billing_Address__c=true
ARRANGE: inserted account Id=001XXXXXXXXXXXXXXX
ASSERT: querying persisted record to verify trigger mutated ShippingPostalCode
ASSERT: persisted BillingPostalCode=94105, ShippingPostalCode=94105
PASS: ShippingPostalCode correctly set to 94105
TEARDOWN: deleting account Id=001XXXXXXXXXXXXXXX
TEARDOWN: account deleted
```

Each phase is tagged (`CLEANUP` / `ARRANGE` / `ACT` / `ASSERT` / `TEARDOWN` /
`PASS`) so the log is self-documenting. Copy-paste the entire `USER_DEBUG`
section into an AI prompt — it's fully readable without the source code.

---

## What This Trigger Does and Does Not Do

| Scope | Behavior |
|---|---|
| Matches billing postal code to shipping | Only when `Match_Billing_Address__c == true` |
| Fires on insert | Yes — sets `ShippingPostalCode` before the record is committed |
| Fires on update | Yes — overwrites `ShippingPostalCode` with current `BillingPostalCode` |
| Cascades to child records | No — this trigger doesn't touch Contacts, Opportunities, etc. |
| Handles null billing postal code | Yes — `acc.ShippingPostalCode = acc.BillingPostalCode` where both are null is a no-op |
