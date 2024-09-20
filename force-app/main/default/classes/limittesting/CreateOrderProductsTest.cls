@isTest
public class CreateOrderProductsTest {

    @isTest
    static void testOrderWithoutQuote() {
        // Create test data
        Account acc = new Account(Name = 'Test Account No Quote');
        insert acc;

        // Create an Order without QuoteId
        Order order = new Order(
                Name = 'Test Order No Quote',
                AccountId = acc.Id,
                EffectiveDate = Date.today(),
                Status = 'Draft',
                QuoteId = null
        );
        insert order;

        // Verify no OrderItems are created
        List<OrderItem> orderItems = [SELECT Id FROM OrderItem WHERE OrderId = :order.Id];
        System.assertEquals(0, orderItems.size(), 'No OrderItems should be created for Order without QuoteId.');
    }

    @isTest
    static void testOrderWithInvalidQuote() {
        // Create test data
        Account acc = new Account(Name = 'Test Account Invalid Quote');
        insert acc;

        // Create an Order with a non-existent QuoteId
        Order order = new Order(
                Name = 'Test Order Invalid Quote',
                AccountId = acc.Id,
                EffectiveDate = Date.today(),
                Status = 'Draft',
                QuoteId = null// Non-existent QuoteId
        );
        insert order;

        // Verify no OrderItems are created
        List<OrderItem> orderItems = [SELECT Id FROM OrderItem WHERE OrderId = :order.Id];
        System.assertEquals(0, orderItems.size(), 'No OrderItems should be created for Order with non-existent QuoteId.');
    }
}