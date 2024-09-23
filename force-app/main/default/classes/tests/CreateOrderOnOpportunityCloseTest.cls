@isTest(SeeAllData=true)
public class CreateOrderOnOpportunityCloseTest {
    @isTest
    static void testCreateOrderOnOpportunityClose() {
        // Step 1: Create a test Account
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        // Step 2: Query the standard pricebook
        Id standardPricebookId = Test.getStandardPricebookId();

        // Step 3: Create a test Opportunity
        Opportunity testOpportunity = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            AccountId = testAccount.Id
        );
        insert testOpportunity;

        // Step 4: Create a test Quote and associate it with the Opportunity
        Quote testQuote = new Quote(
            OpportunityId = testOpportunity.Id,
            Name = 'Test Quote',
            Status = 'Accepted',
            Pricebook2Id = standardPricebookId
        );
        insert testQuote;

        // Step 5: Update the Opportunity to Closed Won (to trigger the logic)
        testOpportunity.StageName = 'Closed Won';
        update testOpportunity;

        // Step 6: Retrieve Orders created by the trigger
        List<Order> createdOrders = [
            SELECT Id, OpportunityId, AccountId, Status, QuoteId
            FROM Order
            WHERE OpportunityId = :testOpportunity.Id
        ];

        // Validate that the Order was created
        System.assertEquals(1, createdOrders.size(), 'An Order should have been created');
        System.assertEquals('Draft', createdOrders[0].Status, 'Order status should be Draft');
        System.assertEquals(testOpportunity.Id, createdOrders[0].OpportunityId, 'Order should be linked to the correct Opportunity');
        System.assertEquals(testQuote.Id, createdOrders[0].QuoteId, 'Order should be linked to the correct Quote');
    }
}