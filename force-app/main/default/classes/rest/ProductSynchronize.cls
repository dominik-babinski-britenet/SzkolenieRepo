public with sharing class ProductSynchronize {
    public static void deleteProducts(List<Product2> productsToDelete) {
        makeRequest(JSON.serialize(productsToDelete), 'DELETE');
    }

    public static void upsertProducts(List<Product2> productsToUpsert) {
        makeRequest(JSON.serialize(productsToUpsert), 'POST');
    }

    @future(callout=true)
    public static void makeRequest(String productList, String method) {
        HttpRequest httpRequest = new HttpRequest();

        httpRequest.setMethod(method);
        httpRequest.setHeader('Content-Type', 'application/json;  charset=utf-8');
        httpRequest.setEndpoint('callout:SynchronizeProductsLegacy/services/apexrest/productsync');
        httpRequest.setBody(productList);

        Http http = new Http();

        try {
            HttpResponse response = http.send(httpRequest);
            System.debug('Response: ' + response.getBody());
        } catch (Exception e) {
            System.debug('Error during HTTP callout: ' + e.getMessage());
        }
    }
}