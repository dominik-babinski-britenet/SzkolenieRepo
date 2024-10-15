public abstract class TestDataGenerator implements DataCreator {
    protected virtual ProductBuilder buildProduct() {
        return new ProductBuilder().setName('Product' + UUID.randomUUID());
    }

    protected virtual RestLoggerBuilder buildLogger() {
        return new RestLoggerBuilder();
    }

    protected virtual ProductLogBuilder buildProductLog(Product2 relatedProduct, RestLogger__c relatedLogger) {
        return new ProductLogBuilder().setProduct(relatedProduct).setLogger(relatedLogger);
    }

    public Product2 createProduct() {
        Product2 createdProduct = buildProduct().product;
        insert createdProduct;
        return createdProduct;
    }

    public RestLogger__c createLogger() {
        RestLogger__c createdLogger = buildLogger().logger;
        insert createdLogger;
        return createdLogger;
    }

    public Product_Log__c createProductLog(Product2 relatedProduct, RestLogger__c relatedLogger) {
        Product_Log__c createdProductLog = buildProductLog(relatedProduct, relatedLogger).productLog;
        insert createdProductLog;
        return createdProductLog;
    }
}