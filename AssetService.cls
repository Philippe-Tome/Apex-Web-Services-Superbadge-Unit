@RestResource(urlMapping = '/lost/*')
global with sharing class AssetService {

    @HttpPut
    global static String reportLostDevice(String assetIdentifier) {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

        List<Asset> assets = [
            SELECT 
                Id,
                AccountId,
                Name,
                Status,
                Asset_Identifier__c,
                (
                    SELECT
                        Id,
                        Coverage__c,
                        Active__c
                    FROM 
                        Insurances__r
                    WHERE 
                        Coverage__c = 'Comprehensive' 
                        AND Active__C = true
                ) 
            FROM 
                Asset
            WHERE
                Asset_Identifier__c = :assetIdentifier
        ];

        if (assets.isEmpty()) {
            return 'No device found.';
        }

        List<Claim__c> claims = [
            SELECT
                Id,
                Name,
                Asset__c,
                Insurance__c,
                Type__c
            FROM 
                Claim__c
            WHERE
                Asset__c = :assets[0].Id
                AND Type__c = 'Loss'
        ];

        if (!claims.isEmpty()) {
            return claims[0].Name + ' already filed.';
        }

        List<Insurance__c> comprehensiveInsurancesOnAsset = assets[0].Insurances__r;

        if (comprehensiveInsurancesOnAsset.isEmpty()) {
            assets[0].Status = 'Lost';
            update assets[0];

            return 'No coverage. Asset status adjusted to Lost.';
        }

        Claim__c claim = new claim__c(
            Asset__c = assets[0].Id,
            Type__c = 'Loss',
            Insurance__c = comprehensiveInsurancesOnAsset[0].Id
        );

        assets[0].Status = 'Lost';

        update assets[0];
        insert claim;

        String newClaimName = [SELECT Id, Name FROM Claim__c WHERE Id =: claim.Id].Name;

        return newClaimName;
    }

}