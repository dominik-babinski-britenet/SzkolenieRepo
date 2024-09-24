public with sharing class synchronizeProducts {
    public static void upsertProducts(List<Product2> productList) {
        Map<String, Object> requestBody = new Map<String, Object>();
        List<Map<String, Object>> records = new List<Map<String, Object>>();

        int i = 0;

        for (Product2 product : productList) {
            Map<String, Object> productRecord = new Map<String, Object>();
            Map<String, String> attributes = new Map<String, String>();
            attributes.put('type', 'Product2');
            attributes.put('referenceId', i);
            productRecord.put('attributes', attributes);

            productRecord.put('Name', product.Name);
            productRecord.put('Family', product.Family);
            productRecord.put('Description', product.Description);
            productRecord.put('ProductCode', product.ProductCode);
            productRecord.put('External__c', true);
            productRecord.put('ExternalId', product.ExternalId);
            records.add(productRecord);
        }

        requestBody.put('records', records);

        String requestBodyJson = JSON.serialize(requestBody);
        HttpRequest httpRequest = new HttpRequest();

        httpRequest.setMethod('POST');
        httpRequest.setHeader('Content-Type', 'application/json;  charset=utf-8');
        httpRequest.setEndpoint('callout:SynchronizeProductsLegacy/services/data/v61.0/composite/tree/product2');
        httpRequest.setBody(requestBodyJson);

        Http http = new Http();

        try {
            HttpResponse response = http.send(httpRequest);
            System.debug('Response: ' + response.getBody());
        } catch (Exception e) {
            System.debug('Error during HTTP callout: ' + e.getMessage());
        }
    }
}