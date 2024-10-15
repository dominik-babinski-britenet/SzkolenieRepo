public with sharing class CreateOrderController {
    @AuraEnabled(cacheable=true)
    public static List<PricebookEntry> getProductPrices(Id opportunityId) {
        return [
            SELECT Id, Product2.Name, Product2.ProductCode, Product2.Description, UnitPrice
            FROM PricebookEntry
            WHERE Pricebook2.Id = :getPricebookIdFromOpportunityId(opportunityId) AND IsActive = TRUE
        ];
    }

    @AuraEnabled
    public static Id getPricebookIdFromOpportunityId(Id opportunityId) {
        Account userAccount = [
            SELECT Partner__c
            FROM Account
            WHERE Id IN (SELECT AccountId FROM Opportunity WHERE Id = :opportunityId)
            LIMIT 1
        ];

        String pricebookName = (userAccount != null && userAccount.Partner__c) ? 'Partner Pricebook' : 'Non-Partner Pricebook';

        return [SELECT Id FROM Pricebook2 WHERE Name = :pricebookName LIMIT 1].Id;
    }

    @AuraEnabled(cacheable=true)
    public static Double getTotalDiscountForOpportunity(Id opportunityId) {
        AggregateResult[] results = [
            SELECT SUM(Discount__r.DiscountValue__c) totalDiscount
            FROM AccountDiscount__c
            WHERE Account__c IN (SELECT AccountId FROM Opportunity WHERE Id = :opportunityId)
        ];

        return (results != null && !results.isEmpty()) ? (Double) results[0].get('totalDiscount') : 0.0;
    }

    @AuraEnabled
    public static void createNewOrder(List<Id> priceBookEntries, List<Double> productPrices, List<Integer> quantities, Id opportunityId) {
        Id accountId = [SELECT AccountId FROM Opportunity WHERE Id = :opportunityId LIMIT 1].AccountId;
        Id pricebookId = getPricebookIdFromOpportunityId(opportunityId);

        Order newOrder = new Order(
            OpportunityId = opportunityId,
            AccountId = accountId,
            EffectiveDate = Date.today(),
            Status = 'Draft',
            Pricebook2Id = pricebookId
        );

        insert newOrder;

        List<OrderItem> orderItems = new List<OrderItem>();

        for (Integer i = 0; i < priceBookEntries.size(); i++) {
            orderItems.add(
                new OrderItem(
                    OrderId = newOrder.Id,
                    PricebookEntryId = priceBookEntries[i],
                    UnitPrice = productPrices[i],
                    Quantity = quantities[i]
                )
            );
        }

        insert orderItems;

        newOrder.Status = 'Activated';
        update newOrder;
    }

    @AuraEnabled
    public static void closeOpportunity(Id opportunityId) {
        Opportunity opportunityToClose = [SELECT Id, StageName FROM Opportunity WHERE Id = :opportunityId LIMIT 1];
        opportunityToClose.StageName = 'Closed Won';
        update opportunityToClose;
    }
}