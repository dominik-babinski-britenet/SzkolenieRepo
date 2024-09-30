public interface DiscountRequirements {
    Boolean isEligibleForDiscount(AggregateResult account, Double value);
}