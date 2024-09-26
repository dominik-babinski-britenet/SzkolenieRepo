@RestResource(urlMapping='/productsync/*')
global with sharing class ProductRestService {
    @HttpPost
    global static void handlePostRequest() {
        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;

        String productsJson = request.requestBody.toString();
        List<Product2> productsToUpsert = (List<Product2>) JSON.deserialize(productsJson, List<Product2>.class);

        Allow_Sync__c syncSetting = [SELECT Id, Active__c FROM Allow_Sync__c LIMIT 1];
        syncSetting.Active__c = true;
        upsert syncSetting;

        upsert productsToUpsert ProductExternalId__c;

        syncSetting.Active__c = false;
        upsert syncSetting;
    }

    @HttpDelete
    global static void handleDeleteRequest() {
        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;

        String productsJson = request.requestBody.toString();
        List<Product2> incomingProducts = (List<Product2>) JSON.deserialize(productsJson, List<Product2>.class);
        List<String> externalProductIds = new List<String>();

        for (Product2 product : incomingProducts) {
            externalProductIds.add(product.ProductExternalId__c);
        }

        List<Product2> productsToDelete = [
            SELECT Id, ProductExternalId__c
            FROM Product2
            WHERE ProductExternalId__c IN :externalProductIds
        ];

        Allow_Sync__c syncSetting = [SELECT Id, Active__c FROM Allow_Sync__c LIMIT 1];
        syncSetting.Active__c = true;
        upsert syncSetting;

        delete productsToDelete;

        syncSetting.Active__c = false;
        upsert syncSetting;
    }
}