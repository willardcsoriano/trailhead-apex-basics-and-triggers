# Unit 3 — AccountHandler Class

Trailhead hands-on challenge. A reusable DML class for creating Account records.

---

## The Class

**File → New → Apex Class**, name it `AccountHandler`.

```apex
public class AccountHandler {
    public static Account insertNewAccount(String accountName) {
        try {
            // Instantiate a new Account object and assign the name
            Account newAccount = new Account(Name = accountName);

            // Perform the DML insert operation
            insert newAccount;

            // Return the account record if successful
            return newAccount;
        } catch (DmlException e) {
            // Catch DML exception (e.g., when passing an empty string) and return null
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
