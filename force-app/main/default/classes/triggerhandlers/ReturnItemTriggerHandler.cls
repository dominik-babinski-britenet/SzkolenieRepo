public class ReturnItemTriggerHandler extends TriggerHandler {
    public override void afterUpdate() {
        synchronizeItems();
        updateCasesAndOrders();
    }

    private void updateCasesAndOrders() {
        Set<Id> idsToProcess = new Set<Id>();
        List<Return_Item__c> itemsToProcess = new List<Return_Item__c>();
        Set<String> casesExternalIds = new Set<String>();

        for (Return_Item__c returnItem : (List<Return_Item__c>) Trigger.new) {
            if (
                returnItem.Synchronized__c == true ||
                returnItem.Status__c == 'Pending' ||
                returnItem.Status__c == 'Awaiting Approval' ||
                returnItem.Status__c == ((Return_Item__c) Trigger.oldMap.get(returnItem.Id)).Status__c
            ) {
                continue;
            }

            idsToProcess.add(returnItem.Id);
            itemsToProcess.add(returnItem);
            casesExternalIds.add(returnItem.Case_External_Id__c);
        }

        List<Case> casesToCheck = [
            SELECT Id, Case_External_Id__c, (SELECT Id, Status__c FROM Return_Items__r)
            FROM Case
            WHERE Case_External_Id__c IN :casesExternalIds
        ];
        List<Case> casesToUpdate = new List<Case>();
        List<Case> approvedCases = new List<Case>();

        for (Case affectedCase : casesToCheck) {
            if (affectedCase.Return_Items__r.size() == 0) {
                continue;
            }

            Boolean rejected = false;
            Boolean pending = false;

            for (Return_Item__c returnItem : affectedCase.Return_Items__r) {
                if (returnItem.Status__c == 'Rejected') {
                    rejected = true;
                    break;
                }

                if (returnItem.Status__c == 'Pending' || returnItem.Status__c == 'Awaiting Approval') {
                    pending = true;
                    break;
                }
            }

            if (pending) {
                continue;
            }

            casesToUpdate.add(new Case(Id = affectedCase.Id, Approval_Status__c = rejected ? 'Rejected' : 'Approved'));

            if (!rejected) {
                approvedCases.add(affectedCase);
            }
        }

        update casesToUpdate;

        applyApprovedCases(approvedCases);
    }

    private void synchronizeItems() {
        for (Return_Item__c returnItem : (List<Return_Item__c>) Trigger.new) {
            if (returnItem.Synchronized__c == false) {
                continue;
            }

            if (returnItem.Status__c == ((Return_Item__c) Trigger.oldMap.get(returnItem.Id)).Status__c) {
                continue;
            }

            System.enqueueJob(new ReturnItemSyncQueueable(returnItem));
        }
    }

    public void applyApprovedCases(List<Case> cases) {
        Set<String> approvedCasesExternalIds = new Set<String>();

        for (Case caseEvaluated : cases) {
            approvedCasesExternalIds.add(caseEvaluated.Case_External_Id__c);
        }

        List<Return_Item__c> itemsToProcess = [
            SELECT
                Id,
                Returned_Quantity__c,
                Product_External_Id__c,
                Strategy__c,
                Order_Product__r.Product2Id,
                Order_Product__r.PricebookEntryId,
                Order_Product__r.Quantity,
                Order_Product__r.OrderId,
                Order_Product__c
            FROM Return_Item__c
            WHERE Case_External_Id__c IN :approvedCasesExternalIds
        ];

        Set<Id> modifiedOrdersIds = new Set<Id>();
        List<OrderItem> itemsToDelete = new List<OrderItem>();
        List<OrderItem> itemsToUpdate = new List<OrderItem>();
        List<OrderITem> itemsToCreate = new List<OrderItem>();

        for (Return_Item__c item : itemsToProcess) {
            modifiedOrdersIds.add(item.Order_Product__r.OrderId);

            if (item.Strategy__c == 'Return Money') {
                if (item.Order_Product__r.Quantity > item.Returned_Quantity__c) {
                    itemsToUpdate.add(
                        new OrderItem(Id = item.Order_Product__c, Quantity = item.Order_Product__r.Quantity - item.Returned_Quantity__c)
                    );
                } else {
                    itemsToDelete.add(new OrderItem(Id = item.Order_Product__c));
                }
            } else if (item.Strategy__c == 'Resend items') {
                OrderItem newItem = new OrderItem();
                newItem.Product2Id = item.Order_Product__r.Product2Id;
                newItem.OrderId = item.Order_Product__r.OrderId;
                newItem.Quantity = item.Returned_Quantity__c;
                newItem.PricebookEntryId = item.Order_Product__r.PricebookEntryId;
                newItem.UnitPrice = 0.0;
                itemsToCreate.add(newItem);
            }
        }

        List<Order> turnedOffOrders = new List<Order>();

        for (Id orderId : modifiedOrdersIds) {
            turnedOffOrders.add(new Order(Id = orderId, Status = 'Draft'));
        }

        update turnedOffOrders;

        insert itemsToCreate;
        update itemsToUpdate;
        delete itemsToDelete;

        for (Order order : turnedOffOrders) {
            order.Status = 'Activated';
        }

        update turnedOffOrders;
    }
}