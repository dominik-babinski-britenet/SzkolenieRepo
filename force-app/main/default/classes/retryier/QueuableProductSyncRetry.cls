public class QueuableProductSyncRetry {
    private Boolean scheduled = false;
    private String body;
    private String header;
    private String method;
    private String status;
    private RestLogger__c logger = new RestLogger__c();
    private List<Product2> products = new List<Product2>();

    public QueuableProductSyncRetry(RestLogger__c logger) {
        this.logger = logger;
        this.method = logger.Method__c;
        List<Product_Log__c> loggerProducts;

        if (method == 'POST') {
            loggerProducts = [
                SELECT
                    Product__r.Name,
                    Product__r.Author__c,
                    Product__r.IsActive,
                    Product__r.External__c,
                    Product__r.ProductExternalId__c,
                    Product__r.ProductClass,
                    Product__r.ProductCode,
                    Product__r.Description
                FROM Product_Log__c
                WHERE Rest_Logger__c = :logger.Id
            ];

            for (Product_Log__c productLog : loggerProducts) {
                products.add(productLog.Product__r);
            }

            return;
        }

        if (method == 'DELETE') {
            loggerProducts = [
                SELECT ProductExternalId__c
                FROM Product_Log__c
                WHERE Rest_Logger__c = :logger.Id
            ];

            for (Product_Log__c productLog : loggerProducts) {
                products.add(new Product2(ProductExternalId__c = productLog.ProductExternalId__c));
            }
        }
    }

    public void execute() {
        HttpRequest httpRequest = new HttpRequest();
        httpRequest.setMethod(method);
        httpRequest.setEndpoint('callout:SynchronizeProducts/services/apexrest/productsync');

        String body = JSON.serialize(products);
        httpRequest.setBody(body);

        Http http = new Http();
        String status = LogUtils.PENDING;
        ProductRestService.DataModel dataModel = new ProductRestService.DataModel();

        try {
            HttpResponse response = http.send(httpRequest);
            dataModel = (ProductRestService.DataModel) JSON.deserialize(response.getBody().toString(), ProductRestService.DataModel.class);
            status = dataModel.status;
        } catch (Exception e) {
            status = LogUtils.CONNECTION_ERROR;
            System.debug(e);
        } finally {
            logger.Status__c = status;
            logger.Retries__c = logger.Retries__c + 1;
            update logger;
        }
    }
}