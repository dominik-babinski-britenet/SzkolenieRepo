trigger AccountDiscountTrigger on AccountDiscount__c(after insert, after update, after delete) {
    TriggerHandler.handle(new AccountDiscountTriggerHandler());
}