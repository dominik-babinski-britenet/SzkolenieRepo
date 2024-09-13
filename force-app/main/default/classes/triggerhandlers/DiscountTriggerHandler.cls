public class DiscountTriggerHandler extends TriggerHandler {
    public override void afterInsert() {
        addDiscounts((List<Discount__c>) Trigger.new);
    }

    public override void afterUpdate() {
        List<Discount__c> deactivatedDiscounts = new List<Discount__c>();
        List<Discount__c> activatedDiscounts = new List<Discount__c>();
        List<Discount__c> updatedDiscounts = new List<Discount__c>();

        for (Discount__c discount : (List<Discount__c>) Trigger.new) {
            if (discount.IsActive__c != Trigger.oldMap.get(discount.Id).get(Discount__c.IsActive__c)) {
                if (!discount.IsActive__c) {
                    deactivatedDiscounts.add(discount);
                } else {
                    activatedDiscounts.add(discount);
                }
            } else if (
                discount.Discount_Requirement__c != Trigger.oldMap.get(discount.Id).get(Discount__c.Discount_Requirement__c) ||
                discount.Discount_Requirement_Value__c != Trigger.oldMap.get(discount.id).get(Discount__c.Discount_Requirement_Value__c)
            ) {
                updatedDiscounts.add(discount);
            }
        }

        deactivatedDiscounts.addAll(updatedDiscounts);
        activatedDiscounts.addAll(updatedDiscounts);
        removeDiscounts(deactivatedDiscounts);
        addDiscounts(activatedDiscounts);
    }

    private void addDiscounts(List<Discount__c> discountsToAdd) {
        List<AccountDiscount__c> discountsToInsert = new List<AccountDiscount__c>();
        List<Account> allAccounts = [
            SELECT Id, Orders_Placed__c, BooksSold__c, Total_Money_Spent__c
            FROM Account
        ];

        for (Discount__c discount : discountsToAdd) {
            if (!discount.IsActive__c) {
                continue;
            }

            DiscountRequirements requirementFunctionToUse = (DiscountRequirements) Type.forName(discount.Discount_Requirement__c)
                .newInstance();

            for (Account acc : allAccounts) {
                if (requirementFunctionToUse.isEligibleForDiscount(acc, (Double) discount.Discount_Requirement_Value__c)) {
                    discountsToInsert.add(new AccountDiscount__c(Account__c = acc.Id, Discount__c = discount.Id));
                }
            }
        }

        insert discountsToInsert;
    }

    public override void afterDelete() {
        removeDiscounts(Trigger.old);
    }

    private void removeDiscounts(List<Discount__c> discountsToRemove) {
        delete [
            SELECT Id, Account__c, Discount__c
            FROM AccountDiscount__c
            WHERE Discount__c IN :discountsToRemove
        ];
    }
}