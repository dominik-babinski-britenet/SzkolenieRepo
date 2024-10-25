public class ReturnItemTriggerHandler extends TriggerHandler {
    public override void beforeUpdate() {
        //check if item is external and if it is prevent its update
    }

    public override void afterUpdate() {
        for (Return_Item__c returnItem : (List<Return_Item__c>) Trigger.new) {
            if (returnItem.Synchronized__c == false) {
                continue;
            }

            if (
                returnItem.Status__c == 'Pending' ||
                returnItem.Status__c == ((Return_Item__c) Trigger.oldMap.get(returnItem.Id)).Status__c
            ) {
                continue;
            }

            System.enqueueJob(new ReturnItemSyncQueueable(returnItem));
        }
    }
}