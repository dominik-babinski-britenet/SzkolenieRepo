public class ProductLogBuilder {
    public Product_Log__c productLog = new Product_Log__c();

    public ProductLogBuilder setProduct(Product2 product) {
        productLog.Product__c = product.Id;
        return this;
    }

    public ProductLogBuilder setLogger(RestLogger__c restLogger) {
        productLog.Rest_Logger__c = restLogger.Id;
        return this;
    }
}