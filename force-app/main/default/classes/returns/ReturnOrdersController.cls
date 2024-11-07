public with sharing class ReturnOrdersController {
    @AuraEnabled(cacheable=true)
    public static List<OrderItem> getOrderItemsForOrder(Id orderId) {
        return [
            SELECT Product2.Name, Product2.External__c, Product2.ProductExternalId__c, Quantity
            FROM OrderItem
            WHERE OrderId = :orderId
        ];
    }

    @AuraEnabled
    public static Map<String, String> createCase(String status, String subject, String description) {
        String externalCaseId = UUID.randomUUID().toString();
        Case caseToCreate = new Case(Subject = subject, Description = description, Status = status, Case_External_Id__c = externalCaseId);
        insert caseToCreate;

        Map<String, String> resultMap = new Map<String, String>();
        resultMap.put('caseId', caseToCreate.Id);
        resultMap.put('caseExternalId', externalCaseId);

        return resultMap;
    }

    @AuraEnabled
    public static List<Return_Item__c> insertJunctionObjects(List<Return_Item__c> itemsToInsert) {
        for (Return_Item__c item : itemsToInsert) {
            item.External_Id__c = UUID.randomUUID().toString();
        }

        insert itemsToInsert;
        return itemsToInsert;
    }

    @AuraEnabled
    public static List<Return_Item__c> filterExternalItems(List<Return_Item__c> initialItems) {
        Set<Id> itemIds = new Set<Id>();

        for (Return_Item__c item : initialItems) {
            itemIds.add(item.Id);
        }

        List<Return_Item__c> externalItems = [
            SELECT External_Id__c, Case_External_Id__c, Returned_Quantity__c, Order_Product__r.Product2.ProductExternalId__c
            FROM Return_Item__c
            WHERE Id IN :itemIds AND Order_Product__r.Product2.External__c = TRUE
        ];

        for (Return_Item__c item : externalItems) {
            item.Product_External_Id__c = item.Order_Product__r.Product2.ProductExternalId__c;
        }

        return externalItems;
    }

    @AuraEnabled
    public static void sendExternalItems(List<Return_Item__c> itemsToSend, String caseExternalId) {
        HttpRequest httpRequest = new HttpRequest();
        httpRequest.setMethod('POST');
        httpRequest.setEndpoint('callout:SynchronizeProducts/services/data/v61.0/sobjects/External_case_items__e');

        External_case_items__e platformEvent = new External_case_items__e(
            Payload__c = JSON.serialize(itemsToSend),
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
    }
}