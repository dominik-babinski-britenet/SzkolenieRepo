public with sharing class ProductSynchronize {
    public static void deleteProducts(List<Product2> productsToDelete) {
        makeRequest(JSON.serialize(productsToDelete), 'DELETE');
    }

    public static void upsertProducts(List<Product2> productsToUpsert) {
        List<String> productIds = new List<String>();
        makeRequest(JSON.serialize(productsToUpsert), 'POST');
    }

    @future(callout=true)
    public static void makeRequest(String body, String method) {
        HttpRequest httpRequest = new HttpRequest();
        String header = 'application/json;  charset=utf-8';
        httpRequest.setMethod(method);
        httpRequest.setHeader('Content-Type', header);
        httpRequest.setEndpoint('callout:SynchronizeProductsLegacy/services/apexrest/productsync');
        httpRequest.setBody(body);

        Http http = new Http();
        String status = 'Pending';

        try {
            HttpResponse response = http.send(httpRequest);
            Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            status = (String) resultMap.get('Status');
        } catch (Exception e) {
            status = 'Connection Error';
        }

        logRequest(method, header, body, status);
    }

    public static void logRequest(String method, String header, String body, String status) {
        List<Product_Log__c> logsToInsert = new List<Product_Log__c>();
        List<Product2> sentProducts = (List<Product2>) JSON.deserialize(body, List<Product2>.class);

        RestLogger__c logger = new RestLogger__c();
        logger.Body__c = body;
        logger.Header__c = header;
        logger.Method__c = method;
        logger.Status__c = status;

        insert logger;

        for (Product2 product : sentProducts) {
            logsToInsert.add(new Product_Log__c(Product__c = product.Id, Rest_Logger__c = logger.Id));
        }

        insert logsToInsert;
    }
}