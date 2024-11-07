trigger OrderTrigger on Order(after insert) {
    TriggerHandler.handle(new OrderTriggerHandler());
}