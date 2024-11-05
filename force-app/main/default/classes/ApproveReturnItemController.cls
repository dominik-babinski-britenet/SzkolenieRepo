public with sharing class ApproveReturnItemController {
    @AuraEnabled
    public static void CreateApprovalRequest(String comment, String strategy, Id recordId) {
        Return_Item__c item = new Return_Item__c(Id = recordId, Strategy__c = strategy);
        System.debug(strategy);
        update item;

        Id caseOwner = [
            SELECT OwnerId
            FROM Case
            WHERE Id IN (SELECT Case__c FROM Return_Item__c WHERE Id = :recordId)
        ][0]
        .OwnerId;

        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments(comment);
        req1.setObjectId(recordId);
        req1.setNextApproverIds(new List<Id>{ caseOwner });
        req1.setProcessDefinitionNameOrId('Return_Item_Approval');
        req1.setSkipEntryCriteria(true);
        Approval.ProcessResult result = Approval.process(req1);
    }
}