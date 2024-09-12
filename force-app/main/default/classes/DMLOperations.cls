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
 * @author Simon Lapointe
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
        Account myAccount = new Account();
        // Set some fields on the Account
        myAccount.name = 'ST Enterprise';
        // Insert the Account into the database
        insert myAccount;
        // Return the Id of the newly created Account
        return myAccount.Id;
    }

    /**
     * Question 2
     * Create a new Account with the specified name and industry provided.
     * @param name The name of the account to be created.
     * @param industry The industry of the account to be created.
     */
    public static void createAccount(String name, String industry) {
        // Create a new Account and set the fields inline
        Account myOtherAccount = new Account(Name = name, Industry = industry);
        // Insert the Account
        insert myOtherAccount;
    }

    
    /**
     * Question 3
     * Create a new Contact and link it to the Account id provided then inserts it into the database.
     * @param accountId The Id of the Account to link the Contact to.
     * @return The Id of the newly created Contact.
     */
     public static Id insertNewContact(Id accountId) {
        // Create a new Contact instance
        Contact newContact = new Contact(AccountId = accountId);
        // Set some fields on the Contact
        newContact.LastName = 'Zappa';
        newContact.FirstName = 'Frank';
        // Set the AccountId field to the given accountId
        //SL: AccountId set above on line 65
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
        // [SELECT Id FROM Contact WHERE Id = :contactId]
        Contact retrievedContact = [SELECT Id, LastName FROM Contact WHERE Id = :contactId];
        // Update the Contact's last name
        retrievedContact.LastName = newLastName;
        // Update the Contact in the database
        update retrievedContact;
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
        // [SELECT Id FROM Opportunity WHERE Id = :oppId]
        Opportunity myOpp = [SELECT Id, StageName FROM Opportunity WHERE Id = :oppId];
        // Update the Opportunity's stage
        myOpp.StageName = newStage;
        // Update the Opportunity in the database
        update myOpp;
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
        // Query the account
        // [SELECT Id FROM Account WHERE Id = :accountId]
        Account myAccount = [SELECT Id, Name, Industry FROM Account WHERE Id = :accountId];
        // Update the Account with the given Id with the new name and industry
        myAccount.Name = newName;
        myAccount.Industry = newIndustry;
        update myAccount;
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
        String newStage = 'Qualification';
        Date newDate = Date.today().addMonths(3);
        Decimal newAmount = 50000;
        // Loop through each Opportunity in the list
            // Set the Opportunity's Stage to Qualification
            // Set the Opportunity's Close Date to 3 months from today
            // Set the Opportunity's Amount to 50000
        for (Opportunity opp : opportunities){
            opp.StageName = newStage;
            opp.CloseDate = newDate;
            opp.Amount = newAmount;
        }
        // Upsert the opportunities List so that records are either updated or created
        upsert opportunities;
    }

    public static void upsertOpportunities(String accountName, List<String> oppNames) {
        // Query for the account
        List<Account> accList = [SELECT Id, Name FROM Account WHERE Name = :accountName LIMIT 1];
        Account accProvided;
        
        if (accList.isEmpty()) {
            // No account found, so create a new one
            accProvided = new Account(Name = accountName);
            insert accProvided;
        } else {
            // Use the existing account
            accProvided = accList[0];
        }
    
        // Initialize the map to store existing Opportunities
        Map<String, Opportunity> exOppos = new Map<String, Opportunity>();
    
        // Query for existing Opportunities with the provided names
        List<Opportunity> existingOpps = [SELECT Id, Name FROM Opportunity WHERE Name IN :oppNames];
        for (Opportunity opp : existingOpps) {
            exOppos.put(opp.Name, opp);
        }
    
        // Loop through the provided Opportunity names
        for (String oppName : oppNames) {
            if (exOppos.containsKey(oppName)) {
                // Update the existing Opportunity
                Opportunity existingOpp = exOppos.get(oppName);
                existingOpp.AccountId = accProvided.Id;
                existingOpp.StageName = 'Qualification';
                existingOpp.CloseDate = Date.today().addMonths(3);
            } else {
                // Create a new Opportunity
                Opportunity newOpp = new Opportunity(
                    Name = oppName, 
                    AccountId = accProvided.Id,
                    StageName = 'Qualification',
                    CloseDate = Date.today().addMonths(3)
                );
                exOppos.put(oppName, newOpp);
            }
        }
    
        // Upsert the Opportunities
        upsert exOppos.values();
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
		// Query for the Account
		List<Account> accounts = [SELECT Id, Name FROM Account WHERE Name = :accountName];
        if(accounts.isEmpty()){
            System.debug('Account not found');
            Account acc = new Account(Name = accountName, Description = 'New Account');
        }
        else{
            acc = accounts[0];
            acc.Description = 'Updated Account';
        }
        upsert acc;
        return acc;
	}

    /**
     * Question 10
	 * Manage the association between Contacts and Accounts
	 * Ensure that for each Contact in the provided list, there is a corresponding Account Name that matches the Contact's last name.
	 * If such an Account does not exist, the method creates it; if it does, the method ensures the Contact is associated with it. (Hint: use previous upsertAccount method - this may cause bad practices but for learning purposes it's okay.)
     * Example Contact.LastName = 'Doe' Link to Account.Name = 'Doe' 
     * Example Contact.LastName = 'Jane' Link to Account.Name = 'Jane'
	 * @param contactsToUpsert List of Contacts to be upserted and linked to accounts.
	 */
	public static void upsertAccountsWithContacts(List<Contact> contactsToUpsert) {
		// Loop through each Contact

		// Extract the Account Name from Contact's LastName

		// Get the account based on the name or create one if it doesn't exist

		// Link the Contact to its Account using the Account Id

		// Upsert the Contacts
	}

    /**
     * Question 11
     * Insert a list of Leads and then deletes them.
     * @param leadNames The list of Lead names to be inserted.
     */
    public static void insertAndDeleteLeads(List<String> leadNames) {
        // Loop through each Lead name

        // Insert the Leads

        // Delete the Leads
    }


    /**
     * Question 12
     * Dynamically create the number of cases and relate it to the accountId, then deletes them.
     * @param accountId The account for which the cases will be created and then deleted.
     * @param numOfCases The number of cases to create.
     */
    public static void createAndDeleteCases(String accountId, Integer numOfCases) {
        // Insert the cases

        // Delete the cases
    }
}