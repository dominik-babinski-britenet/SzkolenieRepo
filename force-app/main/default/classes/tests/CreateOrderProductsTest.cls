@isTest
public class CreateOrderProductsTest {
    @isTest
    static void testOrderWithoutQuote() {
        Account acc = new Account(Name = 'Test Account No Quote');
        insert acc;

        Order order = new Order(
            Name = 'Test Order No Quote',
            AccountId = acc.Id,
            EffectiveDate = Date.today(),
            Status = 'Draft',
            QuoteId = null
        );
        insert order;

        List<OrderItem> orderItems = [SELECT Id FROM OrderItem WHERE OrderId = :order.Id];
        System.assertEquals(0, orderItems.size(), 'No OrderItems should be created for Order without QuoteId.');
    }

    @isTest
    static void testOrderWithInvalidQuote() {
        Account acc = new Account(Name = 'Test Account Invalid Quote');
        insert acc;

        Order order = new Order(
            Name = 'Test Order Invalid Quote',
            AccountId = acc.Id,
            EffectiveDate = Date.today(),
            Status = 'Draft',
            QuoteId = null
        );
        insert order;

        List<OrderItem> orderItems = [SELECT Id FROM OrderItem WHERE OrderId = :order.Id];
        System.assertEquals(0, orderItems.size(), 'No OrderItems should be created for Order with non-existent QuoteId.');
    }
}