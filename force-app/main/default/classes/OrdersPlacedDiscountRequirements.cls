public with sharing class OrdersPlacedDiscountRequirements implements DiscountRequirements {
    public Boolean isEligibleForDiscount(Account account, Double value) {
        return account.Orders_Placed__c > value;
    }
}