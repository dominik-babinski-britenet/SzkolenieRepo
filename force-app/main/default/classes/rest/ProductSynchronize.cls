public with sharing class ProductSynchronize {
    public static void deleteProducts(List<Product2> productsToDelete) {
        makeRequest(productsToDelete, 'DELETE');
    }

    public static void upsertProducts(List<Product2> productsToUpsert) {
        makeRequest(productsToUpsert, 'POST');
    }

    public static void makeRequest(List<Product2> productList, String method) {
        String requestBody = JSON.serialize(productList);
        HttpRequest httpRequest = new HttpRequest();

        httpRequest.setMethod(method);
        httpRequest.setHeader('Content-Type', 'application/json;  charset=utf-8');
        httpRequest.setEndpoint('callout:SynchronizeProductsLegacy/services/apexrest/productsync');
        httpRequest.setBody(requestBody);

        Http http = new Http();

        try {
            HttpResponse response = http.send(httpRequest);
            System.debug('Response: ' + response.getBody());
        } catch (Exception e) {
            System.debug('Error during HTTP callout: ' + e.getMessage());
        }
    }
}