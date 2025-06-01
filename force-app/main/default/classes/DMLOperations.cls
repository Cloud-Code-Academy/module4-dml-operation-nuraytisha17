/**
 * The DMLOperations class serves as a deep dive into Data Manipulation Language (DML) in Apex.
 * It covers fundamental DML operations such as insert, update, upsert, and delete.
 *
 * This class introduces developers to the concept of manipulating Salesforce records in Apex.
 * It discusses how to use DML operations to create, update, and delete records.
 * This class uses standard Salesforce objects like Account, Contact, and Opportunity for demonstration.
 *
 * Topics covered in this class include:
 * - Understanding how to use insert DML operation to create records in Salesforce.
 * - Understanding how to use update and upsert DML operations to update existing records in Salesforce.
 * - Understanding how to use delete DML operation to remove records from Salesforce.
 *
 * Users of this class can expect to gain a strong understanding of DML operations in Apex and
 * be prepared for more advanced topics in Salesforce development.
 *
 * The methods within this class serve as practical examples of different DML operations,
 * allowing developers to learn through practice and examples.
 *
 * @author Nuray Tisha
 */


public with sharing class DMLOperations {

    /**
     * Question 1
     * Create a new Account object and inserts it into the database.
     * The Account will have a random name for uniqueness.
     * @return The Id of the newly created Account.
     */
    public static Id insertNewAccount() {
        // Create a new Account instance
        // Set some fields on the Account
        Account acct = new Account(Name = 'Nuray Account', Industry = 'Technology', Website = 'www.test.com');

        // Insert the Account into the database
        insert acct;

        // Return the Id of the newly created Account
        return acct.Id;
    }

    /**
     * Question 2
     * Create a new Account with the specified name and industry provided.
     * @param name The name of the account to be created.
     * @param industry The industry of the account to be created.
     */
    public static void createAccount(String name, String industry) {
        // Create a new Account and set the fields
        Account acct = new Account(Name = name, Industry = industry);

        // Insert the Account
        insert acct;
    }

    
    /**
     * Question 3
     * Create a new Contact and link it to the Account id provided then inserts it into the database.
     * @param accountId The Id of the Account to link the Contact to.
     * @return The Id of the newly created Contact.
     */
    public static Id insertNewContact(Id accountId) {
        // Create a new Contact instance
        Contact newContact = new Contact(LastName = 'new1', Phone = '4159990007878');

        // Set some fields on the Contact
        // Set the AccountId field to the given accountId
        newContact.AccountId = accountId;

        // Insert the Contact into the database
        insert newContact;

        // Return the Id of the newly created Contact
        return newContact.Id;
    }

    /**
     * Question 4
     * Update the last name of a Contact in the database.
     * Resource: https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql.htm
     * @param contactId The Id of the Contact to update.
     * @param newLastName The new last name for the Contact.
     */
    public static void updateContactLastName(Id contactId, String newLastName) {
        // Retrieve the Contact from the database
        Contact testContact = [SELECT Id FROM Contact WHERE Id = :contactId];

        // Update the Contact's last name
        testContact.LastName = newLastName;

        // Update the Contact in the database
        update testContact;
    }

    /**
     * Question 5
     * Update the stage of an Opportunity in the database.
     * Resource: https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql.htm
     * @param oppId The Id of the Opportunity to update.
     * @param newStage The new stage for the Opportunity.
     */
    public static void updateOpportunityStage(Id oppId, String newStage) {
        // Retrieve the Opportunity from the database
        Opportunity oppty = [SELECT Id FROM Opportunity WHERE Id = :oppId];

        // Update the Opportunity's stage
        oppty.StageName = newStage;

        // Update the Opportunity in the database
        update oppty;
        
    }

    /**
     * Question 6
     * Update the Account's Name and Industry given an Account Id.
     * Resource: https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql.htm
     * @param accountId The Id of the account to be updated.
     * @param newName The new name for the account.
     * @param newIndustry The new industry for the account.
     */
    public static void updateAccountFields(Id accountId, String newName, String newIndustry) {
        // Retrieve the Account from the database
        Account acct = [SELECT Id FROM Account WHERE Id = :accountId];

        // Update the fields on Account record
        acct.Name = newName;
        acct.Industry = newIndustry;

        // Update the Account with the given Id with the new name and industry
        update acct;
    }


    /**
     * Question 7
     * Create or updates an Opportunities
     * The Opportunity's Stage is set to Qualification.
     * The Opportunity's Close Date is set to 3 months from today.
     * The Opportunity's Amount is set to 50000.
     * @param list of Opportunities to be changed then upserted.
     */
    public static void upsertOpportunityList(List<Opportunity> opportunities) {
        // Loop through each Opportunity in the list
        // Set the Opportunity's Stage, Close Date, and Amount
        for (Opportunity oppty : opportunities) {
            oppty.StageName = 'Qualification';
            oppty.CloseDate = Date.today().addMonths(3);
            oppty.Amount = 50000;
        }

        // Upsert the opportunities List to either insert or update records using Database namespace
        Database.upsert(opportunities, false);
    }

    /**
     * Question 8
     * Insert or update opportunities from list of names.
     * Associate the Opportunities with account that has the name accountName.
     * There should be an Opportunity for each name provided in the list.
     * HINT: The account may or may not exists in the database but is required for opportunity creation. Consider how upsert operation can help with this.
     * HINT: There should not be duplicate opportunites based on the name
     * @param accountName The name of the Account.
     * @param oppNames The list of Opportunity names.
     */
    public static void upsertOpportunities(String accountName, List<String> oppNames) {
        // Converting oppNames to a Set for no duplicate opportunities
        Set<String> oppNamesSet = new Set<String>(oppNames);
    
        // Query for the Account with the given name
        List<Account> accounts = [SELECT Id
                                   FROM Account 
                                   WHERE Name = :accountName 
                                   ORDER BY CreatedDate ASC
                                   LIMIT 1];
    
        // If no account exists, create a new one
        if (accounts.isEmpty()) {
            accounts.add(new Account(Name = accountName));
        }
    
        // Upsert the account
        Database.upsert(accounts);
    
        // Map to store existing Opportunities by name
        Map<String, Opportunity> opptyToNames = new Map<String, Opportunity>();
    
        // Loop through for existing Opportunities with the given names and account
        for (Opportunity oppty : [SELECT Id, Name 
                                   FROM Opportunity
                                   WHERE Name IN :oppNamesSet 
                                   AND AccountId IN :accounts]) {
            opptyToNames.put(oppty.Name, oppty);
        }
    
        // List to store Opportunities to upsert
        List<Opportunity> oppsToUpsert = new List<Opportunity>();
    
        // Loop through each Opportunity name
        // If found, update existing Opportunity
        // Else create new Opportunity
        for (String name : oppNames) {
            Opportunity opp;
    
            if (opptyToNames.containsKey(name)) {
                opp = opptyToNames.get(name);
            } else {
                opp = new Opportunity(Name = name);
            }
            opp.StageName = 'Qualification';
            opp.CloseDate = Date.today().addMonths(3);
            opp.Amount = 50000;

            opp.AccountId = accounts[0].Id;
    
            oppsToUpsert.add(opp);
        }
    
        // Upsert the Opportunities
        Database.upsert(oppsToUpsert);
    }
    
    /**
     * Question 9
	 * Upserts an Account with the specified name.
	 * If an Account with the given name already exists, update the description to "Updated Account".
	 * If no such Account exists, it creates a new one and sets the description to "New Account".
	 * @param accountName The name of the Account to be upserted.
	 * @return The Account that was upserted.
	 */
	public static Account upsertAccount(String accountName) {

		// Query for retrieving existing account in a list
		List<Account> accounts = [  SELECT Id 
                                    FROM Account 
                                    WHERE Name = :accountName
                                    ORDER BY CreatedDate ASC
                                    LIMIT 1];

		// if the Account exists, update the description
        // Else create a new Account and set the description
        if (accounts.size() > 0) {
            accounts.get(0).Description = 'Updated Account';
        } else {
            accounts.add(new Account(Name = accountName, Description = 'New Account'));
        }
		// Upsert the Account
        Database.upsert(accounts);
		return accounts.get(0);
	}

    /**
     * Question 10
     * Manage the association between Contacts and Accounts.
     * Ensure that for each Contact in the provided list, there is a corresponding Account Name that matches the Contact's LastName.
     * If such an Account does not exist, the method creates it; if it does, the method ensures the Contact is associated with it. (Hint: use previous upsertAccount method - this may cause bad practices but for learning purposes it's okay.)
     * Example Contact.LastName = 'Doe' Link to Account.Name = 'Doe' 
     * Example Contact.LastName = 'Jane' Link to Account.Name = 'Jane'
     * 
     * Edge Cases:
     * - Duplicate Account Names: The method ensures no duplicate accounts are created by checking existing accounts before creating new ones.
     * - Duplicate LastName Values: Duplicate LastName values in the contactsToUpsert list are processed once, ensuring no duplicate accounts are created for the same LastName.
     * - Null LastName: Contacts with null LastName are skipped as they cannot be associated with an Account.
     * - Large Data Volume: The method handles bulk operations efficiently using maps and lists.
     * 
     * @param contactsToUpsert List of Contacts to be upserted and linked to accounts.
	 */
	public static void upsertAccountsWithContacts(List<Contact> contactsToUpsert) {
            // Map to store accounts by LastName
            Map<String, Account> accountsToMap = new Map<String, Account>();
            Set<String> lastNames = new Set<String>();
        
            // Collect LastNames from contacts
            for (Contact contact : contactsToUpsert) {
                if (contact.LastName != null) {
                    lastNames.add(contact.LastName);
                }
            }
        
            // Query existing accounts with matching LastNames
            for (Account acc : [SELECT Id, Name FROM Account WHERE Name IN :lastNames]) {
                accountsToMap.put(acc.Name, acc);
            }
        
            // List to store new accounts to upsert
            List<Account> accountsToUpsert = new List<Account>();
        
            // Create new accounts for LastNames not in the map
            for (String lastName : lastNames) {
                if (!accountsToMap.containsKey(lastName)) {
                    accountsToUpsert.add(new Account(Name = lastName));
                }
            }
        
            // Upsert new accounts
            if (!accountsToUpsert.isEmpty()) {
                Database.upsert(accountsToUpsert);
        
                // Refresh the accounts map with upserted accounts
                for (Account acc : accountsToUpsert) {
                    accountsToMap.put(acc.Name, acc);
                }
            }
        
            // List to store contacts to upsert
            List<Contact> contactsToUpsertFinal = new List<Contact>();
        
            // Associate contacts with accounts
            for (Contact contact : contactsToUpsert) {
                if (contact.LastName != null && accountsToMap.containsKey(contact.LastName)) {
                    contact.AccountId = accountsToMap.get(contact.LastName).Id;
                    contactsToUpsertFinal.add(contact);
                }
            }
        
            // Upsert contacts
            if (!contactsToUpsertFinal.isEmpty()) {
                Database.upsert(contactsToUpsertFinal);
            }
        }


    /**
     * Question 11
     * Insert a list of Leads and then deletes them.
     * @param leadNames The list of Lead names to be inserted.
     */
    public static void insertAndDeleteLeads(List<String> leadNames) {
        //Store the list of Leads to insert
        List<Lead> leads = new List<Lead>();

        // Loop through each Lead name
        for (String name : leadNames) {
            leads.add(new Lead(LastName = name, Company = 'Test Company'));
        }
        if (leadNames.size() > Limits.getLimitDmlRows()) {
            throw new LimitException('Too many leads to insert.');
        }

        // Insert the Leads
        insert leads;

        // Delete the Leads
        delete leads;
    }


    /**
     * Question 12
     * Dynamically create the number of cases and relate it to the accountId, then deletes them.
     * @param accountId The account for which the cases will be created and then deleted.
     * @param numOfCases The number of cases to create.
     */
    public static void createAndDeleteCases(String accountId, Integer numOfCases) {

        //List to store Cases
        List<Case> cases = new List<Case>();

        //Loop through number of cases
        for (integer i = 0; i < numOfCases; i++) {
            Case c = new Case(AccountId = accountId, Subject = 'Test Case ' + i);
            cases.add(c);
        }
        if (numOfCases > Limits.getLimitDmlRows()) {
            throw new LimitException('Too many cases to insert.');
        }
        // Insert the cases
        insert cases;

        // Delete the cases
        delete cases;
    }
}
