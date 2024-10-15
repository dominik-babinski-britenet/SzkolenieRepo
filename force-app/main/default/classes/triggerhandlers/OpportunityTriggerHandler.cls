public class OpportunityTriggerHandler extends TriggerHandler {
    public override void afterUpdate() {
        List<Order> ordersToInsert = new List<Order>();
        Set<Id> opportunityIds = new Set<Id>();

        for (Opportunity opp : (List<Opportunity>) Trigger.new) {
            if (opp.StageName == 'Closed Won' && ((Opportunity) Trigger.oldMap.get(opp.Id)).StageName != 'Closed Won') {
                opportunityIds.add(opp.Id);
            }
        }

        if (opportunityIds.isEmpty()) {
            return;
        }

        List<Quote> approvedQuotes = [
            SELECT Id, Name, OpportunityId, Pricebook2Id
            FROM Quote
            WHERE OpportunityId IN :opportunityIds AND Status = 'Accepted'
        ];

        Map<Id, List<Quote>> opportunityToQuotesMap = new Map<Id, List<Quote>>();

        for (Quote quote : approvedQuotes) {
            if (!opportunityToQuotesMap.containsKey(quote.OpportunityId)) {
                opportunityToQuotesMap.put(quote.OpportunityId, new List<Quote>());
            }
            opportunityToQuotesMap.get(quote.OpportunityId).add(quote);
        }

        for (Opportunity opp : (List<Opportunity>) Trigger.new) {
            if (opportunityToQuotesMap.containsKey(opp.Id)) {
                for (Quote quote : opportunityToQuotesMap.get(opp.Id)) {
                    Order newOrder = new Order();
                    newOrder.OpportunityId = opp.Id;
                    newOrder.AccountId = opp.AccountId;
                    newOrder.EffectiveDate = Date.today();
                    newOrder.Status = 'Draft';
                    newOrder.QuoteId = quote.Id;
                    newOrder.Name = quote.Name;
                    newOrder.Pricebook2Id = quote.Pricebook2Id;

                    ordersToInsert.add(newOrder);
                }
            }
        }

        insert ordersToInsert;
    }
}