@IsTest
private class OrderItemTriggerHandlerTest {
    @IsTest
    static void testAfterInsertAndUpdate() {
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        Id standardPricebookId = Test.getStandardPricebookId();

        Order testOrder = new Order(
            AccountId = testAccount.Id,
            Status = 'Draft',
            EffectiveDate = Date.today(),
            Pricebook2Id = standardPricebookId
        );
        insert testOrder;

        Product2 testProduct = new Product2(Name = 'Test Product', IsActive = true);
        insert testProduct;

        PricebookEntry testPricebookEntry = new PricebookEntry(
            Pricebook2Id = standardPricebookId,
            Product2Id = testProduct.Id,
            UnitPrice = 100,
            IsActive = true
        );
        insert testPricebookEntry;

        OrderItem testOrderItem = new OrderItem(
            OrderId = testOrder.Id,
            Quantity = 2,
            PricebookEntryId = testPricebookEntry.Id,
            UnitPrice = 100
        );

        insert testOrderItem;

        List<Account> updateddAccounts = [
            SELECT Id, Total_Money_Spent__c, Orders_Placed__c, BooksSold__c
            FROM Account
            WHERE Id = :testAccount.Id
        ];

        System.assertEquals(2, updateddAccounts[0].BooksSold__c);

        testOrderItem.Quantity = 3;
        update testOrderItem;

        List<Account> updatedAccounts = [
            SELECT Id, Total_Money_Spent__c, Orders_Placed__c, BooksSold__c
            FROM Account
            WHERE Id = :testAccount.Id
        ];

        System.assertEquals(1, updatedAccounts.size());
        System.assertEquals(300, updatedAccounts[0].Total_Money_Spent__c);
        System.assertEquals(1, updatedAccounts[0].Orders_Placed__c);
        System.assertEquals(3, updatedAccounts[0].BooksSold__c);
    }
}