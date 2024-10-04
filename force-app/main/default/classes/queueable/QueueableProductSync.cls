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
        String header = 'application/json;  charset=utf-8';
        httpRequest.setMethod(method);
        httpRequest.setHeader('Content-Type', header);
        httpRequest.setEndpoint('callout:SynchronizeProductsLegacy/services/apexrest/productsync');

        String body = JSON.serialize(products);
        httpRequest.setBody(body);

        Http http = new Http();
        String status = LogUtils.PENDING;

        try {
            HttpResponse response = http.send(httpRequest);
            Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            status = (String) resultMap.get('Status');
        } catch (Exception e) {
            status = LogUtils.CONNECTION_ERROR;
        }

        logId = logRequest();

        if (status == LogUtils.FAILED || status == LogUtils.CONNECTION_ERROR) {
            String cronExpression = '0 0 10 * * ?';
            String jobName = logId;
            SyncAttempt__c syncAttempt = new SyncAttempt__c(Rest_Logger__c = logId);
            insert syncAttempt;

            Id jobId = System.schedule(jobName, cronExpression, new RetryScheduler(logId, syncAttempt, method));
            syncAttempt.ScheduledJobId__c = jobId;
            update syncAttempt;
        }
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