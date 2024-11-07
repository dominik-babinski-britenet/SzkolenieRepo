public with sharing class ApproveReturnItemController {
    @AuraEnabled
    public static void CreateApprovalRequest(String comment, String strategy, Id recordId) {
        Return_Item__c item = new Return_Item__c(Id = recordId, Strategy__c = strategy);
        update item;

        Id caseOwner = [
            SELECT OwnerId
            FROM Case
            WHERE Id IN (SELECT Case__c FROM Return_Item__c WHERE Id = :recordId)
        ][0]
        .OwnerId;

        Approval.ProcessSubmitRequest request = new Approval.ProcessSubmitRequest();
        request.setComments(comment);
        request.setObjectId(recordId);
        request.setNextApproverIds(new List<Id>{ caseOwner });
        request.setProcessDefinitionNameOrId('Return_Item_Approval');
        request.setSkipEntryCriteria(true);
        Approval.ProcessResult result = Approval.process(request);
    }
}