# Unit 5 — ContactAndLeadSearch Class

Trailhead hands-on challenge. An SOSL-driven class that searches across both
Contact and Lead objects simultaneously.

---

## The Class

**File → New → Apex Class**, name it `ContactAndLeadSearch`.

```apex
// ContactAndLeadSearch: searches across two unrelated objects with a single
// SOSL query. SOSL is the only mechanism in Apex that can query multiple
// object types at once — SOQL is restricted to one object per query.
public class ContactAndLeadSearch {

    // Accepts a single search string. SOSL's IN NAME FIELDS scope searches
    // the Name, FirstName, and LastName fields of both Contact and Lead.
    // Returns a List of Lists: one inner list per object specified in RETURNING.
    public static List<List<sObject>> searchContactsAndLeads(String searchString) {

        // SOSL uses FIND ... IN ... RETURNING syntax. The colon (:searchString)
        // is a bind variable — same pattern as SOQL. IN NAME FIELDS tells SOSL
        // which fields to search (Name, FirstName, LastName on standard objects).
        // RETURNING lists the objects to return results for.
        List<List<sObject>> results = [
            FIND :searchString
            IN NAME FIELDS
            RETURNING Contact, Lead
        ];

        // The return type mirrors the RETURNING clause:
        //   results[0] → List<Contact> (matches from the Contact object)
        //   results[1] → List<Lead>    (matches from the Lead object)
        // Each inner list is empty if no matches were found on that object.
        return results;
    }
}
```

### What it does

| Step | Line | What happens |
|------|------|-------------|
| 1 | `searchContactsAndLeads('Smith')` | Caller provides a search string |
| 2 | `FIND :searchString IN NAME FIELDS RETURNING Contact, Lead` | SOSL searches both objects |
| 3 | `results[0]` | Contacts whose name matches — empty list if none |
| 4 | `results[1]` | Leads whose name matches — empty list if none |

### SOSL vs SOQL — why SOSL here

| Concern | SOQL | SOSL |
|---------|------|------|
| Objects per query | One | Multiple |
| Match type | Exact field criteria | Full-text across name fields |
| This challenge | Would need 2 separate queries | One query hits both |

---

## Test Payload

**Important:** SOSL relies on indexed search data. You must create test
records **before** running the test, then delete them after.

### Step 1 — Create test data

Run this Anonymous Apex first:

```apex
// Create a Contact and a Lead, both with last name Smith.
// The challenge validator checks for exactly these records.
Contact c = new Contact(LastName = 'Smith');
Lead l = new Lead(LastName = 'Smith', Company = 'Test Company');

insert new List<sObject>{ c, l };

System.debug('Test data created. Contact ID: ' + c.Id + ', Lead ID: ' + l.Id);
```

### Step 2 — Run the test

In a separate Anonymous Apex window:

```apex
// Search for 'Smith' across both objects.
List<List<sObject>> results = ContactAndLeadSearch.searchContactsAndLeads('Smith');

// Extract results for each object type.
List<Contact> contacts = (List<Contact>) results[0];
List<Lead> leads = (List<Lead>) results[1];

// Verify at least one Contact and one Lead were found.
System.assert(contacts.size() >= 1, 'Should find at least one Contact named Smith');
System.assert(leads.size() >= 1, 'Should find at least one Lead named Smith');

System.debug('Found ' + contacts.size() + ' Contact(s), ' + leads.size() + ' Lead(s).');
System.debug('All assertions passed.');
```

### Step 3 — Clean up

After the challenge passes:

```apex
// Find and delete the test records.
List<Contact> testContacts = [SELECT Id FROM Contact WHERE LastName = 'Smith'];
List<Lead> testLeads = [SELECT Id FROM Lead WHERE LastName = 'Smith'];

delete testLeads;
delete testContacts;

System.debug('Test data cleaned up.');
```
