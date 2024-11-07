public class PricebookEntryBuilder {
    public PricebookEntry pricebookEntry = new PricebookEntry();

    public PricebookEntryBuilder setPricebook(Pricebook2 pricebook) {
        this.pricebookEntry.Pricebook2Id = pricebook.Id;
        return this;
    }

    public PricebookEntryBuilder setProduct(Product2 product) {
        this.pricebookEntry.Product2Id = product.Id;
        return this;
    }

    public PricebookEntryBuilder setUnitPrice(Decimal unitPrice) {
        this.pricebookEntry.UnitPrice = unitPrice;
        return this;
    }
}