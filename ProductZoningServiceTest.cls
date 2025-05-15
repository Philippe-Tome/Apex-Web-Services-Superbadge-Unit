@isTest
private with sharing class ProductZoningServiceTest {

    @TestSetup
    static void makeData() {
        Product2 product = new Product2(Name='Test', ProductCode='TestProduct', Family='Fixed-Wing');
    
        Insert product;
        
    }

    @isTest
    private static void testGetProductZoning() {
        
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/ProductZoning/';
        request.addParameter('ProductCode', 'TestProduct');
        request.httpMethod = 'GET';
        request.headers.put('CountryCode', 'US');

        RestContext.request = request;
        
        Test.startTest();
        String result = ProductZoningService.getProductZoning();
        Test.stopTest();
        
        System.assertEquals('Regulated', result);
    }

    @isTest
    private static void testGetProductZoningNoCountryCode() {
     
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/ProductZoning/';
        request.addParameter('ProductCode', 'TestProduct');
        request.httpMethod = 'GET';
        request.headers.put('CountryCode', '');

        RestContext.request = request;
        
        Test.startTest();
        String result = ProductZoningService.getProductZoning();
        Test.stopTest();
        
        System.assertEquals('Regulated', result);
    }

    @isTest
    private static void testGetProductZoningNoProductCode() {
     
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/ProductZoning/';
        request.addParameter('ProductCode', 'TestProduct');
        request.httpMethod = 'GET';
        request.headers.put('CountryCode', 'AU');

        RestContext.request = request;
        
        Test.startTest();
        String result = ProductZoningService.getProductZoning();
        Test.stopTest();
        
        System.assertEquals('Authorized', result);
    }

    @isTest
    private static void testGetProductZoningProductCodeNotExisting() {
     
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/ProductZoning/';
        request.addParameter('ProductCode', 'DoesNotExist');
        request.httpMethod = 'GET';
        request.headers.put('CountryCode', 'AU');

        RestContext.request = request;
        
        Test.startTest();
        String result = ProductZoningService.getProductZoning();
        Test.stopTest();
        
        System.assertEquals('ProductCode is missing or doesn\'t exist', result);
    }

}