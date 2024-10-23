public with sharing class DiscountDataViewController {
    @AuraEnabled(cacheable=true)
    public static List<Discount__c> getAllDiscounts() {
        List<Discount__c> discounts = [
            SELECT
                Id,
                Name,
                DiscountValue__c,
                toLabel(Discount_Requirement__c),
                Discount_Requirement_Value__c,
                IsActive__c,
                (SELECT Account__r.Name FROM AccountDiscounts__r)
            FROM Discount__c
        ];

        return discounts;
    }
}