public class OrderItemTriggerHandler extends TriggerHandler {
    public override void afterUpdate() {
        updateAccountInfo();
    }

    public override void afterInsert() {
        updateAccountInfo();
    }

    public void updateAccountInfo() {
        Set<Id> orderIds = new Set<Id>();

        for (OrderItem item : (List<OrderItem>) Trigger.new) {
            if (item.OrderId != null) {
                orderIds.add(item.OrderId);
            }
        }

        if (orderIds.isEmpty()) {
            return;
        }

        Map<Id, Order> ordersWithAccount = new Map<Id, Order>([SELECT Id, AccountId FROM Order WHERE Id IN :orderIds]);
        Set<Id> accountIds = new Set<Id>();

        for (OrderItem item : (List<OrderItem>) Trigger.new) {
            if (item.OrderId != null) {
                accountIds.add(ordersWithAccount.get(item.OrderId).AccountId);
            }
        }

        if (accountIds.isEmpty()) {
            return;
        }

        removeDiscounts(accountIds);
        addDiscounts(accountIds);
    }

    private void addDiscounts(Set<Id> accountIds) {
        List<AccountDiscount__c> discountsToInsert = new List<AccountDiscount__c>();
        List<AggregateResult> results = [
            SELECT
                Order.AccountId Account,
                COUNT_DISTINCT(OrderId) TotalOrders,
                SUM(Order_Item_Total_Value__c) TotalSpent,
                SUM(Quantity) BooksBought
            FROM OrderItem
            WHERE Order.AccountId IN :accountIds
            GROUP BY Order.AccountId
        ];

        for (Discount__c discount : [SELECT Id, Discount_Requirement__c, Discount_Requirement_Value__c, IsActive__c FROM Discount__c]) {
            if (!discount.IsActive__c) {
                continue;
            }

            DiscountRequirements requirementFunctionToUse = (DiscountRequirements) Type.forName(discount.Discount_Requirement__c)
                .newInstance();

            for (AggregateResult aggregateRecord : results) {
                if (requirementFunctionToUse.isEligibleForDiscount(aggregateRecord, (Double) discount.Discount_Requirement_Value__c)) {
                    discountsToInsert.add(
                        new AccountDiscount__c(Account__c = (Id) aggregateRecord.get('Account'), Discount__c = discount.Id)
                    );
                }
            }
        }

        insert discountsToInsert;
    }

    private void removeDiscounts(Set<Id> accountsToRemove) {
        delete [
            SELECT Id, Account__c, Discount__c
            FROM AccountDiscount__c
            WHERE Account__c IN :accountsToRemove
        ];
    }
}