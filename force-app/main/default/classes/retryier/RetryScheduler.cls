global class RetryScheduler implements Schedulable {
    public Id logId;
    public String method;
    public SyncAttempt__c syncAttempt;

    public RetryScheduler(Id logId, SyncAttempt__c syncAttempt, String method) {
        this.logId = logId;
        this.method = method;
        this.syncAttempt = syncAttempt;
    }

    global void execute(SchedulableContext context) {
        Integer itemCount = [SELECT COUNT() FROM Product_Log__c WHERE Rest_Logger__c = :logId];
        Retry_Job__c retryJob = new Retry_Job__c(Sync_Attempt__c = syncAttempt.Id, Items_to_Sync__c = itemCount, Items_synced__c = 0);
        insert retryJob;
        System.enqueueJob(new BatchedRetry(logId, retryJob, method));
    }
}