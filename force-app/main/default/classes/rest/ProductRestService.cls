@RestResource(urlMapping='/productsync/*')
global with sharing class ProductRestService {
    public static Boolean IS_SYNCING = false;

    @HttpPost
    global static void handlePostRequest() {
        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;

        IS_SYNCING = true;
        DataModel dataModel = new DataModel();

        try {
            String productsJson = request.requestBody.toString();
            List<Product2> productsToUpsert = (List<Product2>) JSON.deserialize(productsJson, List<Product2>.class);

            for (Product2 product : productsToUpsert) {
                product.Id = null;
            }
            upsert productsToUpsert ProductExternalId__c;
            dataModel.status = LogUtils.SUCCESS;
        } catch (Exception e) {
            dataModel.status = LogUtils.FAILED;
        } finally {
            response.responseBody = Blob.valueOf(JSON.serialize(dataModel));
            IS_SYNCING = false;
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

        IS_SYNCING = true;
        DataModel dataModel = new DataModel();

        try {
            delete productsToDelete;
            dataModel.status = LogUtils.SUCCESS;
        } catch (Exception e) {
            dataModel.status = LogUtils.FAILED;
        } finally {
            response.responseBody = Blob.valueOf(JSON.serialize(dataModel));
            IS_SYNCING = false;
        }
    }

    public class DataModel {
        public String status { get; set; }
    }
}