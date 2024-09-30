public with sharing class LeadTriggerHandler extends TriggerHandler {
    public override void afterUpdate() {
        List<Account> accountsToUpdate = new List<Account>();
        Map<ID, Schema.RecordTypeInfo> recordTypeMap = Lead.sObjectType.getDescribe().getRecordTypeInfosById();

        for (Lead lead : (List<Lead>) Trigger.new) {
            if (lead.isConverted && !((Lead) Trigger.oldMap.get(lead.Id)).isConverted) {
                Boolean isPartner = recordTypeMap.get(lead.recordTypeID).getName().containsIgnoreCase('Partner');
                accountsToUpdate.add(new Account(Id = lead.ConvertedAccountId, Partner__c = isPartner));
            }
        }

        update accountsToUpdate;
    }
}