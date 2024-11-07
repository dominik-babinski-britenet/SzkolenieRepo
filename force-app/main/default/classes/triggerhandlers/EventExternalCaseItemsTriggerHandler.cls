public class EventExternalCaseItemsTriggerHandler extends TriggerHandler {
    protected override void afterInsert() {
        List<Return_Item__c> returnItems = new List<Return_Item__c>();
        List<Case> casesToInsert = new List<Case>();
        Map<String, Case> casesMap = new Map<String, Case>();

        for (External_case_items__e event : (List<External_case_items__e>) Trigger.new) {
            returnItems.addAll((List<Return_Item__c>) JSON.deserialize(event.Payload__c, List<Return_Item__c>.class));

            Case caseToAdd = new Case(
                Status = 'New',
                Subject = String.format('External return order of id {0}', new List<String>{ event.Case_Identificator__c }),
                Case_External_Id__c = event.Case_Identificator__c
            );

            casesToInsert.add(caseToAdd);
            casesMap.put(caseToAdd.Case_External_Id__c, caseToAdd);
        }

        insert casesToInsert;

        List<Return_Item__c> itemsToAdd = new List<Return_Item__c>();

        for (Return_Item__c item : returnItems) {
            itemsToAdd.add(
                new Return_Item__c(
                    Status__c = 'Pending',
                    Strategy__c = 'None',
                    Product__r = new Product2(ProductExternalId__c = item.Product_External_Id__c),
                    Synchronized__c = true,
                    Returned_Quantity__c = item.Returned_Quantity__c,
                    External_Id__c = item.External_Id__c,
                    Case__c = casesMap.get(item.Case_External_Id__c).Id,
                    Case_External_Id__c = item.Case_External_Id__c
                )
            );
        }

        insert itemsToAdd;

        for (Case createdCase : casesToInsert) {
            System.enqueueJob(new CaseCreatedEventQueueable(createdCase.Case_External_Id__c));
        }
    }
}