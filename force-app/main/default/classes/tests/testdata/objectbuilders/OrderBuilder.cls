public class OrderBuilder {
    public Order order = new Order();

    public OrderBuilder setPricebook(Pricebook2 pricebook) {
        order.Pricebook2Id = pricebook.Id;
        return this;
    }

    public OrderBuilder setAccount(Account account) {
        order.AccountId = account.Id;
        return this;
    }

    public OrderBuilder setEffectiveDate(Date effectiveDate) {
        order.EffectiveDate = effectiveDate;
        return this;
    }

    public OrderBuilder setStatus(String status) {
        order.Status = status;
        return this;
    }
}