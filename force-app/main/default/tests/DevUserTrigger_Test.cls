@isTest
global with sharing class DevUserTrigger_Test {
    
    @isTest
    static void testInsertDevUserWithLogin(){
        TestFactorySObject testFactory = TestFactorySObject.getInstance();
        MockHttpResponseGenerator mock = new MockHttpResponseGenerator();
        Test.setMock(HttpCalloutMock.class, mock);

        DevUser__c firstDevUser = (DevUser__c)testFactory.createSObject(new DevUser__c(
			Name = 'DevUser test',
            Login__c = 'EnzoRazoppiTAAK'
		));

        Test.startTest();

        insert firstDevUser;

        Test.stopTest();
    }

    @isTest
    static void testUpdateDevUserWithLogin(){
        TestFactorySObject testFactory = TestFactorySObject.getInstance();
        MockHttpResponseGenerator mock = new MockHttpResponseGenerator();
        Test.setMock(HttpCalloutMock.class, mock);

        DevUser__c firstDevUser = (DevUser__c)testFactory.createSObject(new DevUser__c(
			Name = 'DevUser test',
            Login__c = 'EnzoRazoppiTAAK'
		));

        Test.startTest();

        insert firstDevUser;

        firstDevUser.Login__c = 'ThomTAAK';
        update firstDevUser;

        Test.stopTest();
    }

    @isTest
    static void testErrorHTTP(){
        TestFactorySObject testFactory = TestFactorySObject.getInstance();
        MockErrorHttpResponseGenerator mock = new MockErrorHttpResponseGenerator();
        Test.setMock(HttpCalloutMock.class, mock);

        DevUser__c firstDevUser = (DevUser__c)testFactory.createSObject(new DevUser__c(
			Name = 'DevUser test',
            Login__c = 'EnzoRazoppiTAAK'
		));

        Test.startTest();

        insert firstDevUser;

        Test.stopTest();
    }

    global class MockHttpResponseGenerator implements HttpCalloutMock {

        global HttpResponse respond(HttpRequest request) {

            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"login": "EnzoRazoppiTAAK", "id": 224847784, "type": "User", "bio": null}');
            response.setStatusCode(200);
            return response;
        }
    }
    global class MockErrorHttpResponseGenerator implements HttpCalloutMock {

        global HttpResponse respond(HttpRequest request) {

            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('ERROR RESPONSE');
            response.setStatusCode(500);
            return response;
        }
    }
}