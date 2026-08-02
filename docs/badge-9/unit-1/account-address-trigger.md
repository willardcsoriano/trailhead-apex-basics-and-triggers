# Badge 9 Unit 1 — Account Address Trigger

## Challenge

Create an Apex trigger that sets an account's **Shipping Postal Code** to match
the **Billing Postal Code** when the _Match Billing Address_ checkbox is selected.

- **Trigger name:** `AccountAddressTrigger`
- **Object:** Account
- **Events:** `before insert`, `before update`
- **Condition:** `Match_Billing_Address__c == true`
- **Operation:** `ShippingPostalCode = BillingPostalCode`

---

## 1. Pre-Work — Custom Field

Add the checkbox via Setup or the CLI:

```bash
sf schema generate field -o Account -l 'Match Billing Address' -n Match_Billing_Address -t Checkbox -d false -o trailhead-playground
```

Alternatively, in Setup → Object Manager → Account → Fields & Relationships → New:

| Property | Value |
|---|---|
| Field Label | Match Billing Address |
| Field Name | `Match_Billing_Address` |
| Type | Checkbox |
| Default | Unchecked |

---

## 2. Trigger Code

Create `force-app/main/default/triggers/AccountAddressTrigger.trigger`:

```apex
trigger AccountAddressTrigger on Account(before insert, before update) {
    for (Account acc : Trigger.new) {
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

The `before` events let you mutate `Trigger.new` without issuing extra DML — the platform commits the changes as part of the original operation. This is the idiomatic pattern for field-sync triggers.

### Why `Trigger.new` and not a SOQL query

`Trigger.new` holds the records _as they are being processed_. No query needed.
The trigger fires in the same transaction that updates the records, so the
in-memory copy is what gets committed.

---

## 3. Deploy

```bash
sf project deploy start -d force-app/main/default/triggers -o trailhead-playground
```

Then retrieve to capture the deployed metadata:

```bash
mkdir -p docs/badge-9/unit-1
sf project retrieve start -m ApexTrigger:AccountAddressTrigger -o trailhead-playground --json \
  | jq --arg timestamp "$(date -u +'%Y-%m-%dT%H:%M:%SZ')" --arg branch "$(git branch --show-current)" \
  '{command: "sf project retrieve start -m ApexTrigger:AccountAddressTrigger", timestamp: $timestamp, branch: $branch, result: .}' \
  > docs/badge-9/unit-1/retrieval-log.json
```

---

## 4. Test — Happy Path (Anonymous Apex)

```apex
Account acc = new Account(
    Name = 'Test Address Sync',
    BillingPostalCode = '94105',
    ShippingPostalCode = '00000',
    Match_Billing_Address__c = true
);
insert as user acc;

// Re-query to confirm what was committed
Account inserted = [SELECT BillingPostalCode, ShippingPostalCode, Match_Billing_Address__c
                    FROM Account
                    WHERE Id = :acc.Id
                    WITH USER_MODE];
System.assertEquals('94105', inserted.ShippingPostalCode,
    'Shipping postal code should match billing after insert');
System.debug('PASS: ShippingPostalCode = ' + inserted.ShippingPostalCode);
```

## 5. Test — Update (Anonymous Apex)

```apex
Account acc = [SELECT Id, BillingPostalCode, ShippingPostalCode, Match_Billing_Address__c
               FROM Account
               WHERE Name = 'Test Address Sync'
               WITH USER_MODE
               LIMIT 1];
acc.BillingPostalCode = '60601';
acc.Match_Billing_Address__c = true;
update as user acc;

Account updated = [SELECT BillingPostalCode, ShippingPostalCode
                   FROM Account
                   WHERE Id = :acc.Id
                   WITH USER_MODE];
System.assertEquals('60601', updated.ShippingPostalCode,
    'Shipping postal code should reflect updated billing after update');
System.debug('PASS: ShippingPostalCode updated to ' + updated.ShippingPostalCode);
```

## 6. Test — Checkbox Off (Negative Path)

```apex
Account acc = new Account(
    Name = 'Test No Sync',
    BillingPostalCode = '94105',
    ShippingPostalCode = '90210',
    Match_Billing_Address__c = false
);
insert as user acc;

Account inserted = [SELECT BillingPostalCode, ShippingPostalCode
                    FROM Account
                    WHERE Id = :acc.Id
                    WITH USER_MODE];
System.assertNotEquals('94105', inserted.ShippingPostalCode,
    'Shipping postal code should NOT change when checkbox is off');
System.debug('PASS: ShippingPostalCode remains ' + inserted.ShippingPostalCode);
```

### Why `as user`

`WITH USER_MODE` enforces object permissions, field-level security, and sharing
rules — matching the declared `insert as user` statement, which runs the
operation in user mode rather than system mode. The trigger's own queries and
DML would also need `WITH USER_MODE` if they existed, but this trigger only
mutates `Trigger.new` — no query, no DML — so the trigger itself is
mode-agnostic.

---

## 7. Cleanup

```apex
List<Account> testAccounts = [SELECT Id FROM Account
                               WHERE Name IN ('Test Address Sync', 'Test No Sync')
                               WITH USER_MODE];
delete as user testAccounts;
System.debug('Cleaned up ' + testAccounts.size() + ' test accounts.');
```

---

## 8. What This Trigger Does and Does Not Do

| Scope | Behavior |
|---|---|
| Matches billing postal code to shipping | Only when `Match_Billing_Address__c == true` |
| Fires on insert | Yes — sets `ShippingPostalCode` before the record is committed |
| Fires on update | Yes — overwrites `ShippingPostalCode` with current `BillingPostalCode` |
| Cascades to child records | No — this trigger doesn't touch Contacts, Opportunities, etc. |
| Handles null billing postal code | Yes — `acc.ShippingPostalCode = acc.BillingPostalCode` where both are null is a no-op |
