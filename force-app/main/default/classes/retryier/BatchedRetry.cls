public class BatchedRetry implements Database.Batchable<sObject>, Database.AllowsCallouts {
    public Database.QueryLocator start(Database.BatchableContext context) {
        return Database.getQueryLocator(
            [
                SELECT Id, Method__c, Retries__c, Status__c
                FROM RestLogger__c
                WHERE (Status__c = :LogUtils.FAILED OR Status__c = :LogUtils.CONNECTION_ERROR) AND Retries__c < 3
            ]
        );
    }

    public void execute(Database.BatchableContext context, List<SObject> scope) {
        if (scope == null || scope.size() <= 0) {
            return;
        }

        for (RestLogger__c restLogger : (List<RestLogger__c>) scope) {
            new QueuableProductSyncRetry(restLogger).execute();
        }
    }

    public void finish(Database.BatchableContext context) {
    }
}