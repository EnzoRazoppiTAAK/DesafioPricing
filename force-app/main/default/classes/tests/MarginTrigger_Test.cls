@IsTest
public with sharing class MarginTrigger_Test {
    
    @TestSetup
    static void makeData(){
        TestFactorySObject testFactory = TestFactorySObject.getInstance();

        ProductHierarchy__c firstProductHierarchy = (ProductHierarchy__c)testFactory.createSObject(new ProductHierarchy__c(
			Name = 'Test first ProductHierarchy'
		));
        insert firstProductHierarchy;
        
        Product2 firstProduct = (Product2)testFactory.createSObject(new Product2(
			Name = 'Test first Product',
			IsActive = true,
            ProductionCost__c = 0.00d,
            ProductHierarchy__c = firstProductHierarchy.Id
		));
        Product2 secondProduct = (Product2)testFactory.createSObject(new Product2(
			Name = 'Test second Product',
			IsActive = true,
            ProductionCost__c = 0.00d,
            ProductHierarchy__c = firstProductHierarchy.Id
		));
        List<Product2> productsToInsert = new List<Product2>{firstProduct, secondProduct};
        insert productsToInsert;

        DistributionCenter__c firstDistributionCenter = (DistributionCenter__c)testFactory.createSObject(new DistributionCenter__c(
			Name = 'Test Distribution Center'
		));
        insert firstDistributionCenter;

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
			Name = 'Test first Account Group',
            AccountGroup__c = firstAccountGroup.Id,
            CNPJ__c = '00000000000000'
		));
        insert firstAccount;
    }

    @IsTest
    static void testInsertWithoutRequiredFieldsRules(){
        TestFactorySObject testFactory = TestFactorySObject.getInstance();

        ProductHierarchy__c firstProductHierarchy = [SELECT Id FROM ProductHierarchy__c LIMIT 1];
        Product2 firstProduct = [SELECT Id FROM Product2 LIMIT 1];
        DistributionCenter__c firstDistributionCenter = [SELECT Id FROM DistributionCenter__c LIMIT 1];
        Account firstAccount = [SELECT Id FROM Account LIMIT 1];
        AccountGroup__c firstAccountGroup = [SELECT Id FROM AccountGroup__c LIMIT 1];
        City__c firstCity = [SELECT Id FROM City__c LIMIT 1];
        State__c firstState = [SELECT Id FROM State__c LIMIT 1];
        Country__c firstCountry = [SELECT Id FROM Country__c LIMIT 1];

        Margin__c firstMargin = (Margin__c)testFactory.createSObject(new Margin__c(
			Name = 'Test first freight',
            DistributionCenter__c = firstDistributionCenter.Id,
            Status__c = 'Aprovado',
            Value__c = 0.00
		));
        Margin__c secondMargin = (Margin__c)testFactory.createSObject(new Margin__c(
			Name = 'Test second freight',
            ProductHierarchy__c = firstProductHierarchy.Id,
            Product__c = firstProduct.id,
            Account__c = firstAccount.Id,
            AccountGroup__c = firstAccountGroup.Id,
            DistributionCenter__c = firstDistributionCenter.Id,
            Status__c = 'Aprovado',
            Value__c = 0.00,
            City__c = firstCity.Id,
            State__c = firstState.Id,
            Country__c = firstCountry.Id
		));
        Margin__c thirdMargin = (Margin__c)testFactory.createSObject(new Margin__c(
			Name = 'Test third freight',
            Product__c = firstProduct.id,
            Account__c = firstAccount.Id,
            DistributionCenter__c = firstDistributionCenter.Id,
            Status__c = 'Aprovado',
            Value__c = 0.00,
            City__c = firstCity.Id,
            Country__c = firstCountry.Id
		));
        Margin__c fourthFreight = (Margin__c)testFactory.createSObject(new Margin__c(
			Name = 'Test fourth freight',
            Product__c = firstProduct.id,
            Account__c = firstAccount.Id,
            DistributionCenter__c = firstDistributionCenter.Id,
            Status__c = 'Aprovado',
            Value__c = 0.00,
            City__c = firstCity.Id,
            State__c = firstState.Id
		));
        Margin__c fifthFreight = (Margin__c)testFactory.createSObject(new Margin__c(
			Name = 'Test fifth freight',
            Product__c = firstProduct.id,
            Account__c = firstAccount.Id,
            DistributionCenter__c = firstDistributionCenter.Id,
            Status__c = 'Aprovado',
            Value__c = 0.00,
            State__c = firstState.Id,
            Country__c = firstCountry.Id
		));
        List<Margin__c> listToInsert = new List<Margin__c>{firstMargin, secondMargin, thirdMargin, fourthFreight, fifthFreight};
        List<Database.SaveResult> MarginsNotInserted = new List<Database.SaveResult>();

        Database.SaveResult[] MarginsWeWillTryToInsert = Database.insert(listToInsert, false);
        for(Database.SaveResult iMargin: MarginsWeWillTryToInsert){
            if(!iMargin.isSuccess()){
                MarginsNotInserted.add(iMargin);
            }
        }
        Assert.areEqual(5, MarginsNotInserted.size(), 'Error: five freights should not be inserted');
    }

    @IsTest
    static void testInsertAMarginThatAlreadyExistInDatabase(){
        TestFactorySObject testFactory = TestFactorySObject.getInstance();

        Product2 firstProduct = [SELECT Id FROM Product2 LIMIT 1];
        DistributionCenter__c firstDistributionCenter = [SELECT Id FROM DistributionCenter__c LIMIT 1];
        Account firstAccount = [SELECT Id FROM Account LIMIT 1];
        City__c firstCity = [SELECT Id FROM City__c LIMIT 1];

        Margin__c firstMargin = (Margin__c)testFactory.createSObject(new Margin__c(
			Name = 'Test first freight',
            Product__c = firstProduct.id,
            Account__c = firstAccount.Id,
            DistributionCenter__c = firstDistributionCenter.Id,
            Status__c = 'Aprovado',
            Value__c = 0.00,
            City__c = firstCity.Id
		));
        Margin__c secondMargin = (Margin__c)testFactory.createSObject(new Margin__c(
			Name = 'Test second freight',
            Product__c = firstProduct.id,
            Account__c = firstAccount.Id,
            DistributionCenter__c = firstDistributionCenter.Id,
            Status__c = 'Aprovado',
            Value__c = 0.00,
            City__c = firstCity.Id
		));

        Test.startTest();

		insert firstMargin;

        Database.SaveResult marginWeWillTryToInsert = Database.insert(secondMargin, false);

        Test.stopTest();

        Assert.isFalse(marginWeWillTryToInsert.isSuccess(), 'Error: Should not be able to insert a margin that already exist in database');
    }

    @IsTest
    static void testInsertTwoSameMarginsInSameTime(){
        TestFactorySObject testFactory = TestFactorySObject.getInstance(); 
        
        ProductHierarchy__c firstProductHierarchy = [SELECT Id FROM ProductHierarchy__c LIMIT 1];
        AccountGroup__c firstAccountGroup = [SELECT Id FROM AccountGroup__c LIMIT 1];
        DistributionCenter__c firstDistributionCenter = [SELECT Id FROM DistributionCenter__c LIMIT 1];
        City__c firstCity = [SELECT Id FROM City__c LIMIT 1];

        Margin__c firstMargin = (Margin__c)testFactory.createSObject(new Margin__c(
			Name = 'Test first freight',
            ProductHierarchy__c = firstProductHierarchy.Id,
            AccountGroup__c = firstAccountGroup.Id,
            DistributionCenter__c = firstDistributionCenter.Id,
            Status__c = 'Aprovado',
            Value__c = 0.00,
            City__c = firstCity.Id
		));
        Margin__c secondMargin = (Margin__c)testFactory.createSObject(new Margin__c(
			Name = 'Test second freight',
            ProductHierarchy__c = firstProductHierarchy.Id,
            AccountGroup__c = firstAccountGroup.Id,
            DistributionCenter__c = firstDistributionCenter.Id,
            Status__c = 'Aprovado',
            Value__c = 0.00,
            City__c = firstCity.Id
		));
        List<Margin__c> marginsToInsert = new List<Margin__c>{firstMargin, secondMargin};

        Test.startTest();

        Database.SaveResult[] marginsWeWillTryToInsert = Database.insert(marginsToInsert, false);

        Test.stopTest();

        List<Database.SaveResult> marginsNotInserted = new List<Database.SaveResult>();
        for(Database.SaveResult iMargin: marginsWeWillTryToInsert){
            if(!iMargin.isSuccess()){
                marginsNotInserted.add(iMargin);
            }
        }
        Assert.areEqual(1, marginsNotInserted.size(), 'Error: Should not be able to insert two margins with the same parameters, only one will be inserted');
    }

    @IsTest
    static void testUpdateAMarginButTheNewVersionAlreadyExist(){
        TestFactorySObject testFactory = TestFactorySObject.getInstance(); 
        
        ProductHierarchy__c firstProductHierarchy = [SELECT Id FROM ProductHierarchy__c LIMIT 1];
        AccountGroup__c firstAccountGroup = [SELECT Id FROM AccountGroup__c LIMIT 1];
        DistributionCenter__c firstDistributionCenter = [SELECT Id FROM DistributionCenter__c LIMIT 1];
        State__c firstState = [SELECT Id FROM State__c LIMIT 1];
        Country__c firstCountry = [SELECT Id FROM Country__c LIMIT 1];

        Margin__c firstMargin = (Margin__c)testFactory.createSObject(new Margin__c(
			Name = 'Test first freight',
            ProductHierarchy__c = firstProductHierarchy.Id,
            AccountGroup__c = firstAccountGroup.Id,
            DistributionCenter__c = firstDistributionCenter.Id,
            Status__c = 'Aprovado',
            Value__c = 0.00,
            State__c = firstState.Id
		));
        Margin__c secondMargin = (Margin__c)testFactory.createSObject(new Margin__c(
			Name = 'Test second freight',
            ProductHierarchy__c = firstProductHierarchy.Id,
            AccountGroup__c = firstAccountGroup.Id,
            DistributionCenter__c = firstDistributionCenter.Id,
            Status__c = 'Aprovado',
            Value__c = 0.00,
            Country__c = firstCountry.Id
		));
        List<Margin__c> marginsToInsert = new List<Margin__c>{firstMargin, secondMargin};

        Test.startTest();
        insert marginsToInsert;

        secondMargin.Country__c = null;
        secondMargin.State__c = firstState.Id;

        Database.SaveResult marginWeWillTryToUpdate = Database.Update(secondMargin, false);

        Test.stopTest();

        Assert.isFalse(marginWeWillTryToUpdate.isSuccess(), 'Error: Should not be able to update one margin with the same parameters of another margin');
    }
    @IsTest
    static void testUpdateTwoMarginsToSameCityAndAccountGroupAndProduct(){
        TestFactorySObject testFactory = TestFactorySObject.getInstance();

        ProductHierarchy__c firstProductHierarchy = [SELECT Id FROM ProductHierarchy__c LIMIT 1];
        Account firstAccount = [SELECT Id FROM Account LIMIT 1];
        DistributionCenter__c firstDistributionCenter = [SELECT Id FROM DistributionCenter__c LIMIT 1];
        City__c firstCity = [SELECT Id FROM City__c LIMIT 1];
        State__c firstState = [SELECT Id FROM State__c LIMIT 1];
        Country__c firstCountry = [SELECT Id FROM Country__c LIMIT 1];

        Margin__c firstMargin = (Margin__c)testFactory.createSObject(new Margin__c(
			Name = 'Test first freight',
            ProductHierarchy__c = firstProductHierarchy.Id,
            Account__c = firstAccount.Id,
            DistributionCenter__c = firstDistributionCenter.Id,
            Status__c = 'Aprovado',
            Value__c = 0.00,
            State__c = firstState.Id
		));
        Margin__c secondMargin = (Margin__c)testFactory.createSObject(new Margin__c(
			Name = 'Test second freight',
            ProductHierarchy__c = firstProductHierarchy.Id,
            Account__c = firstAccount.Id,
            DistributionCenter__c = firstDistributionCenter.Id,
            Status__c = 'Aprovado',
            Value__c = 0.00,
            Country__c = firstCountry.Id
		));
        List<Margin__c> marginsToInsert = new List<Margin__c>{firstMargin, secondMargin};

        Test.startTest();
        insert marginsToInsert;

        secondMargin.Country__c = null;
        firstMargin.State__c = null;
        secondMargin.City__c = firstCity.Id;
        firstMargin.City__c = firstCity.Id;

        List<Margin__c> marginsToUpdate = new List<Margin__c>{firstMargin, secondMargin};

        Database.SaveResult[] marginsWeWillTryToUpdate = Database.Update(marginsToUpdate, false);

        Test.stopTest();

        List<Database.SaveResult> marginsNotUpdated = new List<Database.SaveResult>();
        for(Database.SaveResult iMargin: marginsWeWillTryToUpdate){
            if(!iMargin.isSuccess()){
                marginsNotUpdated.add(iMargin);
            }
        }
        Assert.areEqual(1, marginsNotUpdated.size(), 'Error: Should not be able to update one margin with the same parameters of another margin, only one will be updated');
    }
}