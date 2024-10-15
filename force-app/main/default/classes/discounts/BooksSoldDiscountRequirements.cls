public with sharing class BooksSoldDiscountRequirements implements DiscountRequirements {
    public Boolean isEligibleForDiscount(AggregateResult account, Double value) {
        return (Double) account.get('BooksBought') > value;
    }
}