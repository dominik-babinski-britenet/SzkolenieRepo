public with sharing class CreateOrderController {
    @AuraEnabled(cacheable=true)
    public static List<PricebookEntry> getProductPrices() {
        return [
            SELECT Id, Product2.Name, Product2.ProductCode, Product2.Description, UnitPrice
            FROM PricebookEntry
            WHERE Pricebook2.IsStandard = TRUE AND IsActive = TRUE
        ];
    }

    @AuraEnabled(cacheable=true)
    public static Double getTotalDiscountForOpportunity(Id opportunityId) {
        AggregateResult[] results = [
            SELECT SUM(Discount__r.DiscountValue__c) totalDiscount
            FROM AccountDiscount__c
            WHERE Account__c IN (SELECT AccountId FROM Opportunity WHERE Id = :opportunityId)
        ];

        if (results != null && !results.isEmpty()) {
            return (Double) results[0].get('totalDiscount');
        }

        return 0.0;
    }

    @AuraEnabled
    public static void createNewOrder(List<Id> priceBookEntries, List<Double> productPrices, List<Integer> quantities, Id opportunityId) {
        Id accountId = [SELECT AccountId FROM Opportunity WHERE Id = :opportunityId LIMIT 1].AccountId;

        Order newOrder = new Order(
            OpportunityId = opportunityId,
            AccountId = accountId,
            EffectiveDate = Date.today(),
            Status = 'Draft',
            Pricebook2Id = [SELECT Pricebook2Id FROM PricebookEntry WHERE Pricebook2.IsStandard = TRUE LIMIT 1]
            .Pricebook2Id
        );

        insert newOrder;

        Id orderID = newOrder.Id;
        Integer productCountToInsert = priceBookEntries.size();
        List<OrderItem> orderItems = new List<OrderItem>();

        for (Integer i = 0; i < productCountToInsert; i++) {
            orderItems.add(
                new OrderItem(
                    OrderId = orderID,
                    PricebookEntryId = priceBookEntries[i],
                    UnitPrice = productPrices[i],
                    Quantity = quantities[i]
                )
            );
        }

        insert orderItems;
    }
}