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
    public static Double getTotalDiscountForOpportunity(Opportunity opportunity) {
        AggregateResult[] results = [
            SELECT SUM(Discount__r.DiscountValue__c) totalDiscount
            FROM AccountDiscount__c
            WHERE Account__c = :opportunity.AccountId
        ];

        if (results != null && !results.isEmpty()) {
            return (Double) results[0].get('totalDiscount');
        }

        return 0.0;
    }
}