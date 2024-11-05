public with sharing class ItemApprovalStatusEventTriggerHandler extends TriggerHandler {
    public override void afterInsert() {
        List<Return_Item__c> itemsToUpdate = new List<Return_Item__c>();

        for (Item_Approval_Status__e event : (List<Item_Approval_Status__e>) Trigger.new) {
            itemsToUpdate.add(
                new Return_Item__c(External_Id__c = event.Item_External_Id__c, Status__c = event.Status__c, Strategy__c = event.Strategy__c)
            );
        }

        upsert itemsToUpdate External_Id__c;
    }
}