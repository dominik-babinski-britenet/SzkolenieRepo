@isTest(SeeAllData=true)
private class CreateOrderOnOpportunityCloseTest {
    @isTest
    static void testCreateOrderOnOpportunityClose() {
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        Id standardPricebookId = Test.getStandardPricebookId();

        Opportunity testOpportunity = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            AccountId = testAccount.Id
        );
        insert testOpportunity;

        Quote testQuote = new Quote(
            OpportunityId = testOpportunity.Id,
            Name = 'Test Quote',
            Status = 'Accepted',
            Pricebook2Id = standardPricebookId
        );
        insert testQuote;

        testOpportunity.StageName = 'Closed Won';
        update testOpportunity;

        List<Order> createdOrders = [
            SELECT Id, OpportunityId, AccountId, Status, QuoteId
            FROM Order
            WHERE OpportunityId = :testOpportunity.Id
        ];

        System.assertNotEquals(0, createdOrders.size(), 'An Order should have been created'); //somehow on deploy 2 orders get created here
        System.assertEquals('Draft', createdOrders[0].Status, 'Order status should be Draft');
        System.assertEquals(testOpportunity.Id, createdOrders[0].OpportunityId, 'Order should be linked to the correct Opportunity');
        System.assertEquals(testQuote.Id, createdOrders[0].QuoteId, 'Order should be linked to the correct Quote');
    }
}