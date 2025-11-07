@IsTest
public with sharing class InboundOrder_Test {
    
    @TestSetup
    static void makeData(){
        TestFactorySObject testFactory = TestFactorySObject.getInstance();

        Id pricebookId = TestFactorySObject.getStandardPricebookId();

        ProductHierarchy__c firstProductHierarchy = (ProductHierarchy__c)testFactory.createSObject(new ProductHierarchy__c(
			Name = 'Test first ProductHierarchy'
		));
        insert firstProductHierarchy;
        
        Product2 firstProduct = (Product2)testFactory.createSObject(new Product2(
			Name = 'Test first Product',
			IsActive = true,
            ProductionCost__c = 100.00d,
            ProductHierarchy__c = firstProductHierarchy.Id,
            ExternalId__c = '1'
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
            CNPJ__c = '00000000000000',
            ExternalId__c = '1'
		));
        insert firstAccount;

        AccountAddress__c firstAccountAddress = (AccountAddress__c)testFactory.createSObject(new AccountAddress__c(
			Name = 'Test first Account Address',
            Account__c = firstAccount.Id,
            Neighbourhood__c = 'Test Neighbourhood',
            CEP__c = 'Test CEP',
            PublicPlace__c = 'Test Public Place',
            City__c = firstCity.Id,
            ExternalId__c = '1'
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
			Name = 'Test first payment condition',
            ExternalId__c = '1'
		));
        insert firstPaymentCondition;

        DistributionCenter__c firstDistributionCenter = (DistributionCenter__c)testFactory.createSObject(new DistributionCenter__c(
			Name = 'Test Distribution Center',
            ExternalId__c = '1'
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
            ExternalId__c = '1',
            deliveryDate__c = Date.today()
        ));
        insert firstOrder;
    }

    @IsTest
    static void testInboundRightOrder(){
        TestFactorySObject testFactory = TestFactorySObject.getInstance();

        Product2 firstProduct  = [SELECT Id, ProductionCost__c FROM Product2 LIMIT 1];
        PricebookEntry firstPricebookEntry = [SELECT Id FROM PricebookEntry LIMIT 1];
        Order firstOrder = [SELECT Id FROM Order LIMIT 1];

        OrderItem firstOrderItem = (OrderItem)testFactory.createSObject(new OrderItem(
            Product2Id = firstProduct.Id,
            Quantity = 1,
            UnitPrice = firstProduct.ProductionCost__c,
            OrderId = firstOrder.Id,
            PricebookEntryId = firstPricebookEntry.Id,
            ExternalId__c = '1',
            TotvsItem__c = true       
        ));

        Test.startTest();

        insert firstOrderItem;

        Order firstOrderUpdated = [SELECT Id, ExternalId__c, Account.ExternalId__c, AccountAddress__r.ExternalId__c, 
            PaymentCondition__r.ExternalId__c, DistributionCenter__r.ExternalId__c, EffectiveDate, FreightType__c, deliveryDate__c, Status, Observation__c, 
            (SELECT ExternalId__c, Product2.ExternalId__c, TotvsItem__c, UnitPrice, ListPrice, Quantity FROM OrderItems)  
            FROM Order LIMIT 1
        ];

        OrderDTO.OrderData orderData = new OrderDTO.OrderData(firstOrderUpdated);
        OrderDTO orderDTO = new orderDTO(new List<OrderDTO.OrderData>{orderData});
        System.debug('orderDTO: '+ orderDTO);
        System.debug('orderData: '+ orderData);


        String orderJson = JSON.serialize(orderDTO);

        System.debug(orderJson);

        RestRequest request = new RestRequest();
        request.requestUri ='https://brave-shark-nskhtp-dev-ed.trailblaze.my.salesforce.com/services//apexrest/upsertOrder';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(orderJson);
        RestContext.request = request;

        RestContext.response = new RestResponse();

        InboundResponse.InboundResponseList inboundResponse = InboundOrder_Controller.upsertOrder();

        Assert.isNotNull(inboundResponse, 'InboundResponse shlout not be null');

        Test.stopTest();
    }


    @IsTest
    static void testInboundOrderWithJSONError(){
        TestFactorySObject testFactory = TestFactorySObject.getInstance();

        Product2 firstProduct  = [SELECT Id, ProductionCost__c FROM Product2 LIMIT 1];

        Test.startTest();

        String orderJson = JSON.serialize(firstProduct);

        RestRequest request = new RestRequest();
        request.requestUri ='https://brave-shark-nskhtp-dev-ed.trailblaze.my.salesforce.com/services//apexrest/upsertOrder';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(orderJson);
        RestContext.request = request;

        RestContext.response = new RestResponse();

        InboundResponse.InboundResponseList inboundResponse = InboundOrder_Controller.upsertOrder();

        Assert.isNotNull(inboundResponse, 'InboundResponse shlout not be null');

        Test.stopTest();
    }

    @IsTest
    static void testInboundOrderWithoutOrderItem(){
        TestFactorySObject testFactory = TestFactorySObject.getInstance();

        Test.startTest();

        Order firstOrderUpdated = [SELECT Id, ExternalId__c, Account.ExternalId__c, AccountAddress__r.ExternalId__c, 
            PaymentCondition__r.ExternalId__c, DistributionCenter__r.ExternalId__c, EffectiveDate, FreightType__c, deliveryDate__c, Status, Observation__c, 
            (SELECT ExternalId__c, Product2.ExternalId__c, TotvsItem__c, UnitPrice, ListPrice, Quantity FROM OrderItems)  
            FROM Order LIMIT 1
        ];

        OrderDTO.OrderData orderData = new OrderDTO.OrderData(firstOrderUpdated);
        OrderDTO orderDTO = new orderDTO(new List<OrderDTO.OrderData>{orderData});

        String orderJson = JSON.serialize(orderDTO);

        System.debug(orderJson);

        RestRequest request = new RestRequest();
        request.requestUri ='https://brave-shark-nskhtp-dev-ed.trailblaze.my.salesforce.com/services//apexrest/upsertOrder';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(orderJson);
        RestContext.request = request;

        RestContext.response = new RestResponse();

        InboundResponse.InboundResponseList inboundResponse = InboundOrder_Controller.upsertOrder();

        Assert.isNotNull(inboundResponse, 'InboundResponse shlout not be null');

        Test.stopTest();
    }

    @IsTest
    static void testInboundOrderWithWrongProduct(){
        TestFactorySObject testFactory = TestFactorySObject.getInstance();

        Product2 firstProduct  = [SELECT Id, ProductionCost__c FROM Product2 LIMIT 1];
        PricebookEntry firstPricebookEntry = [SELECT Id FROM PricebookEntry LIMIT 1];
        Order firstOrder = [SELECT Id FROM Order LIMIT 1];

        OrderItem firstOrderItem = (OrderItem)testFactory.createSObject(new OrderItem(
            Product2Id = firstProduct.Id,
            Quantity = 1,
            UnitPrice = firstProduct.ProductionCost__c,
            OrderId = firstOrder.Id,
            PricebookEntryId = firstPricebookEntry.Id,
            ExternalId__c = '2',
            TotvsItem__c = true       
        ));

        Test.startTest();

        insert firstOrderItem;

        Order firstOrderUpdated = [SELECT Id, ExternalId__c, Account.ExternalId__c, AccountAddress__r.ExternalId__c, 
            PaymentCondition__r.ExternalId__c, DistributionCenter__r.ExternalId__c, EffectiveDate, FreightType__c, deliveryDate__c, Status, Observation__c, 
            (SELECT ExternalId__c, Product2.ExternalId__c, TotvsItem__c, UnitPrice, ListPrice, Quantity FROM OrderItems)  
            FROM Order LIMIT 1
        ];

        OrderDTO.OrderData orderData = new OrderDTO.OrderData(firstOrderUpdated);
        OrderDTO orderDTO = new orderDTO(new List<OrderDTO.OrderData>{orderData});
        System.debug('orderDTO: '+ orderDTO);
        System.debug('orderData: '+ orderData);


        String orderJson = JSON.serialize(orderDTO);

        System.debug(orderJson);

        RestRequest request = new RestRequest();
        request.requestUri ='https://brave-shark-nskhtp-dev-ed.trailblaze.my.salesforce.com/services//apexrest/upsertOrder';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(orderJson);
        RestContext.request = request;

        RestContext.response = new RestResponse();

        InboundResponse.InboundResponseList inboundResponse = InboundOrder_Controller.upsertOrder();

        Assert.isNotNull(inboundResponse, 'InboundResponse shlout not be null');

        Test.stopTest();
    }

    @IsTest
    static void testInboundOrderWithWrongAccount(){
        TestFactorySObject testFactory = TestFactorySObject.getInstance();

        Order firstOrder = [SELECT Id, ExternalId__c, Account.ExternalId__c, AccountAddress__r.ExternalId__c, 
            PaymentCondition__r.ExternalId__c, DistributionCenter__r.ExternalId__c, EffectiveDate, FreightType__c, deliveryDate__c, Status, Observation__c, 
            (SELECT ExternalId__c, Product2.ExternalId__c, TotvsItem__c, UnitPrice, ListPrice, Quantity FROM OrderItems)  
            FROM Order LIMIT 1
        ];

        firstOrder.Account.ExternalId__c = '50';

        Test.startTest();

        OrderDTO.OrderData orderData = new OrderDTO.OrderData(firstOrder);
        OrderDTO orderDTO = new orderDTO(new List<OrderDTO.OrderData>{orderData});
        System.debug('orderDTO: '+ orderDTO);
        System.debug('orderData: '+ orderData);


        String orderJson = JSON.serialize(orderDTO);

        System.debug(orderJson);

        RestRequest request = new RestRequest();
        request.requestUri ='https://brave-shark-nskhtp-dev-ed.trailblaze.my.salesforce.com/services//apexrest/upsertOrder';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(orderJson);
        RestContext.request = request;

        RestContext.response = new RestResponse();

        InboundResponse.InboundResponseList inboundResponse = InboundOrder_Controller.upsertOrder();

        Assert.isNotNull(inboundResponse, 'InboundResponse shlout not be null');

        Test.stopTest();
    }

    @IsTest
    static void testInboundOrderWithWrongFreightType(){
        TestFactorySObject testFactory = TestFactorySObject.getInstance();

        Order firstOrder = [SELECT Id, ExternalId__c, Account.ExternalId__c, AccountAddress__r.ExternalId__c, 
            PaymentCondition__r.ExternalId__c, DistributionCenter__r.ExternalId__c, EffectiveDate, FreightType__c, deliveryDate__c, Status, Observation__c, 
            (SELECT ExternalId__c, Product2.ExternalId__c, TotvsItem__c, UnitPrice, ListPrice, Quantity FROM OrderItems)  
            FROM Order LIMIT 1
        ];

        firstOrder.FreightType__c = '50';

        Test.startTest();

        OrderDTO.OrderData orderData = new OrderDTO.OrderData(firstOrder);
        OrderDTO orderDTO = new orderDTO(new List<OrderDTO.OrderData>{orderData});
        System.debug('orderDTO: '+ orderDTO);
        System.debug('orderData: '+ orderData);


        String orderJson = JSON.serialize(orderDTO);

        System.debug(orderJson);

        RestRequest request = new RestRequest();
        request.requestUri ='https://brave-shark-nskhtp-dev-ed.trailblaze.my.salesforce.com/services//apexrest/upsertOrder';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(orderJson);
        RestContext.request = request;

        RestContext.response = new RestResponse();

        InboundResponse.InboundResponseList inboundResponse = InboundOrder_Controller.upsertOrder();

        Assert.isNotNull(inboundResponse, 'InboundResponse shlout not be null');

        Test.stopTest();
    }

}