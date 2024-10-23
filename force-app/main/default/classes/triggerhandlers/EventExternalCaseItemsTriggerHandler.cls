public class EventExternalCaseItemsTriggerHandler extends TriggerHandler {
    protected override void afterInsert() {
        Map<OrderItem, String> orderItemsToProcess = new Map<OrderItem, String>();
        List<Case> casesToInsert = new List<Case>();

        for (External_case_items__e event : (List<External_case_items__e>) Trigger.new) {
            List<OrderItem> orderItems = (List<OrderItem>) JSON.deserialize(event.Payload__c, List<OrderItem>.class);
            String externalCaseId = event.Case_Identificator__c;

            casesToInsert.add(
                new Case(Status = 'New', Subject = String.format('External return order of id {0}', new List<String>{ externalCaseId }))
            );

            for (OrderItem item : orderItems) {
                orderItemsToProcess.put(item, externalCaseId);
            }
        }

        insert casesToInsert;

        List<Return_Item__c> returnItems = new List<Return_Item__c>();

        for (OrderItem item : orderItemsToProcess.keySet()) {
            returnItems.add(
                new Return_Item__c(
                    Status__c = 'Pending',
                    Strategy__c = 'None',
                    Returned_Quantity__c = item.Quantity,
                    Product__r = new Product2(ProductExternalId__c = item.Product2.ProductExternalId__c)
                )
            );
        }
    }
}