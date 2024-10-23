public with sharing class ReturnOrdersController {
    @AuraEnabled(cacheable=true)
    public static List<OrderItem> getOrderItemsForOrder(Id orderId) {
        return [SELECT Product2.Name, Product2.External__c, Quantity FROM OrderItem WHERE OrderId = :orderId];
    }

    @AuraEnabled
    public static string insertJunctionObjects(List<Return_Item__c> itemsToInsert) {
        insert itemsToInsert;
        return '';
    }

    @AuraEnabled
    public static string sendExternalItems() {
        return '';
    }
}