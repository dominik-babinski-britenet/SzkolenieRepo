public with sharing class MoneySpentDiscountRequirements implements DiscountRequirements {
    public Boolean isEligibleForDiscount(AggregateResult account, Double value) {
        return (Double) account.get('TotalSpent') > value;
    }
}