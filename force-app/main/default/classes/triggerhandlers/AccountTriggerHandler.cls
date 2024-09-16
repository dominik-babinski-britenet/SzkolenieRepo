public with sharing class AccountTriggerHandler extends TriggerHandler {
    public override void afterUpdate() {
        //TODO: Filter only those accounts which were actually changed

        List<Discount__c> allDiscounts = [SELECT Id, Discount_Requirement__c, Discount_Requirement_Value__c FROM Discount__c];
        List<AccountDiscount__c> discountsToRemove = [SELECT Id FROM AccountDiscount__c WHERE Account__c IN :Trigger.new];
        List<AccountDiscount__c> discountsToAdd = new List<AccountDiscount__c>();

        for (Account account : (List<Account>) Trigger.new) {
            for (Discount__c discount : allDiscounts) {
                DiscountRequirements requirementFunctionToUse = (DiscountRequirements) Type.forName(discount.Discount_Requirement__c)
                    .newInstance();

                if (requirementFunctionToUse.isEligibleForDiscount(account, (Double) discount.Discount_Requirement_Value__c)) {
                    discountsToAdd.add(new AccountDiscount__c(Account__c = account.Id, Discount__c = discount.Id));
                }
            }
        }

        delete discountsToRemove;
        insert discountsToAdd;
    }
}