# Unit 3 — AccountHandler Class

Trailhead hands-on challenge. A reusable DML class for creating Account records.

---

## The Class

**File → New → Apex Class**, name it `AccountHandler`.

```apex
// AccountHandler: provides a single static utility for creating Account records.
// Static methods belong to the class itself — callers use AccountHandler.methodName()
// without needing to instantiate the class with 'new AccountHandler()'.
public class AccountHandler {

    // Accepts a name string, returns the new Account if successful, null if not.
    // The method signature is the contract: callers know exactly what goes in and out.
    public static Account insertNewAccount(String accountName) {
        try {
            // sObject constructors use named-parameter syntax (fieldName = value).
            // At this point the Account exists only in memory — no ID yet.
            Account newAccount = new Account(Name = accountName);

            // DML statement: the record is now persisted to the org's database.
            // Salesforce auto-assigns an ID on successful insert.
            insert newAccount;

            // Return the now-persisted record (with its new ID) to the caller.
            return newAccount;

        } catch (DmlException e) {
            // DML operations can fail for reasons beyond the method's control:
            // validation rules, required-field violations, governor limits.
            // Returning null lets the caller decide how to handle failure.
            return null;
        }
    }
}
```

### What it does

| Step | Line | What happens |
|------|------|-------------|
| 1 | `Account newAccount = ...` | Creates an Account object in memory (not yet in the database) |
| 2 | `insert newAccount;` | DML — the account is written to the org's database and assigned an ID |
| 3 | `return newAccount;` | Returns the account (now with an ID) to whoever called the method |
| 4 | `catch (DmlException e)` | If the insert fails (e.g., empty name), returns `null` instead of crashing |

### How it's called

```apex
Account a = AccountHandler.insertNewAccount('Acme Inc.');
// a.Name = 'Acme Inc.', a.Id = '001xxxxxxxxxxxx'
```

---

## Test Payload

**Debug → Open Execute Anonymous Window** (Ctrl+E). Check **"Open Log"**, click **Execute**.

```apex
// Create an account using your class
Account acc = AccountHandler.insertNewAccount('Test Account');

// Verify it was created
System.debug('Created: ' + acc.Name + ' (ID: ' + acc.Id + ')');
System.assertNotEquals(null, acc, 'Should not be null');
System.assertNotEquals(null, acc.Id, 'Should have an ID assigned by the org');

// Clean up — delete it so you don't clutter the org
delete acc;
System.debug('Deleted. Test passed.');
```

Expected output:

```
USER_DEBUG | Created: Test Account (ID: 001xxxxxxxxxxxx)
USER_DEBUG | Deleted. Test passed.
```
