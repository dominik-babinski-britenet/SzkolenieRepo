public with sharing class OrdersPlacedDiscountRequirements implements DiscountRequirements {
    public Boolean isEligibleForDiscount(AggregateResult account, Double value) {
        return (Double) account.get('TotalOrders') > value;
    }
}