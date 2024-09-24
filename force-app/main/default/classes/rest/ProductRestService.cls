@RestResource(urlMapping='/productsync/*')
global with sharing class ProductRestService {
    global static Boolean isFromRest = true;

    @HttpPost
    global static void handlePostRequest() {
        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;

        String productsJson = request.requestBody.toString();
        List<Product2> productsToUpsert = (List<Product2>) JSON.deserialize(productsJson, List<Product2>.class);

        for (Product2 product : productsToUpsert) {
            product.External__c = true;
        }

        isFromRest = true;
        upsert productsToUpsert;
        isFromRest = false;
    }

    @HttpDelete
    global static void handleDeleteRequest() {
        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;

        String productsJson = request.requestBody.toString();
        List<Product2> productsToDelete = (List<Product2>) JSON.deserialize(productsJson, List<Product2>.class);

        isFromRest = true;
        delete productsToDelete;
        isFromRest = false;
    }
}