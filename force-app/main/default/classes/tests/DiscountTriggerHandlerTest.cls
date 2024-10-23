@isTest
public class DiscountTriggerHandlerTest {
    @testSetup
    static void setupTestData() {
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        Id standardPricebook = Test.getStandardPricebookId();
        Order testOrder = new Order(
            AccountId = testAccount.Id,
            Status = 'Draft',
            EffectiveDate = Date.today(),
            Pricebook2Id = standardPricebook
        );
        insert testOrder;

        Product2 testProduct = new Product2(Name = 'Test Product', IsActive = true);
        insert testProduct;

        PricebookEntry pricebookEntry = new PricebookEntry(
            Pricebook2Id = standardPricebook,
            Product2Id = testProduct.Id,
            UnitPrice = 100,
            IsActive = true
        );
        insert pricebookEntry;

        OrderItem testOrderItem = new OrderItem(
            OrderId = testOrder.Id,
            Quantity = 3,
            UnitPrice = 100.0,
            PricebookEntryId = pricebookEntry.Id
        );
        insert testOrderItem;
    }

    @isTest
    static void testAfterInsert() {
        Discount__c discount = new Discount__c(
            Name = 'Test Discount',
            Discount_Requirement__c = 'MoneySpentDiscountRequirements',
            DiscountValue__c = 5.0,
            Discount_Requirement_Value__c = 100.0,
            IsActive__c = true
        );

        Test.startTest();
        insert discount;
        Test.stopTest();

        List<AccountDiscount__c> accountDiscounts = [SELECT Id, Account__c, Discount__c FROM AccountDiscount__c];

        System.assert(!accountDiscounts.isEmpty(), 'Account discounts should be added after insert.');
        System.assertEquals(1, accountDiscounts.size(), 'One discount should have been applied.');
    }

    @isTest
    static void testAfterUpdate() {
        Discount__c discount = new Discount__c(
            Name = 'Test Discount',
            Discount_Requirement__c = 'MoneySpentDiscountRequirements',
            DiscountValue__c = 5.0,
            Discount_Requirement_Value__c = 100.0,
            IsActive__c = true
        );
        insert discount;

        Test.startTest();
        discount.IsActive__c = false;
        update discount;
        Test.stopTest();

        List<AccountDiscount__c> accountDiscounts = [SELECT Id, Account__c, Discount__c FROM AccountDiscount__c];

        System.assert(accountDiscounts.isEmpty(), 'Account discounts should be removed after deactivating the discount.');
    }

    @isTest
    static void testAfterDelete() {
        Discount__c discount = new Discount__c(
            Name = 'Test Discount',
            Discount_Requirement__c = 'MoneySpentDiscountRequirements',
            DiscountValue__c = 5.0,
            Discount_Requirement_Value__c = 100.0,
            IsActive__c = true
        );
        insert discount;

        Test.startTest();
        delete discount;
        Test.stopTest();

        List<AccountDiscount__c> accountDiscounts = [SELECT Id, Account__c, Discount__c FROM AccountDiscount__c];

        System.assert(accountDiscounts.isEmpty(), 'Account discounts should be removed after the discount is deleted.');
    }
}