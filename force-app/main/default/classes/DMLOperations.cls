
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
        myAccount.Name = 'SL Enterprises inc';
        myAccount.BillingCity = 'Norfolk';
        myAccount.BillingState = 'VA';
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
        Contact myContact = new Contact();
        // Set some fields on the Contact
        myContact.FirstName = 'SpongeBob';
        myContact.LastName = 'SquarePants';
        // Set the AccountId field to the given accountId
        myContact.AccountId = accountId;
        // Insert the Contact into the database
        insert myContact;
        // Return the Id of the newly created Contact
        return myContact.Id;
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
        Contact mySOQLContact = [SELECT Id FROM Contact WHERE Id = :contactId];
        // Update the Contact's last name
        mySOQLContact.LastName = newLastName;
        // Update the Contact in the database
        update mySOQLContact;
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
        Opportunity myOpp = [SELECT Id FROM Opportunity WHERE Id = :oppId];
        // [SELECT Id FROM Opportunity WHERE Id = :oppId]
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
        Account myAccount = [SELECT Id FROM Account WHERE Id = :accountId];
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
        // Loop through each Opportunity in the list
        for (Opportunity opp : opportunities) {
            opp.StageName = 'Qualification';
            opp.CloseDate = Date.today().addMonths(3);
            opp.Amount = 50000;
        }
            // Set the Opportunity's Stage to Qualification
            // Set the Opportunity's Close Date to 3 months from today
            // Set the Opportunity's Amount to 50000
        // Upsert the opportunities List so that records are either updated or created
        upsert opportunities;
    }

    /**
     * Question 8
     * Insert or updates opportunities from list of names.
     * Associate the Opportunities with account that has the name accountName.
     * There should be an Opportunity for each name provided in the list.
     * HINT: The account may or may not exists in the database but is required for opportunity creation. Consider how upsert operation can help with this.
     * @param accountName The name of the Account.
     * @param oppNames The list of Opportunity names.
     */
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
        List<Opportunity> existingOpps = [SELECT Id, Name FROM Opportunity WHERE Name IN :oppNames AND AccountId = :accProvided.Id];
        for (Opportunity opp : existingOpps) {
            exOppos.put(opp.Name, opp);
        }
    
        // Create a list to hold Opportunities to upsert
        List<Opportunity> oppsToUpsert = new List<Opportunity>();
    
        // Process each Opportunity name
        for (String oppName : oppNames) {
            Opportunity opp;
            if (exOppos.containsKey(oppName)) {
                // If the Opportunity exists, use it
                opp = exOppos.get(oppName);
            } else {
                // If the Opportunity doesn't exist, create a new one
                opp = new Opportunity(
                    Name = oppName,
                    AccountId = accProvided.Id,
                    StageName = 'Prospecting',  // Set a default stage
                    CloseDate = Date.today().addDays(30)  // Set a default close date
                );
            }
            oppsToUpsert.add(opp);
        }
    
        // Perform the upsert operation
        upsert oppsToUpsert;
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
		List<Account> accounts = [SELECT Id, Name, Description FROM Account WHERE Name = :accountName];
        Account acc; //declare Account object
        if(accounts.isEmpty()){
            acc = new Account(Name = accountName, Description = 'New Account');
        } //if the Account list is empty, initialize the Account object
        else {
            acc = accounts[0];
            acc.Description = 'Updated Account';
        } //if not, set the account to the one found with the query and update the description
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
        List<String> lastNames = new List<String>(); //create a list to store the last names
        for(Contact con : contactsToUpsert){
            lastNames.add(con.LastName); //loop through the contacts provided and put the last names in the list
        }

        List<Account> existingAccounts = [SELECT Id, Name FROM Account WHERE Name IN :lastNames]; //list of existing Accounts that match our last names
        
        Map<String, Id> accountNameToId = new Map<String, Id>(); //create a map of account names and Ids
        for(Account a : existingAccounts) {
            accountNameToId.put(a.Name, a.Id); 
        }

        List<Account> newAccounts = new List<Account>(); //create new accounts for missing last names
        for(String lastName : lastNames) {
            if(!accountNameToId.containsKey(lastName)) {
            newAccounts.add(new Account(Name = lastName));
            }
        }

        insert newAccounts;
        for(Account a : newAccounts) {
            accountNameToId.put(a.Name, a.Id);
        }
    
        for(Contact c : contactsToUpsert) { // Link the Contact to its Account using the Account Id
            c.AccountId = accountNameToId.get(c.LastName);
        }
    
        upsert contactsToUpsert; // Upsert the Contacts
    }
    /**
     * Question 11
     * Insert a list of Leads and then deletes them.
     * @param leadNames The list of Lead names to be inserted.
     */
    public static void insertAndDeleteLeads(List<String> leadNames) {
        List<Lead> myLeads = new List<Lead>();
        // Loop through each Lead name
        for(String leadName : leadNames){
            Lead newLead = new Lead(
                LastName = leadName, 
                Company = 'Oy and Chroma and Milli Beagles Inc' //Company is a required field, now my dogs exist in my code!
            ); 
            myLeads.add(newLead);
        }
        // Insert the Leads
        if (!myLeads.isEmpty()) { //this checks if the list of leads is not empty, if it returns false, insert them
            insert myLeads;
            System.debug('Inserted ' + myLeads.size() + ' leads.');
        }
        // Delete the Leads
        if (!myLeads.isEmpty()) { //again, checks if the list of leads is not empty, if it returns false, delete them
            delete myLeads;
            System.debug('Deleted ' + myLeads.size() + ' leads.');
        }
    }

    /**
     * Question 12
     * Dynamically create the number of cases and relate it to the accountId, then deletes them.
     * @param accountId The account for which the cases will be created and then deleted.
     * @param numOfCases The number of cases to create.
     */
    public static void createAndDeleteCases(String accountId, Integer numOfCases) {
        // Insert the cases
        List<Case> casesToInsert = new List<Case>();
        Case myCase = new Case();
        for(Integer i = 0; i < numOfCases ; i++){
            myCase.AccountId = accountId;
        }
        insert casesToInsert;
        // Delete the cases
        delete casesToInsert;

    }
}
