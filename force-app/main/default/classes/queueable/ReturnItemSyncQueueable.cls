public class ReturnItemSyncQueueable implements Queueable, Database.AllowsCallouts {
    public Return_Item__c returnItem;

    public ReturnItemSyncQueueable(Return_Item__c returnItem) {
        this.returnItem = returnItem;
    }

    public void execute(QueueableContext context) {
        Item_Approval_Status__e event = new Item_Approval_Status__e();
        event.Item_External_Id__c = returnItem.External_Id__c;
        event.Status__c = returnItem.Status__c;
        event.Strategy__c = returnItem.Strategy__c;

        HttpRequest httpRequest = new HttpRequest();
        httpRequest.setMethod('POST');
        httpRequest.setEndpoint('callout:SynchronizeProducts/services/data/v61.0/sobjects/Item_Approval_Status__e');

        String body = JSON.serialize(event);
        httpRequest.setBody(body);

        Http http = new Http();

        try {
            HttpResponse response = http.send(httpRequest);
        } catch (Exception e) {
        }
    }
}