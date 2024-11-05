public class ProductBuilder {
    public Product2 product = new Product2();

    public ProductBuilder setName(String name) {
        product.Name = name;
        return this;
    }

    public ProductBuilder setExternalId(String externalId) {
        product.ProductExternalId__c = externalId;
        return this;
    }
}