public with sharing class BooksSoldDiscountRequirements implements DiscountRequirements {
    public Boolean isEligibleForDiscount(Account account, Double value) {
        return account.BooksSold__c > value;
    }
}