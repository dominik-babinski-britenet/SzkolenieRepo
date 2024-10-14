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
        if (!ProductRestService.IS_SYNCING) {
            System.enqueueJob(new QueueableProductSync(convertToExternal((List<Product2>) Trigger.new), 'POST'));
        }
    }

    public override void beforeUpdate() {
        for (Product2 product : (List<Product2>) Trigger.new) {
            if (!ProductRestService.IS_SYNCING && product.External__c) {
                product.addError('You cannot update external products');
            }
        }
    }

    public override void afterUpdate() {
        if (!ProductRestService.IS_SYNCING) {
            System.enqueueJob(new QueueableProductSync(convertToExternal((List<Product2>) Trigger.new), 'POST'));
        }
    }

    public override void beforeDelete() {
        for (Product2 product : (List<Product2>) Trigger.old) {
            if (!ProductRestService.IS_SYNCING && product.External__c) {
                product.addError('You cannot delete external products');
            }
        }
    }

    public override void afterDelete() {
        if (!ProductRestService.IS_SYNCING) {
            System.enqueueJob(new QueueableProductSync(convertToExternal((List<Product2>) Trigger.old), 'DELETE'));
        }
    }

    private List<Product2> convertToExternal(List<Product2> productList) {
        List<Product2> result = new List<Product2>();

        for (Product2 product : productList) {
            Product2 insertedProduct = product.clone();
            insertedProduct.Id = product.Id;
            insertedProduct.External__c = true;
            result.add(insertedProduct);
        }

        return result;
    }
}