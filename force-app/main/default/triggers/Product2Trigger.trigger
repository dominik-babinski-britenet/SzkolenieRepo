trigger Product2Trigger on Product2(after insert, after update, after delete) {
    TriggerHandler.handle(new Product2TriggerHandler());
}