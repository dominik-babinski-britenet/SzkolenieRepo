trigger LeadTrigger on Lead(after update) {
    TriggerHandler.handle(new LeadTriggerHandler());
}