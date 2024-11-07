public class AccountBuilder {
    public Account account = new Account();

    public AccountBuilder setName(String name) {
        account.Name = name;
        return this;
    }
}