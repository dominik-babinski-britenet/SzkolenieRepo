@RestResource(urlMapping='/productsync/*')
global with sharing class ProductRestService {
    public static Integer syncRequests = 0;

    @HttpPost
    global static void handlePostRequest() {
        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;
        response.addHeader('Content-Type', 'application/json');

        syncRequests += 1;

        try {
            String productsJson = request.requestBody.toString();
            List<Product2> productsToUpsert = (List<Product2>) JSON.deserialize(productsJson, List<Product2>.class);

            for (Product2 product : productsToUpsert) {
                product.Id = null;
            }
            upsert productsToUpsert ProductExternalId__c;

            response.responseBody = Blob.valueOf('{"Status": "' + LogUtils.SUCCESS + '"}');
        } catch (Exception e) {
            response.responseBody = Blob.valueOf('{"Status": "' + LogUtils.FAILED + '"}');
        } finally {
            syncRequests -= 1;
        }
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

        syncRequests += 1;

        try {
            delete productsToDelete;
        } catch (Exception e) {
        } finally {
            syncRequests -= 1;
        }
    }
}