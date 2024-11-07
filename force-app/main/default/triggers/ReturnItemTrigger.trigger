trigger ReturnItemTrigger on Return_Item__c(before update, after update) {
    TriggerHandler.handle(new ReturnItemTriggerHandler());
}