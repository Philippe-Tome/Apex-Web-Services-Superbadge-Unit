global with sharing class CredentialVerificationService {
    webservice static String verifyCredential(String lastName, String certName) {
        List<Contact> contacts = [SELECT Id, LastName FROM Contact WHERE LastName = :lastName];

        List<Contact_Certification__c> certificates = [SELECT Id, isActive__c, Name FROM Contact_Certification__c WHERE Name = :certName];
        
        if (contacts.isEmpty() || certificates.isEmpty()) {
            return 'No record found';
        }

        if (certificates[0].isActive__c) {
            return 'Valid';
        }

        return 'Needs Renewal';
    }
}