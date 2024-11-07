public class CaseCreatedEventQueueable implements Queueable, Database.AllowsCallouts {
    String caseId;

    public CaseCreatedEventQueueable(String caseId) {
        this.caseId = caseId;
    }

    public void execute(QueueableContext context) {
        HttpRequest httpRequest = new HttpRequest();
        httpRequest.setMethod('POST');
        httpRequest.setEndpoint('callout:SynchronizeProducts/services/data/v61.0/sobjects/Case_Created__e');

        Case_Created__e event = new Case_Created__e();
        event.Case_Identificator__c = caseId;
        String body = JSON.serialize(event);
        httpRequest.setBody(body);

        Http http = new Http();

        try {
            HttpResponse response = http.send(httpRequest);
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
    }
}