public abstract class TestDataGenerator implements DataCreator {
    protected virtual ProductBuilder buildProduct() {
        return new ProductBuilder().setName('Product' + UUID.randomUUID());
    }

    protected virtual AccountBuilder buildAccount() {
        return new AccountBuilder().setName(UUID.randomUUID().toString());
    }

    protected virtual PricebookBuilder buildPricebook() {
        return new PricebookBuilder();
    }

    protected virtual RestLoggerBuilder buildLogger() {
        return new RestLoggerBuilder();
    }

    protected virtual ProductLogBuilder buildProductLog(Product2 relatedProduct, RestLogger__c relatedLogger) {
        return new ProductLogBuilder().setProduct(relatedProduct).setLogger(relatedLogger);
    }

    protected virtual PricebookEntryBuilder buildPricebookEntry(Product2 relatedProduct, Pricebook2 relatedPricebook) {
        return new PricebookEntryBuilder().setPricebook(relatedPricebook).setProduct(relatedProduct);
    }

    protected virtual OrderBuilder buildOrder(Pricebook2 relatedPricebook, Account account) {
        return new OrderBuilder().setPricebook(relatedPricebook).setAccount(account).setEffectiveDate(Date.today()).setStatus('Draft');
    }

    protected virtual OrderItemBuilder buildOrderItem(Order relatedOrder, Product2 relatedProduct, Integer quantity) {
        return new OrderItemBuilder().setOrder(relatedOrder).setProduct(relatedProduct).setQuantity(quantity).setUnitPrice(0.0);
    }

    protected virtual ReturnItemBuilder buildReturnItem(OrderItem orderItem) {
        return new ReturnItemBuilder().setOrderProduct(orderItem).setExternalId(UUID.randomUUID().toString());
    }

    protected virtual CaseBuilder buildCase() {
        return new CaseBuilder();
    }

    public Account createAccount() {
        Account account = buildAccount().account;
        insert account;
        return account;
    }

    public Order createOrder(Pricebook2 pricebook, Account account) {
        Order order = buildOrder(pricebook, account).order;
        insert order;
        return order;
    }

    public OrderItem createOrderItem(Order order, Product2 product, Integer quantity, PricebookEntry pricebookEntry) {
        OrderItem orderItem = buildOrderItem(order, product, quantity).setPricebookEntry(pricebookEntry).orderItem;
        insert orderItem;
        return orderItem;
    }

    public Return_Item__c createReturnItem(String caseExternalId, OrderItem orderItem, Integer quantity, String productExternalId) {
        Return_Item__c returnItem = buildReturnItem(orderItem)
            .setCaseExternalId(caseExternalId)
            .setOrderProduct(orderItem)
            .setStatus('Pending')
            .setStrategy('Return Money')
            .setQuantity(quantity)
            .setProductExternalId(productExternalId)
            .returnItem;

        insert returnItem;
        return returnItem;
    }

    public Case createCase() {
        Case createdCase = buildCase().createdCase;
        insert createdCase;
        return createdCase;
    }

    public Case createCaseWithExternalId() {
        Case createdCase = buildCase().setExternalCaseId(UUID.randomUUID().toString()).createdCase;
        insert createdCase;
        return createdCase;
    }

    public Pricebook2 createPricebook(String name) {
        Pricebook2 pricebook = buildPricebook().setName(name).pricebook;
        insert pricebook;
        return pricebook;
    }

    public PricebookEntry createPricebookEntry(Pricebook2 pricebook, Product2 buildProduct, Decimal unitPrice) {
        PricebookEntry createdPricebookEntry = buildPricebookEntry(buildProduct, pricebook).setUnitPrice(unitPrice).pricebookEntry;
        insert createdPricebookEntry;
        return createdPricebookEntry;
    }

    public Product2 createProduct() {
        Product2 createdProduct = buildProduct().product;
        insert createdProduct;
        return createdProduct;
    }

    public Product2 createExternalProduct() {
        Product2 createdProduct = buildProduct().setExternalId(UUID.randomUUID().toString()).product;
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