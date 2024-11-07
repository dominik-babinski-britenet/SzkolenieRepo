public class ReturnItemBuilder {
    public Return_Item__c returnItem = new Return_Item__c();

    public ReturnItemBuilder setQuantity(Integer quantity) {
        returnItem.Returned_Quantity__c = quantity;
        return this;
    }

    public ReturnItemBuilder setOrderProduct(OrderItem relatedOrderItem) {
        returnItem.Order_Product__c = relatedOrderItem.Id;
        return this;
    }

    public ReturnItemBuilder setStatus(String status) {
        returnItem.Status__c = status;
        return this;
    }

    public ReturnItemBuilder setStrategy(String strategy) {
        returnItem.Strategy__c = strategy;
        return this;
    }

    public ReturnItemBuilder setCaseExternalId(String externalId) {
        returnItem.Case_External_Id__c = externalId;
        return this;
    }

    public ReturnItemBuilder setExternalId(String externalId) {
        returnItem.External_Id__c = externalId;
        return this;
    }

    public ReturnItemBuilder setProductExternalId(String productExternalId) {
        returnItem.Product_External_Id__c = productExternalId;
        return this;
    }
}