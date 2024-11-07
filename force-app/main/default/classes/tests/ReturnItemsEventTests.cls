@isTest
private class ReturnItemsEventTests {
    @TestSetup
    static void createTestData() {
        new DataGenerator().createData();
    }

    @isTest
    static void testExternalCaseGettingCreated() {
        Test.startTest();
        External_case_items__e event = new External_case_items__e();
        List<Return_Item__c> returnItems = [SELECT Id, Case_External_Id__c, External_Id__c FROM Return_Item__c];
        event.Payload__c = JSON.serialize(returnItems);
        event.Case_Identificator__c = [SELECT Id, Case_External_Id__c FROM Case LIMIT 1].Case_External_Id__c;
        Database.SaveResult publishResult = EventBus.publish(event);
        Assert.areEqual(publishResult.isSuccess(), true);
        Test.getEventBus().deliver();
        Test.stopTest();

        List<Case> cases = [SELECT Id FROM Case];
        Assert.areEqual(cases.size(), 2);
    }

    @isTest
    static void testExternalApprovalModifiesItems() {
        Test.startTest();
        Item_Approval_Status__e event = new Item_Approval_Status__e();
        Return_Item__c returnItem = [SELECT External_Id__c FROM Return_Item__c LIMIT 1];

        String returnItemExternalId = returnItem.External_Id__c;

        event.Status__c = 'Approved';
        event.Strategy__c = 'Resend items';
        event.Item_External_Id__c = returnItemExternalId;

        Database.SaveResult publishResult = EventBus.publish(event);
        Assert.areEqual(publishResult.isSuccess(), true);
        Test.getEventBus().deliver();
        Test.stopTest();
        Return_Item__c changedReturnItem = [SELECT Status__c, Strategy__c FROM Return_Item__c WHERE External_Id__c = :returnItemExternalId];
        Assert.areEqual(changedReturnItem.Status__c, 'Approved');
        Assert.areEqual(changedReturnItem.Strategy__c, 'Resend items');
    }

    class DataGenerator extends TestDataGenerator {
        public void createData() {
            Product2 firstProduct = createExternalProduct();
            Product2 secondProduct = createExternalProduct();

            Id pricebookId = Test.getStandardPricebookId();
            Pricebook2 pricebook = new Pricebook2(IsActive = true);
            pricebook.Id = pricebookId;
            update pricebook;

            PricebookEntry firstPricebookEntry = createPricebookEntry(pricebook, firstProduct, 40.0);
            PricebookEntry secondPricebookEntry = createPricebookEntry(pricebook, secondProduct, 40.0);

            Account acc = createAccount();

            Order order = createOrder(pricebook, acc);
            Case createdCase = createCaseWithExternalId();

            OrderItem firstOrderItem = createOrderItem(order, firstProduct, 14, firstPricebookEntry);
            OrderItem secondOrderItem = createOrderItem(order, secondProduct, 12, secondPricebookEntry);

            Return_Item__c firstReturnItem = createReturnItem(
                createdCase.Case_External_Id__c,
                firstOrderItem,
                10,
                firstProduct.ProductExternalId__c
            );
            Return_Item__c secondReturnItem = createReturnItem(
                createdCase.Case_External_Id__c,
                secondOrderItem,
                5,
                secondProduct.ProductExternalId__c
            );

            firstReturnItem.Case_External_Id__c = createdCase.Case_External_Id__c;
            secondReturnItem.Case_External_Id__c = createdCase.Case_External_Id__c;
            update firstReturnItem;
            update secondReturnItem;
        }
    }
}