@IsTest
public with sharing class OrderItemTrigger_Test {
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

        Tax__c firstTax = (Tax__c)testFactory.createSObject(new Tax__c(
			Name = 'Test first Tax',
            Product__c = firstProduct.Id,
            DistributionCenter__c = firstDistributionCenter.Id,
            TaxOnCost__c = 10.00,
            Status__c = 'Aprovado',
            State__c = firstState.Id
		));
        Tax__c secondTax = (Tax__c)testFactory.createSObject(new Tax__c(
			Name = 'Test second Tax',
            Product__c = firstProduct.Id,
            DistributionCenter__c = firstDistributionCenter.Id,
            TaxOnCost__c = 50.00,
            Status__c = 'Aprovado',
            State__c = secondState.Id
		));
        Tax__c thirdTax = (Tax__c)testFactory.createSObject(new Tax__c(
			Name = 'Test third Tax',
            Product__c = secondProduct.Id,
            DistributionCenter__c = firstDistributionCenter.Id,
            TaxOnCost__c = 50.00,
            Status__c = 'Aprovado',
            State__c = secondState.Id
		));
        List<Tax__c> taxesToInsert = new List<Tax__c>{firstTax, secondTax, thirdTax};
        insert taxesToInsert;

        Freight__c lessSpecificFreight = (Freight__c)testFactory.createSObject(new Freight__c(
			Name = 'Test Less Specific freight',
            ProductHierarchy__c = firstProductHierarchy.id,
            DistributionCenter__c = firstDistributionCenter.Id,
            Status__c = 'Aprovado',
            Value__c = 100.00,
            Country__c = firstCountry.Id
		));
        insert lessSpecificFreight;

        Margin__c lessSpecificMargin = (Margin__c)testFactory.createSObject(new Margin__c(
			Name = 'Test Less Specific margin',
            ProductHierarchy__c = firstProductHierarchy.id,
            AccountGroup__c = firstAccountGroup.Id,
            DistributionCenter__c = firstDistributionCenter.Id,
            Status__c = 'Aprovado',
            Value__c = 100.00,
            Country__c = firstCountry.Id
		));
        insert lessSpecificMargin;
    }

    @IsTest
    static void testInsertAOrderItemThatAlreadyExistInDatabase(){
        TestFactorySObject testFactory = TestFactorySObject.getInstance();

        Product2 firstProduct  = [SELECT Id, ProductionCost__c FROM Product2 LIMIT 1];
        PricebookEntry firstPricebookEntry = [SELECT Id FROM PricebookEntry LIMIT 1];
        Order firstOrder = [SELECT Id FROM Order LIMIT 1];

        OrderItem firstOrderItem = (OrderItem)testFactory.createSObject(new OrderItem(
            Product2Id = firstProduct.Id,
            Quantity = 1,
            UnitPrice = firstProduct.ProductionCost__c,
            OrderId = firstOrder.Id,
            PricebookEntryId = firstPricebookEntry.Id
        ));
        OrderItem secondOrderItem = (OrderItem)testFactory.createSObject(new OrderItem(
            Product2Id = firstProduct.Id,
            Quantity = 1,
            UnitPrice = firstProduct.ProductionCost__c,
            OrderId = firstOrder.Id,
            PricebookEntryId = firstPricebookEntry.Id
        ));
        
        Test.startTest();
        insert firstOrderItem;
        Database.SaveResult orderItemWeWillTryToInsert = Database.insert(secondOrderItem, false);
        List<OrderItem> orderItemDeleted = [SELECT Id FROM OrderItem WHERE Id =: firstOrderItem.Id];
        Test.stopTest();

        Assert.areEqual(0, orderItemDeleted.size(), 'Error: The first order item should be deleted');
        Assert.isTrue(orderItemWeWillTryToInsert.isSuccess(), 'Error: The insertion of the second order item should be successful');
    }

    @IsTest
    static void testInsertTwoSameOrderItemsInSameTime(){
        TestFactorySObject testFactory = TestFactorySObject.getInstance();

        Product2 firstProduct  = [SELECT Id, ProductionCost__c FROM Product2 LIMIT 1];
        PricebookEntry firstPricebookEntry = [SELECT Id FROM PricebookEntry LIMIT 1];
        Order firstOrder = [SELECT Id FROM Order LIMIT 1];

        OrderItem firstOrderItem = (OrderItem)testFactory.createSObject(new OrderItem(
            Product2Id = firstProduct.Id,
            Quantity = 1,
            UnitPrice = firstProduct.ProductionCost__c,
            OrderId = firstOrder.Id,
            PricebookEntryId = firstPricebookEntry.Id
        ));
        OrderItem secondOrderItem = (OrderItem)testFactory.createSObject(new OrderItem(
            Product2Id = firstProduct.Id,
            Quantity = 1,
            UnitPrice = firstProduct.ProductionCost__c,
            OrderId = firstOrder.Id,
            PricebookEntryId = firstPricebookEntry.Id
        ));
        List<OrderItem> orderItemsToInsert = new List<OrderItem>{firstOrderItem, secondOrderItem};
        
        Test.startTest();
        Database.SaveResult[] orderItemsWeWillTryToInsert = Database.insert(orderItemsToInsert, false);
        Test.stopTest();

        List<Database.SaveResult> orderItemsNotInserted = new List<Database.SaveResult>();
        for(Database.SaveResult iOrderItem: orderItemsWeWillTryToInsert){
            if(!iOrderItem.isSuccess()){ 
                orderItemsNotInserted.add(iOrderItem);
            }
        }
        Assert.areEqual(1, orderItemsNotInserted.size(), 'Error: Should not be able to insert two order items with the same parameters, only one will be inserted');
    }

    @IsTest
    static void testInsertWithoutRequiredParameters(){
        TestFactorySObject testFactory = TestFactorySObject.getInstance();

        List<Product2> productsList  = [SELECT Id, ProductionCost__c FROM Product2 LIMIT 3];
        List<PricebookEntry> pricebookEntriesList = [SELECT Id FROM PricebookEntry LIMIT 3];
        Order firstOrder = [SELECT Id FROM Order LIMIT 1];
        
        OrderItem firstOrderItem = (OrderItem)testFactory.createSObject(new OrderItem(
            Product2Id = productsList.get(2).Id,
            Quantity = 0,
            UnitPrice = productsList.get(2).ProductionCost__c,
            OrderId = firstOrder.Id,
            PricebookEntryId = pricebookEntriesList.get(2).Id
        ));
        firstOrderItem.ListPrice = null;
        Test.startTest();
        Database.SaveResult orderItemWeWillTryToInsert = Database.insert(firstOrderItem, false);
        Test.stopTest();

        Assert.isFalse(orderItemWeWillTryToInsert.isSuccess(), 'Error: Should not be able to insert an order item without required parameters');
    }

    @IsTest
    static void testSearchForTheTax(){
        TestFactorySObject testFactory = TestFactorySObject.getInstance();

        Product2 firstProduct = [SELECT Id, ProductionCost__c FROM Product2 LIMIT 1];
        PricebookEntry firstPricebookEntry = [SELECT Id FROM PricebookEntry LIMIT 1];
        Order firstOrder = [SELECT Id, AccountAddress__c FROM Order LIMIT 1];
        
        OrderItem firstOrderItem = (OrderItem)testFactory.createSObject(new OrderItem(
            Product2Id = firstProduct.Id,
            Quantity = 1,
            UnitPrice = firstProduct.ProductionCost__c,
            OrderId = firstOrder.Id,
            PricebookEntryId = firstPricebookEntry.Id
        ));

        Test.startTest();
        insert firstOrderItem;

        AccountAddress__c firstAccountAddress = [SELECT Id, City__c FROM AccountAddress__c WHERE Id =:firstOrder.AccountAddress__c LIMIT 1];
        City__c firstCity = [SELECT Id, State__c FROM City__c  WHERE Id =:firstAccountAddress.City__c LIMIT 1];
        firstOrderItem = [SELECT Id, TaxPercentage__c FROM OrderItem WHERE Id =: firstOrderItem.Id];

        Assert.isNotNull(firstOrderItem.TaxPercentage__c, 'Error: The tax should not be null');

        Tax__c tax = [SELECT Id, TaxOnCost__c, Product__c, State__c FROM Tax__c WHERE Product__c =: firstProduct.Id AND State__c =: firstCity.State__c];
        Decimal taxValue = tax.TaxOnCost__c;

        Test.stopTest();

        Assert.areEqual(taxValue, firstOrderItem.TaxPercentage__c, 'Error: The tax in order item should be the same of the tax in the database');
    }

    @IsTest
    static void testSearchForTheMostSpecificFreight(){
        TestFactorySObject testFactory = TestFactorySObject.getInstance();

        Test.startTest();

        Product2 firstProduct = [SELECT Id, ProductionCost__c FROM Product2 LIMIT 1];
        ProductHierarchy__c firstProductHierarchy = [SELECT Id FROM ProductHierarchy__c LIMIT 1];
        DistributionCenter__c firstDistributionCenter = [SELECT Id FROM DistributionCenter__c LIMIT 1];
        PricebookEntry firstPricebookEntry = [SELECT Id FROM PricebookEntry LIMIT 1];
        Order firstOrder = [SELECT Id, AccountId, AccountAddress__c FROM Order LIMIT 1];
        AccountAddress__c firstAccountAddress = [SELECT Id, City__c FROM AccountAddress__c WHERE Id =:firstOrder.AccountAddress__c LIMIT 1];
        AccountGroup__c firstAccountGroup = [SELECT Id FROM AccountGroup__c LIMIT 1];
        State__c firstState = [SELECT Id FROM State__c LIMIT 1];
        Country__c firstCountry = [SELECT Id FROM Country__c LIMIT 1];
        
        OrderItem firstOrderItem = (OrderItem)testFactory.createSObject(new OrderItem(
            Product2Id = firstProduct.Id,
            Quantity = 1,
            UnitPrice = firstProduct.ProductionCost__c,
            OrderId = firstOrder.Id,
            PricebookEntryId = firstPricebookEntry.Id
        ));

        insert firstOrderItem;
        firstOrderItem = [SELECT Id, FreightValue__c FROM OrderItem WHERE Id =: firstOrderItem.Id];
        Assert.isNotNull(firstOrderItem.FreightValue__c, 'Error: The tax should not be null');
        Decimal formerFreight = firstOrderItem.FreightValue__c;

        Freight__c fifthMostSpecificFreight = (Freight__c)testFactory.createSObject(new Freight__c(
			Name = 'Test fifth Most Specific Freight',
            ProductHierarchy__c = firstProductHierarchy.id,
            DistributionCenter__c = firstDistributionCenter.Id,
            Status__c = 'Aprovado',
            Value__c = 35.00,
            State__c = firstState.Id
		));
        insert fifthMostSpecificFreight;
        update firstOrderItem;

        Freight__c fourthMostSpecificFreight = (Freight__c)testFactory.createSObject(new Freight__c(
			Name = 'Test fourth Most Specific Freight',
            ProductHierarchy__c = firstProductHierarchy.id,
            DistributionCenter__c = firstDistributionCenter.Id,
            Status__c = 'Aprovado',
            Value__c = 30.00,
            City__c = firstAccountAddress.City__c
		));
        insert fourthMostSpecificFreight;
        update firstOrderItem;

        Freight__c thirdMostSpecificFreight = (Freight__c)testFactory.createSObject(new Freight__c(
			Name = 'Test third Most Specific Freight',
            Product__c = firstProduct.id,
            DistributionCenter__c = firstDistributionCenter.Id,
            Status__c = 'Aprovado',
            Value__c = 25.00,
            Country__c = firstCountry.Id
		));
        insert thirdMostSpecificFreight;
        update firstOrderItem;

        Freight__c secondMostSpecificFreight = (Freight__c)testFactory.createSObject(new Freight__c(
			Name = 'Test second Most Specific Freight',
            Product__c = firstProduct.id,
            DistributionCenter__c = firstDistributionCenter.Id,
            Status__c = 'Aprovado',
            Value__c = 20.00,
            State__c = firstState.Id
		));
        insert secondMostSpecificFreight;
        update firstOrderItem;

        Freight__c mostSpecificFreight = (Freight__c)testFactory.createSObject(new Freight__c(
			Name = 'Test Most Specific Freight',
            Product__c = firstProduct.id,
            DistributionCenter__c = firstDistributionCenter.Id,
            Status__c = 'Aprovado',
            Value__c = 15.00,
            City__c = firstAccountAddress.City__c
		));
        insert mostSpecificFreight;
        update firstOrderItem;
        firstOrderItem = [SELECT Id, FreightValue__c FROM OrderItem WHERE Id =: firstOrderItem.Id];

        Test.stopTest();

        Assert.areNotEqual(formerFreight, firstOrderItem.FreightValue__c, 'Error: nao pode ser igual');
        Assert.areEqual(mostSpecificFreight.Value__c, firstOrderItem.FreightValue__c, 'Error: tem que ser igual ');
    }

    @IsTest
    static void testSearchForTheMostSpecificMarginAmoungTheWorst(){
        TestFactorySObject testFactory = TestFactorySObject.getInstance();

        Test.startTest();

        Product2 firstProduct = [SELECT Id, ProductionCost__c FROM Product2 LIMIT 1];
        ProductHierarchy__c firstProductHierarchy = [SELECT Id FROM ProductHierarchy__c LIMIT 1];
        DistributionCenter__c firstDistributionCenter = [SELECT Id FROM DistributionCenter__c LIMIT 1];
        PricebookEntry firstPricebookEntry = [SELECT Id FROM PricebookEntry LIMIT 1];
        Order firstOrder = [SELECT Id, AccountId, AccountAddress__c FROM Order LIMIT 1];
        AccountAddress__c firstAccountAddress = [SELECT Id, City__c FROM AccountAddress__c WHERE Id =:firstOrder.AccountAddress__c LIMIT 1];
        AccountGroup__c firstAccountGroup = [SELECT Id FROM AccountGroup__c LIMIT 1];
        State__c firstState = [SELECT Id FROM State__c LIMIT 1];
        Country__c firstCountry = [SELECT Id FROM Country__c LIMIT 1];
        
        OrderItem firstOrderItem = (OrderItem)testFactory.createSObject(new OrderItem(
            Product2Id = firstProduct.Id,
            Quantity = 1,
            UnitPrice = firstProduct.ProductionCost__c,
            OrderId = firstOrder.Id,
            PricebookEntryId = firstPricebookEntry.Id
        ));

        insert firstOrderItem;
        firstOrderItem = [SELECT Id, MarginPercentage__c FROM OrderItem WHERE Id =: firstOrderItem.Id];
        Assert.isNotNull(firstOrderItem.MarginPercentage__c, 'Error: The tax should not be null');
        Decimal formerMargin = firstOrderItem.MarginPercentage__c;
        
        Margin__c secondWorstSpecificMargin = (Margin__c)testFactory.createSObject(new Margin__c(
			Name = 'Test second worst specific Margin',
            ProductHierarchy__c = firstProductHierarchy.Id,
            AccountGroup__c = firstAccountGroup.Id,
            DistributionCenter__c = firstDistributionCenter.Id,
            Status__c = 'Aprovado',
            Value__c = 95.00,
            State__c = firstState.Id
		));
        insert secondWorstSpecificMargin;
        update firstOrderItem;

        Margin__c thirdWorstSpecificMargin = (Margin__c)testFactory.createSObject(new Margin__c(
			Name = 'Test third worst specific Margin',
            ProductHierarchy__c = firstProductHierarchy.Id,
            AccountGroup__c = firstAccountGroup.Id,
            DistributionCenter__c = firstDistributionCenter.Id,
            Status__c = 'Aprovado',
            Value__c = 90.00,
            City__c = firstAccountAddress.City__c
		));
        insert thirdWorstSpecificMargin;
        update firstOrderItem;

        Margin__c fourthWorstSpecificMargin = (Margin__c)testFactory.createSObject(new Margin__c(
			Name = 'Test fourth worst specific Margin',
            ProductHierarchy__c = firstProductHierarchy.Id,
            Account__c = firstOrder.AccountId,
            DistributionCenter__c = firstDistributionCenter.Id,
            Status__c = 'Aprovado',
            Value__c = 85.00,
            Country__c = firstCountry.Id
		));
        insert fourthWorstSpecificMargin;
        update firstOrderItem;

        Margin__c fifthWorstSpecificMargin = (Margin__c)testFactory.createSObject(new Margin__c(
			Name = 'Test fifth worst specific Margin',
            ProductHierarchy__c = firstProductHierarchy.Id,
            Account__c = firstOrder.AccountId,
            DistributionCenter__c = firstDistributionCenter.Id,
            Status__c = 'Aprovado',
            Value__c = 80.00,
            State__c = firstState.Id
		));
        insert fifthWorstSpecificMargin;
        update firstOrderItem;

        Margin__c sixthWorstSpecificMargin = (Margin__c)testFactory.createSObject(new Margin__c(
			Name = 'Test sixth worst specific Margin',
            ProductHierarchy__c = firstProductHierarchy.Id,
            Account__c = firstOrder.AccountId,
            DistributionCenter__c = firstDistributionCenter.Id,
            Status__c = 'Aprovado',
            Value__c = 75.00,
            City__c = firstAccountAddress.City__c
		));
        insert sixthWorstSpecificMargin;
        update firstOrderItem;
        firstOrderItem = [SELECT Id, MarginPercentage__c FROM OrderItem WHERE Id =: firstOrderItem.Id];

        Test.stopTest();

        Assert.areNotEqual(formerMargin, firstOrderItem.MarginPercentage__c, 'Error: The values of margins should not be equal');
        Assert.areEqual(sixthWorstSpecificMargin.Value__c, firstOrderItem.MarginPercentage__c, 'Error: The values of margins should be equal');
    }

    @IsTest
    static void testSearchForTheMostSpecificMarginAmoungTheBest(){
        TestFactorySObject testFactory = TestFactorySObject.getInstance();

        Test.startTest();

        Product2 firstProduct = [SELECT Id, ProductionCost__c FROM Product2 LIMIT 1];
        ProductHierarchy__c firstProductHierarchy = [SELECT Id FROM ProductHierarchy__c LIMIT 1];
        DistributionCenter__c firstDistributionCenter = [SELECT Id FROM DistributionCenter__c LIMIT 1];
        PricebookEntry firstPricebookEntry = [SELECT Id FROM PricebookEntry LIMIT 1];
        Order firstOrder = [SELECT Id, AccountId, AccountAddress__c FROM Order LIMIT 1];
        AccountAddress__c firstAccountAddress = [SELECT Id, City__c FROM AccountAddress__c WHERE Id =:firstOrder.AccountAddress__c LIMIT 1];
        AccountGroup__c firstAccountGroup = [SELECT Id FROM AccountGroup__c LIMIT 1];
        State__c firstState = [SELECT Id FROM State__c LIMIT 1];
        Country__c firstCountry = [SELECT Id FROM Country__c LIMIT 1];
        
        OrderItem firstOrderItem = (OrderItem)testFactory.createSObject(new OrderItem(
            Product2Id = firstProduct.Id,
            Quantity = 1,
            UnitPrice = firstProduct.ProductionCost__c,
            OrderId = firstOrder.Id,
            PricebookEntryId = firstPricebookEntry.Id
        ));

        insert firstOrderItem;
        firstOrderItem = [SELECT Id, MarginPercentage__c FROM OrderItem WHERE Id =: firstOrderItem.Id];
        Assert.isNotNull(firstOrderItem.MarginPercentage__c, 'Error: The tax should not be null');
        Decimal formerMargin = firstOrderItem.MarginPercentage__c;

        Margin__c sixthMostSpecificMargin = (Margin__c)testFactory.createSObject(new Margin__c(
			Name = 'Test sixth Most Specific Margin',
            Product__c = firstProduct.Id,
            AccountGroup__c = firstAccountGroup.Id,
            DistributionCenter__c = firstDistributionCenter.Id,
            Status__c = 'Aprovado',
            Value__c = 50.00,
            Country__c = firstCountry.Id
		));
        insert sixthMostSpecificMargin;
        update firstOrderItem;

        Margin__c fifthMostSpecificMargin = (Margin__c)testFactory.createSObject(new Margin__c(
			Name = 'Test fifth Most Specific Margin',
            Product__c = firstProduct.Id,
            AccountGroup__c = firstAccountGroup.Id,
            DistributionCenter__c = firstDistributionCenter.Id,
            Status__c = 'Aprovado',
            Value__c = 45.00,
            State__c = firstState.Id
		));
        insert fifthMostSpecificMargin;
        update firstOrderItem;

        Margin__c fourthMostSpecificMargin = (Margin__c)testFactory.createSObject(new Margin__c(
			Name = 'Test fourth Most Specific Margin',
            Product__c = firstProduct.Id,
            AccountGroup__c = firstAccountGroup.Id,
            DistributionCenter__c = firstDistributionCenter.Id,
            Status__c = 'Aprovado',
            Value__c = 40.00,
            City__c = firstAccountAddress.City__c
		));
        insert fourthMostSpecificMargin;
        update firstOrderItem;

        Margin__c thirdMostSpecificMargin = (Margin__c)testFactory.createSObject(new Margin__c(
			Name = 'Test third Most Specific Margin',
            Product__c = firstProduct.Id,
            Account__c = firstOrder.AccountId,
            DistributionCenter__c = firstDistributionCenter.Id,
            Status__c = 'Aprovado',
            Value__c = 35.00,
            Country__c = firstCountry.Id
		));
        insert thirdMostSpecificMargin;
        update firstOrderItem;

        Margin__c secondMostSpecificMargin = (Margin__c)testFactory.createSObject(new Margin__c(
			Name = 'Test second Most Specific Margin',
            Product__c = firstProduct.Id,
            Account__c = firstOrder.AccountId,
            DistributionCenter__c = firstDistributionCenter.Id,
            Status__c = 'Aprovado',
            Value__c = 30.00,
            State__c = firstState.Id
        ));
        insert secondMostSpecificMargin;
        update firstOrderItem;

        Margin__c mostSpecificMargin = (Margin__c)testFactory.createSObject(new Margin__c(
			Name = 'Test most specific Margin',
            Product__c = firstProduct.Id,
            Account__c = firstOrder.AccountId,
            DistributionCenter__c = firstDistributionCenter.Id,
            Status__c = 'Aprovado',
            Value__c = 25.00,
            City__c = firstAccountAddress.City__c
        ));
        insert mostSpecificMargin;
        update firstOrderItem;


        firstOrderItem = [SELECT Id, MarginPercentage__c FROM OrderItem WHERE Id =: firstOrderItem.Id];

        Test.stopTest();

        Assert.areNotEqual(formerMargin, firstOrderItem.MarginPercentage__c, 'Error: The values of margins should not be equal');
        Assert.areEqual(mostSpecificMargin.Value__c, firstOrderItem.MarginPercentage__c, 'Error: The values of margins should be equal');
    }
}