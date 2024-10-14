@isTest
private class ProductSyncTest {
    @isTest
    static void testRestUpsert() {
        Product2 product = new Product2(Name = 'Test', ProductExternalId__c = 'abc');

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/productsync';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serialize(new List<Product2>{ product }));

        RestContext.request = req;
        RestContext.response = res;

        ProductRestService.handlePostRequest();
        String stringifiedJson = RestContext.response.responseBody.toString();
        ProductRestService.DataModel dataModel = (ProductRestService.DataModel) JSON.deserialize(
            stringifiedJson,
            ProductRestService.DataModel.class
        );

        Assert.areEqual(LogUtils.SUCCESS, dataModel.status);
    }

    @isTest
    static void ensureNewProductsGetExternalId() {
        Product2 product = new Product2(Name = 'Test');
        insert product;

        Product2 productWithExternalId = [SELECT Id, ProductExternalId__c FROM Product2 WHERE Id = :product.Id];

        Assert.areNotEqual(null, productWithExternalId.ProductExternalId__c);
    }

    @isTest
    static void ensureNewExternalProductsDontGetTheirExternalIdChanged() {
        Product2 product = new Product2(Name = 'Test', External__c = true, ProductExternalId__c = '123');
        insert product;
        Assert.areEqual(product.ProductExternalId__c, '123');
    }

    @isTest
    static void ensureNewSyncRequestOnNonExternalProductInserted() {
        Assert.areEqual(false, SyncCalloutMock.wasExecuted);
        Test.setMock(HttpCalloutMock.class, new SyncCalloutMock(LogUtils.SUCCESS));
        Test.startTest();
        Product2 product = new Product2(Name = 'Test');
        insert product;
        Test.stopTest();
        Assert.areEqual(true, SyncCalloutMock.wasExecuted);
    }

    @isTest
    static void ensureNoSyncRequestOnExternalProductInserted() {
        Assert.areEqual(false, SyncCalloutMock.wasExecuted);
        Test.startTest();
        Product2 product = new Product2(Name = 'Test', External__c = true);
        insert product;

        Test.setMock(HttpCalloutMock.class, new SyncCalloutMock(LogUtils.SUCCESS));
        product.Name = '123';
        try {
            update product;
        } catch (Exception e) {
            System.debug(e.getMessage());
        } finally {
            Test.stopTest();
            Assert.areEqual(false, SyncCalloutMock.wasExecuted);
        }
    }

    @isTest
    static void ensureExternalRecordsCantBeUpdated() {
        Test.setMock(HttpCalloutMock.class, new SyncCalloutMock(LogUtils.SUCCESS));
        Test.startTest();
        Product2 product = new Product2(Name = 'Test', External__c = true);
        insert product;
        product.Name = 'Other test';

        try {
            update product;
        } catch (DmlException e) {
            System.debug(e.toString());
        } finally {
            Test.stopTest();
            Product2 updatedProduct = [SELECT Name FROM Product2];
            Assert.areEqual('Test', updatedProduct.Name);
        }
    }

    @isTest
    static void ensureNonExternalRecordsUpdatedResultsInSync() {
        Test.setMock(HttpCalloutMock.class, new SyncCalloutMock(LogUtils.SUCCESS));
        Test.startTest();
        Product2 product = new Product2(Name = 'Test');
        insert product;
        product.Name = 'Other test';
        update product;
        Test.stopTest();
        Assert.areEqual('Other test', product.Name);
    }

    @isTest
    static void ensureExternalRecordsCantBeDeleted() {
        Test.setMock(HttpCalloutMock.class, new SyncCalloutMock(LogUtils.SUCCESS));
        Test.startTest();
        Product2 product = new Product2(Name = 'Test', External__c = true);
        insert product;

        try {
            delete product;
        } catch (DmlException e) {
            System.debug(e.toString());
        } finally {
            Test.stopTest();
            Product2 updatedProduct = [SELECT Name FROM Product2];
            Assert.areNotEqual(null, updatedProduct);
        }
    }

    @isTest
    static void ensureNonExternalRecordsDeletionResultsInSync() {
        Product2 product = new Product2(Name = 'Test');
        Test.startTest();
        insert product;

        Test.setMock(HttpCalloutMock.class, new SyncCalloutMock(LogUtils.SUCCESS));
        delete product;
        Test.stopTest();

        Assert.areEqual(true, SyncCalloutMock.wasExecuted);
    }

    @isTest
    static void ensureRecordDeletionResultsInLogDeletion() {
        Product2 product = new Product2(Name = 'Test');
        insert product;
        RestLogger__c logger = new RestLogger__c();
        insert logger;
        Product_Log__c productLog = new Product_Log__c(Product__c = product.Id, Rest_Logger__c = logger.Id);
        insert productLog;

        List<Product_Log__c> logs = [SELECT Id FROM Product_Log__c WHERE Product__c = :product.Id];
        Assert.areEqual(1, logs.size());
        delete product;
        logs = [SELECT Id FROM Product_Log__c WHERE Product__c = :product.Id];
        Assert.areEqual(0, logs.size());
    }
}