public with sharing class CreateOrderController {
    @AuraEnabled(cacheable=true)
    public static List<PricebookEntry> getProductPrices() {
        return [
            SELECT Id, Product2.Name, Product2.ProductCode, Product2.Description, UnitPrice
            FROM PricebookEntry
            WHERE Pricebook2.IsStandard = TRUE AND IsActive = TRUE
        ];
    }
}