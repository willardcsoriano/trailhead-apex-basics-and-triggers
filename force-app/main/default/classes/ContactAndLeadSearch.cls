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