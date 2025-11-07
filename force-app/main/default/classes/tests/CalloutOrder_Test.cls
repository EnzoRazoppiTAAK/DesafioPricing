@IsTest
global with sharing class CalloutOrder_Test {

    @TestSetup
    static void makeData(){
        TestFactorySObject testFactory = TestFactorySObject.getInstance();

        Id pricebookId = TestFactorySObject.getStandardPricebookId();

        ProductHierarchy__c firstProductHierarchy = (ProductHierarchy__c)testFactory.createSObject(new ProductHierarchy__c(
			Name = 'Test first ProductHierarchy'
		));
        ProductHierarchy__c secondProductHierarchy = (ProductHierarchy__c)testFactory.createSObject(new ProductHierarchy__c(
			Name = 'Test second ProductHierarchy'
		));
        List<ProductHierarchy__c> productHierarchiesToInsert = new List<ProductHierarchy__c>{firstProductHierarchy, secondProductHierarchy};
        insert productHierarchiesToInsert;
        
        Product2 firstProduct = (Product2)testFactory.createSObject(new Product2(
			Name = 'Test first Product',
			IsActive = true,
            ProductionCost__c = 100.00d,
            ProductHierarchy__c = firstProductHierarchy.Id
		));
        insert firstProduct;

        PricebookEntry firstPricebookEntry = (PricebookEntry)testFactory.createSObject(new PricebookEntry(
			Pricebook2Id = pricebookId,
			Product2Id = firstProduct.Id,
			UnitPrice = firstProduct.ProductionCost__c,
			IsActive = true
		));
        insert firstPricebookEntry;

        Country__c firstCountry = (Country__c)testFactory.createSObject(new Country__c(
			Name = 'Test Country',
            Acronym__c = 'CR'
		));
        insert firstCountry;

        State__c firstState = (State__c)testFactory.createSObject(new State__c(
			Name = 'Test first State',
            Acronym__c = 'TS1',
            Country__c = firstCountry.Id
		));
        insert firstState;

        City__c firstCity = (City__c)testFactory.createSObject(new City__c(
			Name = 'Test first city',
            CodigoIBGE__c = 0.00d,
            State__c = firstState.Id
		));
        insert firstCity;

        AccountGroup__c firstAccountGroup = (AccountGroup__c)testFactory.createSObject(new AccountGroup__c(
		    Name = 'Test first Account Group'
		));
        insert firstAccountGroup;

        Account firstAccount = (Account)testFactory.createSObject(new Account(
			Name = 'Test first Account',
            AccountGroup__c = firstAccountGroup.Id,
            CNPJ__c = '00000000000000'
		));
        insert firstAccount;

        AccountAddress__c firstAccountAddress = (AccountAddress__c)testFactory.createSObject(new AccountAddress__c(
			Name = 'Test first Account Address',
            Account__c = firstAccount.Id,
            Neighbourhood__c = 'Test Neighbourhood',
            CEP__c = 'Test CEP',
            PublicPlace__c = 'Test Public Place',
            City__c = firstCity.Id
		));
        insert firstAccountAddress;

        Contract firstContract= (Contract)testFactory.createSObject(new Contract(
			Name = 'Test first Contract',
            AccountId = firstAccount.Id,
            Status = 'Draft',
            StartDate = Date.today(),
            ContractTerm = 12
		));
        insert firstContract;

        PaymentCondition__c firstPaymentCondition= (PaymentCondition__c)testFactory.createSObject(new PaymentCondition__c(
			Name = 'Test first payment condition'
		));
        insert firstPaymentCondition;

        DistributionCenter__c firstDistributionCenter = (DistributionCenter__c)testFactory.createSObject(new DistributionCenter__c(
			Name = 'Test Distribution Center'
		));
        insert firstDistributionCenter;

        Freight__c mostSpecificFreight = (Freight__c)testFactory.createSObject(new Freight__c(
			Name = 'Test Less Specific freight',
            Product__c = firstProduct.Id,
            DistributionCenter__c = firstDistributionCenter.Id,
            Status__c = 'Aprovado',
            Value__c = 100.00,
            City__c = firstCity.Id
		));
        insert mostSpecificFreight;

        Margin__c mostSpecificMargin = (Margin__c)testFactory.createSObject(new Margin__c(
			Name = 'Test Less Specific margin',
            Product__c = firstProduct.Id,
            Account__c = firstAccount.Id,
            DistributionCenter__c = firstDistributionCenter.Id,
            Status__c = 'Aprovado',
            Value__c = 100.00,
            City__c = firstCity.Id
		));
        insert mostSpecificMargin;

        Tax__c firstTax = (Tax__c)testFactory.createSObject(new Tax__c(
			Name = 'Test first Tax',
            Product__c = firstProduct.Id,
            DistributionCenter__c = firstDistributionCenter.Id,
            TaxOnCost__c = 10.00,
            Status__c = 'Aprovado',
            State__c = firstState.Id
		));
        insert firstTax;
        
        Order firstOrder = (Order)testFactory.createSObject(new Order( 
            Name = 'Test first Order',
            Status = 'Novo',
            AccountId =  firstAccount.Id,
            AccountAddress__c = firstAccountAddress.Id,
            EffectiveDate = Date.today(),
            ContractId = firstContract.Id,
            PaymentCondition__c = firstPaymentCondition.Id,
            DistributionCenter__c = firstDistributionCenter.Id,
            Pricebook2Id = pricebookId,
            FreightType__c = 'CIF',
            ExternalId__c = '1'
        ));
        insert firstOrder;
    }

    @IsTest
    static void testCalloutResponseError(){
        TestFactorySObject testFactory = TestFactorySObject.getInstance();
        Test.setMock(HttpCalloutMock.class, new MockHttpErrorResponseGenerator());

        Test.startTest();

        Order firstOrder = [SELECT Id FROM Order LIMIT 1];
        calloutOrder_Service.calloutOrders(new List<Id>{firstOrder.Id}, 'Elias');

        Order ChangedOrder = [SELECT Id, Status FROM Order LIMIT 1];

        Test.stopTest();

        Assert.areEqual('Erro de integração', ChangedOrder.Status);
    }

    @IsTest
    static void testCalloutResponseWithoutExeternalCode(){
        TestFactorySObject testFactory = TestFactorySObject.getInstance();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseWithoutExternalCodeGenerator());

        Test.startTest();

        Order firstOrder = [SELECT Id FROM Order LIMIT 1];
        calloutOrder_Service.calloutOrders(new List<Id>{firstOrder.Id}, 'Elias');

        Order ChangedOrder = [SELECT Id, Status FROM Order LIMIT 1];

        Test.stopTest();

        Assert.areEqual('Erro de integração', ChangedOrder.Status);
    }

    @IsTest
    static void testInvocableMethodOrder(){
        TestFactorySObject testFactory = TestFactorySObject.getInstance();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseWithoutExternalCodeGenerator());

        Test.startTest();
        

        Order firstOrder = [SELECT Id FROM Order LIMIT 1];
        InvocableMethodOrder.invocableProcessIntegration(new List<Id>{firstOrder.Id});

        Order ChangedOrder = [SELECT Id, Status FROM Order LIMIT 1];

        Test.stopTest();

        Assert.areEqual('Erro de integração', ChangedOrder.Status);
    }

    global class MockHttpErrorResponseGenerator implements HttpCalloutMock {

        global HttpResponse respond(HttpRequest request) {

            System.assertEquals('callout:OrgDoElias/services//apexrest/upsertOrder', request.getEndpoint());
            System.assertEquals('POST', request.getMethod());

            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{["errorCode": ]}}');
            response.setStatusCode(200);
            return response;
        }
    }

    global class MockHttpResponseWithoutExternalCodeGenerator implements HttpCalloutMock {

        global HttpResponse respond(HttpRequest request) {

            System.assertEquals('callout:OrgDoElias/services//apexrest/upsertOrder', request.getEndpoint());
            System.assertEquals('POST', request.getMethod());

            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"responses": [{"sobjectType": "Order","salesforceId": "801bm00001FBaDVAA1","hasError": true,"externalCode": null,"errorMessage": null,'
            + '"items":[{"sobjectType": "OrderItem","salesforceId": "802bm00000EucgrAAB","hasError": true,"externalCode": null,"errorMessage": null}]}]}');
            response.setStatusCode(200);
            return response;
        }
    }
}