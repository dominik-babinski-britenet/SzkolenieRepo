public with sharing class DiscountDataViewController {
    @AuraEnabled(cacheable=true)
    public static List<Discount__c> getAllDiscounts() {
        return [SELECT Id, Name, IsActive__c, Discount_Requirement__c, Discount_Requirement_Value__c, DiscountValue__c FROM Discount__c];
    }
}