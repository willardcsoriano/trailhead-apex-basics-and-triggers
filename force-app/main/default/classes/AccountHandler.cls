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