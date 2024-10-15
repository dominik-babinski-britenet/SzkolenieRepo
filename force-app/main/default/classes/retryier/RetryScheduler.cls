global class RetryScheduler implements Schedulable {
    global void execute(SchedulableContext context) {
        Database.executeBatch(new BatchedRetry(), 100);
    }
}