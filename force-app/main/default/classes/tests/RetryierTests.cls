@isTest
private class RetryierTests {
    @TestSetup
    static void prepareData() {
        new DataGenerator().createData();
    }

    @isTest
    static void testSchedulable() {
        Test.setMock(HttpCalloutMock.class, new SyncCalloutMock(LogUtils.SUCCESS));

        Test.startTest();
        RetryScheduler scheduler = new RetryScheduler();
        scheduler.execute(null);
        Test.stopTest();
        RestLogger__c logger = [SELECT Id, Method__c, Status__c, Retries__c FROM RestLogger__c LIMIT 1];
        System.assertEquals(logger.Retries__c, 1);
        System.assertEquals(logger.Status__c, LogUtils.SUCCESS);
    }

    @isTest
    static void testBatchable() {
        Test.setMock(HttpCalloutMock.class, new SyncCalloutMock(LogUtils.SUCCESS));

        Test.startTest();
        BatchedRetry retryBatch = new BatchedRetry();
        Database.executeBatch(retryBatch, 200);
        Test.stopTest();
        RestLogger__c logger = [SELECT Id, Method__c, Status__c, Retries__c FROM RestLogger__c LIMIT 1];
        System.assertEquals(logger.Retries__c, 1);
        System.assertEquals(logger.Status__c, LogUtils.SUCCESS);
    }

    @isTest
    static void testRetryCountAndStatusOnSuccess() {
        Test.setMock(HttpCalloutMock.class, new SyncCalloutMock(LogUtils.SUCCESS));

        Test.startTest();
        RestLogger__c logger = [SELECT Id, Method__c, Status__c, Retries__c FROM RestLogger__c LIMIT 1];
        QueuableProductSyncRetry syncRetry = new QueuableProductSyncRetry(logger);
        syncRetry.execute();
        Test.stopTest();
        System.assertEquals(logger.Retries__c, 1);
        System.assertEquals(logger.Status__c, LogUtils.SUCCESS);
    }

    @isTest
    static void testRetryCountAndStatusOnFailure() {
        Test.setMock(HttpCalloutMock.class, new SyncCalloutMock(LogUtils.FAILED));

        Test.startTest();
        RestLogger__c logger = [SELECT Id, Method__c, Status__c, Retries__c FROM RestLogger__c LIMIT 1];
        QueuableProductSyncRetry syncRetry = new QueuableProductSyncRetry(logger);
        syncRetry.execute();
        Test.stopTest();
        System.assertEquals(logger.Retries__c, 1);
        System.assertEquals(logger.Status__c, LogUtils.FAILED);
    }

    @isTest
    static void testRetryCountAndStatusOnConnectionError() {
        Test.setMock(HttpCalloutMock.class, new SyncCalloutMock(LogUtils.CONNECTION_ERROR));

        Test.startTest();
        RestLogger__c logger = [SELECT Id, Method__c, Status__c, Retries__c FROM RestLogger__c LIMIT 1];
        QueuableProductSyncRetry syncRetry = new QueuableProductSyncRetry(logger);
        syncRetry.execute();
        Test.stopTest();
        System.assertEquals(logger.Retries__c, 1);
        System.assertEquals(logger.Status__c, LogUtils.CONNECTION_ERROR);
    }

    class DataGenerator extends TestDataGenerator {
        public void createData() {
            Product2 firstProduct = createProduct();
            Product2 secondProduct = createProduct();

            RestLogger__c logger = createLogger();
            logger.Method__c = 'POST';
            logger.Status__c = LogUtils.FAILED;
            logger.Retries__c = 0;
            upsert logger;

            createProductLog(firstProduct, logger);
            createProductLog(secondProduct, logger);
        }
    }
}