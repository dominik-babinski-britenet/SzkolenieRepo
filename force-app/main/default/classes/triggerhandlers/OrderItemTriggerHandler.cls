public class OrderItemTriggerHandler extends TriggerHandler {
    public override void afterUpdate() {
        updateAccountInfo();
    }

    public override void afterInsert() {
        updateAccountInfo();
    }

    public void updateAccountInfo() {
        Set<Id> accountIds = new Set<Id>();

        for (OrderItem item : (List<OrderItem>) Trigger.new) {
            if (item.Order.AccountId != null) {
                accountIds.add(item.Order.AccountId);
            }
        }

        if (accountIds.isEmpty()) {
            return;
        }

        List<AggregateResult> results = [
            SELECT AccountId, SUM(TotalAmount) totalMoneySpent, COUNT(Id) ordersPlaced, SUM(Order_Items__c) totalBooksSold
            FROM Order
            WHERE AccountId IN :accountIds
            GROUP BY AccountId
        ];

        List<Account> accountsToUpdate = new List<Account>();

        for (AggregateResult result : results) {
            Account acc = new Account(
                Id = (Id) result.get('AccountId'),
                Total_Money_Spent__c = (Decimal) result.get('totalMoneySpent'),
                Orders_Placed__c = (Integer) result.get('ordersPlaced'),
                BooksSold__c = (Decimal) result.get('totalBooksSold')
            );

            accountsToUpdate.add(acc);
        }

        update accountsToUpdate;
    }
}