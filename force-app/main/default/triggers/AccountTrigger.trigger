trigger AccountTrigger on Account(after update) {
    TriggerHandler.handle(new AccountTriggerHandler());
}