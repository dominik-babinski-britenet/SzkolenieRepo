public with sharing class FutureProcess {
    @Future
    public static void process() {
        List<Account> accounts = [SELECT Name FROM Account];
    }
}