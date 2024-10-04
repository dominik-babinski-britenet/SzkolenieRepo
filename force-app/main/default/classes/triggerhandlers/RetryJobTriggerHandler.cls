public with sharing class RetryJobTriggerHandler extends TriggerHandler {
    public override void afterUpdate() {
        List<Retry_Job__c> finishedJobs = new List<Retry_Job__c>();
        Set<Id> syncAttemptIds = new Set<Id>();

        for (Retry_Job__c job : (List<Retry_Job__c>) Trigger.new) {
            if (job.Items_to_Sync__c <= job.Items_synced__c) {
                finishedJobs.add(job);
                syncAttemptIds.add(job.Sync_Attempt__c);
            }
        }

        if (finishedJobs.size() <= 0) {
            return;
        }

        Set<Id> jobsToAbort = new Set<Id>();

        for (Retry_Job__c job : [
            SELECT Sync_Attempt__r.ScheduledJobId__c
            FROM Retry_Job__c
            WHERE Has_failed__c = FALSE AND Sync_Attempt__c IN :syncAttemptIds
        ]) {
            jobsToAbort.add(job.Sync_Attempt__r.ScheduledJobId__c);
        }

        AggregateResult[] groupedResult = [
            SELECT Sync_Attempt__r.ScheduledJobId__c, COUNT(Id)
            FROM Retry_Job__c
            GROUP BY Sync_Attempt__r.ScheduledJobId__c
        ];

        for (AggregateResult result : groupedResult) {
            if ((Integer) result.get('expr0') >= 3) {
                jobsToAbort.add((String) result.get('ScheduledJobId__c'));
            }
        }

        for (Id id : jobsToAbort) {
            System.abortJob(id);
        }
    }
}