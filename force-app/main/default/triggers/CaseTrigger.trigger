trigger CaseTrigger on Case(after update) {
    TriggerHandler.handle(new CaseTriggerHandler());
}