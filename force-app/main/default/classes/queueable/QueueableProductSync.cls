public class QueueableProductSync implements Queueable, Database.AllowsCallouts {
    private String body;
    private String header;
    private String method;
    private String status;
    private List<Product2> products;
    private Id logId;

    public QueueableProductSync(List<Product2> products, String method) {
        this.products = products;
        this.method = method;
    }

    public void execute(QueueableContext context) {
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
        }

        logId = logRequest();
    }

    public Id logRequest() {
        List<Product_Log__c> logsToInsert = new List<Product_Log__c>();
        List<Product2> sentProducts = products;

        RestLogger__c logger = new RestLogger__c();
        logger.Header__c = header;
        logger.Method__c = method;
        logger.Status__c = status;

        insert logger;

        for (Product2 product : sentProducts) {
            logsToInsert.add(new Product_Log__c(Product__c = product.Id, Rest_Logger__c = logger.Id));
        }

        insert logsToInsert;

        return logger.Id;
    }
}