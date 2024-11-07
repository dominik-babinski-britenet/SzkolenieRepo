public with sharing class CaseBuilder {
    public Case createdCase = new Case();

    public CaseBuilder setSubject(String subject) {
        createdCase.Subject = subject;
        return this;
    }

    public CaseBuilder setExternalCaseId(String externalCaseId) {
        createdCase.Case_External_Id__c = externalCaseId;
        return this;
    }
}