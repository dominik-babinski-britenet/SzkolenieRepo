@isTest
public class LeadTriggerHandlerTest {
    @testSetup
    static void setupTestData() {
        RecordType partnerRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Lead' AND DeveloperName = 'Partner' LIMIT 1];

        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        Lead partnerLead = new Lead(
            FirstName = 'Partner',
            LastName = 'Lead',
            Company = 'Test Partner',
            Email = 'samplemail@supermail.com',
            RecordTypeId = partnerRecordType.Id
        );
        Lead customerLead = new Lead(
            FirstName = 'Customer',
            LastName = 'Lead',
            Company = 'Test Customer',
            Email = 'othermail@supermail.com'
        );
        insert new List<Lead>{ partnerLead, customerLead };

        Database.LeadConvert lcPartner = new Database.LeadConvert();
        lcPartner.setLeadId(partnerLead.Id);
        lcPartner.setConvertedStatus('Closed - Converted');
        lcPartner.setAccountId(testAccount.Id);
        lcPartner.setDoNotCreateOpportunity(true);

        Database.LeadConvert lcCustomer = new Database.LeadConvert();
        lcCustomer.setLeadId(customerLead.Id);
        lcCustomer.setConvertedStatus('Closed - Converted');
        lcCustomer.setAccountId(testAccount.Id);
        lcCustomer.setDoNotCreateOpportunity(true);

        List<Database.LeadConvert> leadConversions = new List<Database.LeadConvert>{ lcPartner, lcCustomer };
        Database.convertLead(leadConversions, false);
    }
}