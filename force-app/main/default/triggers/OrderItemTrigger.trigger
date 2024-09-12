trigger OrderItemTrigger on OrderItem(after insert, after update, after delete) {
    TriggerHandler.handle(new OrderItemTriggerHandler());
}