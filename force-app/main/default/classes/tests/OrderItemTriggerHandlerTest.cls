@isTest
public class OrderItemTriggerHandlerTest {
    @testSetup
    static void setupTestData() {
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        Id standardPricebook = Test.getStandardPricebookId();
        Product2 testProduct = new Product2(Name = 'Test Product', IsActive = true);
        insert testProduct;

        PricebookEntry pricebookEntry = new PricebookEntry(
            Pricebook2Id = standardPricebook,
            Product2Id = testProduct.Id,
            UnitPrice = 100,
            IsActive = true
        );
        insert pricebookEntry;

        Order testOrder1 = new Order(
            AccountId = testAccount.Id,
            Status = 'Draft',
            EffectiveDate = Date.today(),
            Pricebook2Id = standardPricebook
        );
        Order testOrder2 = new Order(
            AccountId = testAccount.Id,
            Status = 'Draft',
            EffectiveDate = Date.today(),
            Pricebook2Id = standardPricebook
        );
        insert new List<Order>{ testOrder1, testOrder2 };

        OrderItem testOrderItem1 = new OrderItem(
            OrderId = testOrder1.Id,
            Quantity = 2,
            UnitPrice = 50.0,
            PricebookEntryId = pricebookEntry.Id
        );
        OrderItem testOrderItem2 = new OrderItem(
            OrderId = testOrder2.Id,
            Quantity = 5,
            UnitPrice = 20.0,
            PricebookEntryId = pricebookEntry.Id
        );
        insert new List<OrderItem>{ testOrderItem1, testOrderItem2 };

        Discount__c discount = new Discount__c(
            Name = 'Test Discount',
            Discount_Requirement__c = 'MoneySpentDiscountRequirements',
            DiscountValue__c = 5.0,
            Discount_Requirement_Value__c = 100.0,
            IsActive__c = true
        );
        insert discount;
    }
}