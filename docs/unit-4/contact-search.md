# Unit 4 — ContactSearch Class

Trailhead hands-on challenge. A SOQL-driven class that searches for contacts
by last name and mailing postal code.

---

## The Class

**File → New → Apex Class**, name it `ContactSearch`.

```apex
// ContactSearch: provides a static utility for finding contacts by two criteria.
// The method accepts two filter values and delegates to SOQL — the read-only
// half of the data layer. No DML is performed.
public class ContactSearch {

    // Accepts a last name and a postal code. Returns a list of matching contacts
    // (ID and Name only), or an empty list if none match.
    // The method signature is the contract: String + String → List<Contact>.
    public static List<Contact> searchForContacts(String lastName, String postalCode) {

        // SOQL query embedded in square brackets. The colon syntax (:lastName)
        // binds an Apex variable into the query — this is called a bind variable.
        // It prevents SOQL injection and is the only safe way to inject values.
        List<Contact> results = [
            SELECT Id, Name
            FROM Contact
            WHERE LastName = :lastName AND MailingPostalCode = :postalCode
        ];

        // Return whatever SOQL found — a populated list, or an empty list.
        // No null check needed: SOQL queries never return null; they return
        // an empty list when no rows match.
        return results;
    }
}
```

### What it does

| Step | Line | What happens |
|------|------|-------------|
| 1 | `searchForContacts('Smith', '94105')` | Caller provides two filter values |
| 2 | `SELECT Id, Name FROM Contact WHERE ...` | SOQL searches the Contact table |
| 3 | `:lastName` / `:postalCode` | Bind variables inject the method parameters safely |
| 4 | `return results;` | Returns matching contacts (or empty list if none) |

### Why only ID and Name?

The challenge spec requires returning **only** ID and Name. Adding extra
fields like Email or Phone would fail the Trailhead check. SOQL always
selects exactly the fields you list — it has no `SELECT *`.

### Why bind variables?

```apex
// Good — bind variable, safe from injection
WHERE LastName = :lastName

// Bad — string concatenation, vulnerable to SOQL injection
WHERE LastName = \'' + lastName + '\''
```

Bind variables (`:variableName`) are the only correct way to pass values
into a SOQL query. They prevent injection and handle escaping automatically.

---

## Test Payload

**Debug → Open Execute Anonymous Window** (Ctrl+E). Check **"Open Log"**,
click **Execute**.

```apex
// Step 1: Create test data so we have something to search for.
// Two contacts with known last names and postal codes.
Contact c1 = new Contact(LastName = 'TestSearch', MailingPostalCode = '00001');
Contact c2 = new Contact(LastName = 'TestSearch', MailingPostalCode = '00002');
insert new List<Contact>{ c1, c2 };

// Step 2: Search for the first contact by both criteria.
List<Contact> found = ContactSearch.searchForContacts('TestSearch', '00001');

// Verify exactly one result was returned.
System.assertEquals(1, found.size(), 'Should find exactly 1 contact');
System.assertEquals('TestSearch', found[0].LastName, 'Last name should match');
System.assertNotEquals(null, found[0].Id, 'Should have an ID');

// Step 3: Search with a postal code that should return nothing.
List<Contact> none = ContactSearch.searchForContacts('TestSearch', '99999');
System.assertEquals(0, none.size(), 'Should return empty list, not null');

// Step 4: Clean up test data.
delete new List<Contact>{ c1, c2 };

System.debug('All assertions passed.');
```

Expected output:

```
USER_DEBUG | All assertions passed.
```
