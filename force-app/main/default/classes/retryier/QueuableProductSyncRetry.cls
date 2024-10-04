public class QueuableProductSyncRetry implements Queueable, Database.AllowsCallouts {
    private Boolean scheduled = false;
    private String body;
    private String header;
    private String method;
    private String status;
    private List<Product2> products;
    private Retry_Job__c retryJob;

    public QueuableProductSyncRetry(List<Product2> products, Retry_Job__c retryJob, String method) {
        this.products = products;
        this.method = method;
        this.retryJob = retryJob;
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
        } finally {
            retryJob.Items_synced__c = retryJob.Items_synced__c + products.size();

            if (status == LogUtils.FAILED || status == LogUtils.CONNECTION_ERROR) {
                retryJob.Has_failed__c = true;
            }

            update retryJob;
        }
    }
}