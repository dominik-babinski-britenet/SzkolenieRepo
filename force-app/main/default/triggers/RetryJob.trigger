trigger RetryJob on Retry_Job__c(after update) {
    TriggerHandler.handle(new RetryJobTriggerHandler());
}