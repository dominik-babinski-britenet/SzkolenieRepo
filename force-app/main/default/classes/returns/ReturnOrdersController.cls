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
    public static string sendExternalItems(List<OrderItem> items, String caseExternalId) {
        HttpRequest httpRequest = new HttpRequest();
        httpRequest.setMethod('POST');
        httpRequest.setEndpoint('callout:SynchronizeProducts/services/data/v61.0/sobjects/External_case_items__e');

        External_case_items__e platformEvent = new External_case_items__e(
            Payload__c = JSON.serialize(items),
            Case_Identificator__c = caseExternalId
        );

        String body = JSON.serialize(platformEvent);
        httpRequest.setBody(body);

        Http http = new Http();

        try {
            HttpResponse response = http.send(httpRequest);
        } catch (Exception e) {
            System.debug(e.getMessage());
        }

        return '';
    }
}