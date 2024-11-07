trigger DiscountTrigger on Discount__c(after insert, after update, after delete) {
    TriggerHandler.handle(new DiscountTriggerHandler());
}