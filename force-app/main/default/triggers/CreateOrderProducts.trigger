trigger CreateOrderProducts on Order (after insert) {

    Set<Id> quoteIds = new Set<Id>();

    for (Order ord : Trigger.new) {
        if (ord.QuoteId != null) {
            quoteIds.add(ord.QuoteId);
        }
    }

    Map<Id, List<QuoteLineItem>> quoteToLineItemsMap = new Map<Id, List<QuoteLineItem>>();

    if (!quoteIds.isEmpty()) {
        for (QuoteLineItem item : [
                SELECT Id, QuoteId, Product2Id, Quantity, UnitPrice, PricebookEntryId
                FROM QuoteLineItem
                WHERE QuoteId IN :quoteIds
        ]) {
            if (!quoteToLineItemsMap.containsKey(item.QuoteId)) {
                quoteToLineItemsMap.put(item.QuoteId, new List<QuoteLineItem>());
            }
            quoteToLineItemsMap.get(item.QuoteId).add(item);
        }
    }

    List<OrderItem> orderItemsToInsert = new List<OrderItem>();

    for (Order ord : Trigger.new) {
        if (ord.QuoteId != null && quoteToLineItemsMap.containsKey(ord.QuoteId)) {
            for (QuoteLineItem item : quoteToLineItemsMap.get(ord.QuoteId)) {
                OrderItem createdItem = new OrderItem();
                createdItem.UnitPrice = item.UnitPrice;
                createdItem.Quantity = item.Quantity;
                createdItem.Product2Id = item.Product2Id;
                createdItem.OrderId = ord.Id;
                createdItem.PricebookEntryId = item.PricebookEntryId;
                createdItem.QuoteLineItemId = item.Id;
                createdItem.QuoteLineItem = item;
                orderItemsToInsert.add(createdItem);
            }
        }
    }


    insert orderItemsToInsert;

}