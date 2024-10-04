public class BatchedRetry implements Database.Batchable<sObject> {
    public Id logId;
    public String method;
    public Retry_Job__c retryJob;

    public BatchedRetry(Id logId, Retry_Job__c retryJob, String method) {
        this.logId = logId;
        this.retryJob = retryJob;
        this.method = method;
    }

    public Database.QueryLocator start(Database.BatchableContext context) {
        return Database.getQueryLocator(
            [SELECT Rest_Logger__r.Method__c, Product__r.Name, Product__r.Id FROM Product_Log__c WHERE Rest_Logger__c = :logId]
        );
    }

    public void execute(Database.BatchableContext context, List<SObject> scope) {
        System.enqueueJob(new QueuableProductSyncRetry(scope, retryJob, method));
    }

    public void finish(Database.BatchableContext context) {
    }
}