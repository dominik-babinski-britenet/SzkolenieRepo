@isTest
private class ProductSyncTest {
    @TestSetup
    static void createData() {
        new DataGenerator().createData();
    }

    @isTest
    static void testRestUpsert() {
        Product2 product = [SELECT Id, ProductExternalId__c FROM Product2 WHERE External__c = FALSE];

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
        Product2 productWithExternalId = [SELECT Id, ProductExternalId__c FROM Product2 WHERE External__c = FALSE];
        Assert.areNotEqual(null, productWithExternalId.ProductExternalId__c);
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
        Exception exception;
        Assert.areEqual(false, SyncCalloutMock.wasExecuted);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SyncCalloutMock(LogUtils.SUCCESS));
        try {
            Product2 product = new Product2(Name = 'Test', External__c = true);
            insert product;
        } catch (Exception e) {
            System.debug(e); // TODO: Compare to label of an error
        } finally {
            Test.stopTest();
            Assert.areEqual(false, SyncCalloutMock.wasExecuted);
        }
    }

    @isTest
    static void ensureExternalRecordsCantBeUpdated() {
        Test.setMock(HttpCalloutMock.class, new SyncCalloutMock(LogUtils.SUCCESS));
        Test.startTest();
        Product2 product = [SELECT Id, ProductExternalId__c FROM Product2 WHERE External__c = TRUE];
        String nameToSet = 'Test 123';
        product.Name = nameToSet;

        try {
            update product;
        } catch (DmlException e) {
            System.debug(e.toString());
        } finally {
            Test.stopTest();
            Product2 updatedProduct = [SELECT Name FROM Product2 WHERE External__c = TRUE];
            Assert.areNotEqual(nameToSet, updatedProduct.Name);
        }
    }

    @isTest
    static void ensureNonExternalRecordsCanBeUpdated() {
        Test.setMock(HttpCalloutMock.class, new SyncCalloutMock(LogUtils.SUCCESS));
        Test.startTest();
        Product2 product = [SELECT Id, ProductExternalId__c FROM Product2 WHERE External__c = FALSE];
        String nameToSet = 'Test 123';
        product.Name = nameToSet;
        update product;
        Test.stopTest();
        Assert.areEqual(nameToSet, product.Name);
    }

    @isTest
    static void ensureExternalRecordsCantBeDeleted() {
        Test.setMock(HttpCalloutMock.class, new SyncCalloutMock(LogUtils.SUCCESS));
        Test.startTest();
        Product2 product = [SELECT Id, ProductExternalId__c FROM Product2 WHERE External__c = TRUE];

        try {
            delete product;
        } catch (DmlException e) {
            System.debug(e.toString());
        } finally {
            Test.stopTest();
            Product2 updatedProduct = [SELECT Name FROM Product2 WHERE External__c = TRUE];
            Assert.areNotEqual(null, updatedProduct);
        }
    }

    @isTest
    static void ensureNonExternalRecordsDeletionResultsInSync() {
        Product2 product = [SELECT Id, ProductExternalId__c FROM Product2 WHERE External__c = FALSE];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SyncCalloutMock(LogUtils.SUCCESS));
        delete product;
        Test.stopTest();

        Assert.areEqual(true, SyncCalloutMock.wasExecuted);
    }

    class DataGenerator extends TestDataGenerator {
        public void createData() {
            createProduct();
            ProductRestService.IS_SYNCING = true;
            Product2 externalProduct = createProduct();
            externalProduct.External__c = true;
            update externalProduct;
            ProductRestService.IS_SYNCING = false;
        }
    }
}