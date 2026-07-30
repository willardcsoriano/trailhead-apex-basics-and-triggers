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