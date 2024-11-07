public class OrderItemBuilder {
    public OrderItem orderItem = new OrderItem();

    public OrderItemBuilder setQuantity(Integer quantity) {
        orderItem.Quantity = quantity;
        return this;
    }

    public OrderItemBuilder setProduct(Product2 product) {
        orderItem.Product2Id = product.Id;
        return this;
    }

    public OrderItemBuilder setOrder(Order order) {
        orderItem.OrderId = order.Id;
        return this;
    }

    public OrderItemBuilder setUnitPrice(Decimal unitPrice) {
        orderItem.UnitPrice = unitPrice;
        return this;
    }

    public OrderItemBuilder setPricebookEntry(PricebookEntry pricebookEntry) {
        orderItem.PricebookEntryId = pricebookEntry.Id;
        return this;
    }
}