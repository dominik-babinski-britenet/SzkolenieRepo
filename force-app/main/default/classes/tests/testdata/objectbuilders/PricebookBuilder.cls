public class PricebookBuilder {
    public Pricebook2 pricebook = new Pricebook2();

    public PricebookBuilder setActive(Boolean active) {
        this.pricebook.IsActive = active;
        return this;
    }

    public PricebookBuilder setName(String name) {
        this.pricebook.Name = name;
        return this;
    }
}