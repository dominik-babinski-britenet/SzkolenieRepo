trigger EventExternalCaseItemsTrigger on External_case_items__e(after insert) {
    TriggerHandler.handle(new EventExternalCaseItemsTriggerHandler());
}