trigger OpportunityTrigger on Opportunity(after update) {
    TriggerHandler.handle(new OpportunityTriggerHandler());
}