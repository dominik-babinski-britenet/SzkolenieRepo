trigger CreateOrderOnOpportunityClose on Opportunity (after update) {

    List<Order> ordersToInsert = new List<Order>();
    Set<Id> opportunityIds = new Set<Id>();

    for (Opportunity opp : Trigger.new) {
        if (opp.StageName == 'Closed Won' && Trigger.oldMap.get(opp.Id).StageName != 'Closed Won') {
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

    for (Opportunity opp : Trigger.new) {
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

    //CustomNotificationType notificationType =
    //[SELECT Id, DeveloperName
    //FROM CustomNotificationType
    //WHERE DeveloperName='new_order_was_created'];
//
    //Messaging.CustomNotification notification = new Messaging.CustomNotification();
    //notification.setTitle('Apex Custom Notification');
    //notification.setBody('The notifications are coming from INSIDE the Apex!');
//
    //notification.setNotificationTypeId(notificationType.Id);
    //notification.setTargetId(Trigger.new[0].Id);
//
    //notification.send(new Set<String>{Trigger.new[0].LastModifiedById});

    insert ordersToInsert;
}