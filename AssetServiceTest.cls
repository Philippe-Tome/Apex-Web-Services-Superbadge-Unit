@isTest
private with sharing class AssetServiceTest {

    @TestSetup
    static void makeData(){
        List<Asset> assets = new List<Asset>();
        List<Insurance__c> insurances = new List<Insurance__c>();

        Account acc = new Account(
            Name = 'TestAccount'
        );

        insert acc;

        Contact con = new Contact(
            FirstName = 'Test',
            LastName = 'Test',
            AccountId = acc.Id
        );

        insert con;

        Asset asset1 = new Asset(
            Name = 'AssetNoClaimWithInsurance', 
            Asset_Identifier__c = '1234',
            AccountId = acc.Id,
            ContactId = con.Id
        );

        assets.add(asset1);

        Asset asset2 = new Asset(
            Name = 'AssetWithClaimWithInsurance', 
            Asset_Identifier__c = '5678',
            AccountId = acc.Id,
            ContactId = con.Id
        );

        assets.add(asset2);

        Asset asset3 = new Asset(
            Name = 'AssetNoClaimWithoutInsurance', 
            Asset_Identifier__c = '9012',
            AccountId = acc.Id,
            ContactId = con.Id
        );

        assets.add(asset3);

        insert assets;

        Insurance__c insuranceAsset1 = new Insurance__c(
            Asset__c = asset1.Id,
            Coverage__c = 'Comprehensive',
            Active__c = true
        );

        insurances.add(insuranceAsset1);

        Insurance__c insuranceAsset2 = new Insurance__c(
            Asset__c = asset2.Id,
            Coverage__c = 'Comprehensive',
            Active__c = true
        );

        insurances.add(insuranceAsset2);

        insert insurances;
    }

    @isTest
    private static void testReportLostDeviceNoClaimWithInsurance() {
                
        Test.startTest();
        String result = AssetService.reportLostDevice('1234');
        Test.stopTest();
        
        Asset asset = [SELECT Id, Name, Status, Asset_Identifier__c FROM Asset WHERE Asset_Identifier__c = '1234'];

        Claim__c claim = [SELECT Id, Name FROM Claim__c WHERE Asset__c =: asset.Id LIMIT 1];

        System.assertEquals(claim.Name, result);
        System.assertEquals('Lost', asset.Status);
    }

    @isTest
    private static void testReportLostDeviceWithClaimWithInsurance() {
                
        Test.startTest();
        String result = AssetService.reportLostDevice('5678');
        Test.stopTest();
        
        Asset asset = [SELECT Id, Name, Status, Asset_Identifier__c FROM Asset WHERE Asset_Identifier__c = '5678'];

        Claim__c claim = [SELECT Id, Name FROM Claim__c WHERE Asset__c =: asset.Id LIMIT 1];

        System.assertEquals(claim.Name + ' already filed.', result + ' already filed.');
    }

    @isTest
    private static void testReportLostDeviceNoClaimWithoutInsurance() {
                
        Test.startTest();
        String result = AssetService.reportLostDevice('9012');
        Test.stopTest();
        
        Asset asset = [SELECT Id, Name, Status, Asset_Identifier__c FROM Asset WHERE Asset_Identifier__c = '9012'];

        System.assertEquals(asset.Status = 'Lost', asset.Status);
        System.assertEquals('No coverage. Asset status adjusted to Lost.', result);
    }

    @isTest
    private static void testReportLostDeviceNoDeviceFound() {
                
        Test.startTest();
        String result = AssetService.reportLostDevice('0000');
        Test.stopTest();

        System.assertEquals('No device found.', result);
    }
}