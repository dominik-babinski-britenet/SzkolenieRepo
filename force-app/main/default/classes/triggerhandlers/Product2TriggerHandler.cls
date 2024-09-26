public with sharing class Product2TriggerHandler extends TriggerHandler {
    public override void beforeInsert() {
        for (Product2 product : (List<Product2>) Trigger.new) {
            if (product.External__c) {
                continue;
            }

            product.ProductExternalId__c = UUID.randomUUID().toString();
        }
    }

    public override void afterInsert() {
        ProductSynchronize.upsertProducts(convertToExternal((List<Product2>) Trigger.new));
    }

    public override void beforeUpdate() {
        Boolean allowSyncing = Allow_Sync__c.getOrgDefaults().Active__c;

        for (Product2 product : (List<Product2>) Trigger.new) {
            if (!allowSyncing && product.External__c) {
                product.addError('You cannot update external products');
            }
        }
    }

    public override void afterUpdate() {
        ProductSynchronize.upsertProducts(convertToExternal((List<Product2>) Trigger.new));
    }

    public override void beforeDelete() {
        Boolean allowSyncing = Allow_Sync__c.getOrgDefaults().Active__c;

        for (Product2 product : (List<Product2>) Trigger.old) {
            if (!allowSyncing && product.External__c) {
                product.addError('You cannot delete external products');
            }
        }
    }

    public override void afterDelete() {
        ProductSynchronize.deleteProducts(convertToExternal((List<Product2>) Trigger.old));
    }

    private List<Product2> convertToExternal(List<Product2> productList) {
        List<Product2> result = new List<Product2>();

        for (Product2 product : productList) {
            Product2 insertedProduct = product.clone();
            insertedProduct.External__c = true;
            result.add(insertedProduct);
        }

        return result;
    }
}