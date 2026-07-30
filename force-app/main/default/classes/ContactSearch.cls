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