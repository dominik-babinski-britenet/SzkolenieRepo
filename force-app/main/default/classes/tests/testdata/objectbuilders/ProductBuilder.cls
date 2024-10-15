public class ProductBuilder {
    public Product2 product = new Product2();

    public ProductBuilder setName(String name) {
        product.Name = name;
        return this;
    }
}