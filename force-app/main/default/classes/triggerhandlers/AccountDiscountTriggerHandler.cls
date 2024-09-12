public with sharing class AccountDiscountTriggerHandler extends TriggerHandler {
    public override void afterInsert() {
        updateAllQuoteDiscounts();
    }

    public override void afterDelete() {
        updateAllQuoteDiscounts();
    }

    private void updateAllQuoteDiscounts() {
    }
}