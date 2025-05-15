@RestResource(urlMapping = '/ProductZoning/*')
global with sharing class ProductZoningService {

    @HttpGet
    global static String getProductZoning() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

        String countryCode = req.headers.get('CountryCode'); 

        if(String.isEmpty(countryCode)) {
            countryCode = 'US';
        }
        
        String productCode = req.params.get('ProductCode');

        List<Product2> products = [SELECT Id, Name, Family, ProductCode FROM Product2 WHERE ProductCode = :productCode LIMIT 1];

        if (products.isEmpty()) {
            return 'ProductCode is missing or doesn\'t exist';
        }
        
        String family = products[0].Family;

        List<Product_Geo_Mapping__mdt> geoMapping = new List<Product_Geo_Mapping__mdt>();

        geoMapping = [
            SELECT Permissible_Fly_Zone__c 
            FROM Product_Geo_Mapping__mdt 
            WHERE 
                Product_Family__c = :family 
                AND Country_Code__c = :countryCode 
            LIMIT 1
        ];

        if (!geoMapping.isEmpty()) {
            return geoMapping[0].Permissible_Fly_Zone__c;
        } else {
            return 'Confirm with the local authorities';
        }
    }

}
