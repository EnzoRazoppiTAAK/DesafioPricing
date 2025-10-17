@IsTest
public with sharing class OrderTrigger_Test {
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
        Product2 secondProduct = (Product2)testFactory.createSObject(new Product2(
			Name = 'Test second Product',
			IsActive = true,
            ProductionCost__c = 50.00d,
            ProductHierarchy__c = firstProductHierarchy.Id
		));
        Product2 thirdProduct = (Product2)testFactory.createSObject(new Product2(
			Name = 'Test third Product',
			IsActive = true,
            ProductionCost__c = 50.00d,
            ProductHierarchy__c = secondProductHierarchy.Id
		));
        List<Product2> productsToInsert = new List<Product2>{firstProduct, secondProduct, thirdProduct};
        insert productsToInsert;

        PricebookEntry firstPricebookEntry = (PricebookEntry)testFactory.createSObject(new PricebookEntry(
			Pricebook2Id = pricebookId,
			Product2Id = firstProduct.Id,
			UnitPrice = firstProduct.ProductionCost__c,
			IsActive = true
		));
        PricebookEntry secondPricebookEntry = (PricebookEntry)testFactory.createSObject(new PricebookEntry(
			Pricebook2Id = pricebookId,
			Product2Id = secondProduct.Id,
			UnitPrice = secondProduct.ProductionCost__c,
			IsActive = true
		));
        PricebookEntry thirdPricebookEntry = (PricebookEntry)testFactory.createSObject(new PricebookEntry(
			Pricebook2Id = pricebookId,
			Product2Id = thirdProduct.Id,
			UnitPrice = thirdProduct.ProductionCost__c,
			IsActive = true
		));
        List<PricebookEntry> pricebookEntriesToInsert = new List<PricebookEntry>{firstPricebookEntry, secondPricebookEntry, thirdPricebookEntry};
        insert pricebookEntriesToInsert;

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
        State__c secondState = (State__c)testFactory.createSObject(new State__c(
			Name = 'Test second State',
            Acronym__c = 'TS2',
            Country__c = firstCountry.Id
		));
        List<State__c> statesToInsert = new List<State__c>{firstState, secondState};
        insert statesToInsert;

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
            FreightType__c = 'CIF'
        ));
        insert firstOrder;

    }

    @IsTest
    static void testInsertStatusShouldBeNovo(){
        
        TestFactorySObject testFactory = TestFactorySObject.getInstance();

        Id pricebookId = TestFactorySObject.getStandardPricebookId();
        DistributionCenter__c firstDistributionCenter = [SELECT Id FROM DistributionCenter__c LIMIT 1];
        PaymentCondition__c firstPaymentCondition = [SELECT Id FROM PaymentCondition__c LIMIT 1];
        Contract firstContract = [SELECT Id FROM Contract LIMIT 1];
        Account firstAccount = [SELECT Id FROM Account LIMIT 1];
        AccountAddress__c firstAccountAddress = [SELECT Id FROM AccountAddress__c LIMIT 1];

        Order firstOrder = (Order)testFactory.createSObject(new Order( 
            Name = 'Test first Order',
            Status = 'Em aprovação',
            AccountId =  firstAccount.Id,
            AccountAddress__c = firstAccountAddress.Id,
            EffectiveDate = Date.today(),
            ContractId = firstContract.Id,
            PaymentCondition__c = firstPaymentCondition.Id,
            DistributionCenter__c = firstDistributionCenter.Id,
            Pricebook2Id = pricebookId,
            FreightType__c = 'CIF'
        ));

        Order secondtOrder = (Order)testFactory.createSObject(new Order( 
            Name = 'Test Second Order',
            Status = 'Aprovado',
            AccountId =  firstAccount.Id,
            AccountAddress__c = firstAccountAddress.Id,
            EffectiveDate = Date.today(),
            ContractId = firstContract.Id,
            PaymentCondition__c = firstPaymentCondition.Id,
            DistributionCenter__c = firstDistributionCenter.Id,
            Pricebook2Id = pricebookId,
            FreightType__c = 'CIF'
        ));

        Order thirdOrder = (Order)testFactory.createSObject(new Order( 
            Name = 'Test third Order',
            Status = 'Erro de integração',
            AccountId =  firstAccount.Id,
            AccountAddress__c = firstAccountAddress.Id,
            EffectiveDate = Date.today(),
            ContractId = firstContract.Id,
            PaymentCondition__c = firstPaymentCondition.Id,
            DistributionCenter__c = firstDistributionCenter.Id,
            Pricebook2Id = pricebookId,
            FreightType__c = 'CIF'
        ));

        Order fourthOrder = (Order)testFactory.createSObject(new Order( 
            Name = 'Test fourth Order',
            Status = 'Integrado',
            AccountId =  firstAccount.Id,
            AccountAddress__c = firstAccountAddress.Id,
            EffectiveDate = Date.today(),
            ContractId = firstContract.Id,
            PaymentCondition__c = firstPaymentCondition.Id,
            DistributionCenter__c = firstDistributionCenter.Id,
            Pricebook2Id = pricebookId,
            FreightType__c = 'CIF'
        ));
        List<Order> orders = new List<Order>{firstOrder, secondtOrder, thirdOrder, fourthOrder};
        Test.startTest();

        List<Database.SaveResult> ordersWeWillTryToInsert = Database.insert(orders, false);
        List<Database.SaveResult> ordersInserted = new List<Database.SaveResult>();

        for(Database.SaveResult iOrder: ordersWeWillTryToInsert){
            if(iOrder.isSuccess()){ 
                ordersInserted.add(iOrder);
            }
        }

        Test.stopTest();

        Assert.areEqual(0, ordersInserted.size(), 'Error: Should not be able to insert Order without Status Novo');
    }
    

    @IsTest
    static void testCalculateDiscount(){
        TestFactorySObject testFactory = TestFactorySObject.getInstance();

        Id pricebookId = TestFactorySObject.getStandardPricebookId();
        DistributionCenter__c firstDistributionCenter = [SELECT Id FROM DistributionCenter__c LIMIT 1];
        PaymentCondition__c firstPaymentCondition = [SELECT Id FROM PaymentCondition__c LIMIT 1];
        Contract firstContract = [SELECT Id FROM Contract LIMIT 1];
        Account firstAccount = [SELECT Id FROM Account LIMIT 1];
        AccountAddress__c firstAccountAddress = [SELECT Id FROM AccountAddress__c LIMIT 1];
        Product2 firstProduct  = [SELECT Id, ProductionCost__c FROM Product2 LIMIT 1];
        PricebookEntry firstPricebookEntry = [SELECT Id FROM PricebookEntry LIMIT 1];
        Order firstOrder = [SELECT Id, Discount__c FROM Order LIMIT 1];

        OrderItem firstOrderItem = (OrderItem)testFactory.createSObject(new OrderItem(
            Product2Id = firstProduct.Id,
            Quantity = 1,
            UnitPrice = firstProduct.ProductionCost__c,
            OrderId = firstOrder.Id,
            PricebookEntryId = firstPricebookEntry.Id
        ));

        Test.startTest();

        insert firstOrderItem;

        Order orderUpdated = [SELECT Id, Discount__c FROM Order LIMIT 1];

        Test.stopTest();

        Assert.isNotNull(orderUpdated.Discount__c, 'Error: Should not be null');
    }

    @IsTest
    static void testUpdateTheOrderAccount() {
        TestFactorySObject testFactory = TestFactorySObject.getInstance();

        Order firstOrder = [SELECT Id, AccountId FROM Order LIMIT 1];
        AccountGroup__c firstAccountGroup = [SELECT Id FROM AccountGroup__c LIMIT 1];

        Account secondAccount = (Account)testFactory.createSObject(new Account(
			Name = 'Test second Account',
            AccountGroup__c = firstAccountGroup.Id,
            CNPJ__c = '00000000000001'
		));

        Test.startTest();
        insert secondAccount;

        firstOrder.AccountId = secondAccount.Id;

        Database.SaveResult orderWeWillTryToUpdate = Database.update(firstOrder, false);

        Test.stopTest();

        Assert.isFalse(orderWeWillTryToUpdate.isSuccess(), 'Error: Should not be able to update the order account');
    }

    @IsTest
    static void testCannotUpdateIntegradoItem(){
        TestFactorySObject testFactory = TestFactorySObject.getInstance();

        Test.startTest();

        Id pricebookId = TestFactorySObject.getStandardPricebookId();
        DistributionCenter__c firstDistributionCenter = [SELECT Id FROM DistributionCenter__c LIMIT 1];
        PaymentCondition__c firstPaymentCondition = [SELECT Id FROM PaymentCondition__c LIMIT 1];
        Contract firstContract = [SELECT Id FROM Contract LIMIT 1];
        Account firstAccount = [SELECT Id FROM Account LIMIT 1];
        AccountAddress__c firstAccountAddress = [SELECT Id FROM AccountAddress__c LIMIT 1];

        Order firstOrder = (Order)testFactory.createSObject(new Order( 
            Name = 'Test first Order',
            Status = 'Integrado',
            AccountId =  firstAccount.Id,
            AccountAddress__c = firstAccountAddress.Id,
            EffectiveDate = Date.today(),
            ContractId = firstContract.Id,
            PaymentCondition__c = firstPaymentCondition.Id,
            DistributionCenter__c = firstDistributionCenter.Id,
            Pricebook2Id = pricebookId,
            FreightType__c = 'CIF'
        ));

        insert firstOrder;

        firstContract.Status = 'Activated';
        firstOrder.Status = 'Activated';

        update firstContract;
        update firstOrder;

        firstOrder = [SELECT Id, AccountId, Status, FreightType__c FROM Order LIMIT 1];

        firstOrder.FreightType__c = 'FOB';

        Database.SaveResult orderWeWillTryToUpdate = Database.update(firstOrder, false);

        Test.stopTest();

        Assert.isFalse(orderWeWillTryToUpdate.isSuccess(), 'Error: Should not be able to update the order after it was activated');
    }

    @IsTest
    static void testIsERPItem(){
        User userIntegration = [SELECT Id FROM User WHERE UserName = 'userintegration@api.com' LIMIT 1];

        System.runAs(userIntegration){
            TestFactorySObject testFactory = TestFactorySObject.getInstance();

            Id pricebookId = TestFactorySObject.getStandardPricebookId();
            DistributionCenter__c firstDistributionCenter = [SELECT Id FROM DistributionCenter__c LIMIT 1];
            PaymentCondition__c firstPaymentCondition = [SELECT Id FROM PaymentCondition__c LIMIT 1];
            Contract firstContract = [SELECT Id FROM Contract LIMIT 1];
            Account firstAccount = [SELECT Id FROM Account LIMIT 1];
            AccountAddress__c firstAccountAddress = [SELECT Id FROM AccountAddress__c LIMIT 1];

            Order firstOrder = (Order)testFactory.createSObject(new Order( 
                Name = 'Test first Order',
                Status = 'Em aprovação',
                AccountId =  firstAccount.Id,
                AccountAddress__c = firstAccountAddress.Id,
                EffectiveDate = Date.today(),
                ContractId = firstContract.Id,
                PaymentCondition__c = firstPaymentCondition.Id,
                DistributionCenter__c = firstDistributionCenter.Id,
                Pricebook2Id = pricebookId,
                FreightType__c = 'CIF'
            ));

        }
    }
}