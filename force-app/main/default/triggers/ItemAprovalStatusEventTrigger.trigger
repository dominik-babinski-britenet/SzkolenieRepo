trigger ItemAprovalStatusEventTrigger on Item_Approval_Status__e(after insert) {
    TriggerHandler.handle(new ItemApprovalStatusEventTriggerHandler());
}