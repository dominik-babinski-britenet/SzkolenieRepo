public with sharing class Product2TriggerHandler extends TriggerHandler {
    public override void afterUpdate() {
        if (ProductSynchronize.isFromRest == true) {
            return;
        }

        ProductSynchronize.upsertProducts((List<Product2>) Trigger.new);
    }

    public override void afterInsert() {
        //if trigger is external then do nothing

        //if trigger is not external then assign external id and execute below
        ProductSynchronize.upsertProducts((List<Product2>) Trigger.new);
    }

    public override void afterDelete() {
        //
        ProductSynchronize.deleteProducts((List<Product2>) Trigger.old);
    }
}