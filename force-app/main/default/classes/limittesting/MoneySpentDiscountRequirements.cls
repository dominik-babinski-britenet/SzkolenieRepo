public with sharing class MoneySpentDiscountRequirements implements DiscountRequirements{
    public Boolean isEligibleForDiscount(Account account, Double value) {
        return account.Total_Money_Spent__c > value;
    }
}