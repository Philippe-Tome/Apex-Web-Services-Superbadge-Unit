@isTest
private with sharing class CredentialVerificationServiceTest {

    @TestSetup
    static void makeData() {
        Contact con = new Contact(
            FirstName = 'Contact1FirstName',
            LastName = 'Contact1'
        );

        insert con;

        Certification__c cert = new Certification__c(
            Name = 'Certification'
        );

        insert cert;

        Contact_Certification__c certRecord = new Contact_Certification__c(
            Contact__c = con.Id,
            Certification__c = cert.Id,
            Issue_Date__c = Date.today() - 7
        );

        insert certRecord;
    }

    @isTest
    private static void testVerifyCredential() {
        
        Contact con = [SELECT Id, LastName FROM Contact WHERE LastName = 'Contact1'];

        Contact_Certification__c cert = [SELECT Id, Name FROM Contact_Certification__c WHERE Contact__c =: con.Id];

        Test.startTest();
        String result = CredentialVerificationService.verifyCredential('Contact1', cert.Name);
        Test.stopTest();
    
        System.assertEquals('Valid', result);
    }

    @isTest
    private static void testVerifyCredentialNoContact() {
        
        Contact con = [SELECT Id, LastName FROM Contact WHERE LastName = 'Contact1'];

        Contact_Certification__c cert = [SELECT Id, Name FROM Contact_Certification__c WHERE Contact__c =: con.Id];

        Test.startTest();
        String result = CredentialVerificationService.verifyCredential('INVALID', cert.Name);
        Test.stopTest();
    
        System.assertEquals('No record found', result);
    }

    @isTest
    private static void testVerifyCredentialNoCertification() {
        
        Contact con = [SELECT Id, LastName FROM Contact WHERE LastName = 'Contact1'];

        Contact_Certification__c cert = [SELECT Id, Name FROM Contact_Certification__c WHERE Contact__c =: con.Id];

        Test.startTest();
        String result = CredentialVerificationService.verifyCredential('Contact1', 'INVALID');
        Test.stopTest();
    
        System.assertEquals('No record found', result);
    }

    @isTest
    private static void testVerifyCredentialExpired() {
        
        Contact con = [SELECT Id, LastName FROM Contact WHERE LastName = 'Contact1'];

        Contact_Certification__c cert = [SELECT Id, Name FROM Contact_Certification__c WHERE Contact__c =: con.Id];
        cert.isActive__c = false;

        update cert;

        Test.startTest();
        String result = CredentialVerificationService.verifyCredential('Contact1', cert.Name);
        Test.stopTest();
    
        System.assertEquals('Needs Renewal', result);
    }

}