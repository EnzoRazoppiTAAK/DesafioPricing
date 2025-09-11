@IsTest
public with sharing class FreightTrigger_Test {
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
	
    }

    @IsTest
    static void testInsertWithoutRequiredFieldsRules(){
        TestFactorySObject testFactory = TestFactorySObject.getInstance();

        ProductHierarchy__c firstProductHierarchy = [SELECT Id FROM ProductHierarchy__c LIMIT 1];
        Product2 firstProduct = [SELECT Id FROM Product2 LIMIT 1];
        DistributionCenter__c firstDistributionCenter = [SELECT Id FROM DistributionCenter__c LIMIT 1];
        City__c firstCity = [SELECT Id FROM City__c LIMIT 1];
        State__c firstState = [SELECT Id FROM State__c LIMIT 1];
        Country__c firstCountry = [SELECT Id FROM Country__c LIMIT 1];

        Freight__c firstFreight = (Freight__c)testFactory.createSObject(new Freight__c(
			Name = 'Test first freight',
            DistributionCenter__c = firstDistributionCenter.Id,
            Status__c = 'Aprovado',
            Value__c = 0.00
		));
        Freight__c secondFreight = (Freight__c)testFactory.createSObject(new Freight__c(
			Name = 'Test second freight',
            ProductHierarchy__c = firstProductHierarchy.Id,
            Product__c = firstProduct.id,
            DistributionCenter__c = firstDistributionCenter.Id,
            Status__c = 'Aprovado',
            Value__c = 0.00,
            City__c = firstCity.Id,
            State__c = firstState.Id,
            Country__c = firstCountry.Id
		));
        Freight__c thirdFreight = (Freight__c)testFactory.createSObject(new Freight__c(
			Name = 'Test third freight',
            Product__c = firstProduct.id,
            DistributionCenter__c = firstDistributionCenter.Id,
            Status__c = 'Aprovado',
            Value__c = 0.00,
            City__c = firstCity.Id,
            Country__c = firstCountry.Id
		));
        Freight__c fourthFreight = (Freight__c)testFactory.createSObject(new Freight__c(
			Name = 'Test fourth freight',
            Product__c = firstProduct.id,
            DistributionCenter__c = firstDistributionCenter.Id,
            Status__c = 'Aprovado',
            Value__c = 0.00,
            City__c = firstCity.Id,
            State__c = firstState.Id
		));
        Freight__c fifthFreight = (Freight__c)testFactory.createSObject(new Freight__c(
			Name = 'Test fifth freight',
            Product__c = firstProduct.id,
            DistributionCenter__c = firstDistributionCenter.Id,
            Status__c = 'Aprovado',
            Value__c = 0.00,
            State__c = firstState.Id,
            Country__c = firstCountry.Id
		));
        List<Freight__c> listToInsert = new List<Freight__c>{firstFreight, secondFreight, thirdFreight, fourthFreight, fifthFreight};
        List<Database.SaveResult> freightsNotInserted = new List<Database.SaveResult>();

        Database.SaveResult[] freightsWeWillTryToInsert = Database.insert(listToInsert, false);
        for(Database.SaveResult iFreight: freightsWeWillTryToInsert){
            if(!iFreight.isSuccess()){
                freightsNotInserted.add(iFreight);
            }
        }
        Assert.areEqual(5, freightsNotInserted.size(), 'Error: five freights should not be inserted');

    }

    @IsTest
    static void testInsertAFreightThatAlreadyExistInDatabase(){
        TestFactorySObject testFactory = TestFactorySObject.getInstance();

        Product2 firstProduct = [SELECT Id FROM Product2 LIMIT 1];
        DistributionCenter__c firstDistributionCenter = [SELECT Id FROM DistributionCenter__c LIMIT 1];
        City__c firstCity = [SELECT Id FROM City__c LIMIT 1];

        Freight__c firstFreight = (Freight__c)testFactory.createSObject(new Freight__c(
			Name = 'Test first freight',
            Product__c = firstProduct.id,
            DistributionCenter__c = firstDistributionCenter.Id,
            Status__c = 'Aprovado',
            Value__c = 0.00,
            City__c = firstCity.Id
		));
        Freight__c secondFreight = (Freight__c)testFactory.createSObject(new Freight__c(
			Name = 'Test second freight',
            Product__c = firstProduct.id,
            DistributionCenter__c = firstDistributionCenter.Id,
            Status__c = 'Aprovado',
            Value__c = 0.00,
            City__c = firstCity.Id
		));

        Test.startTest();

		insert firstFreight;

        Database.SaveResult freightWeWillTryToInsert = Database.insert(secondFreight, false);
        Test.stopTest();

        Assert.isFalse(freightWeWillTryToInsert.isSuccess(), 'Error: Should not be able to insert a freight that already exist in database');
    }

    @IsTest
    static void testInsertTwoSameFreightsInSameTime(){
        TestFactorySObject testFactory = TestFactorySObject.getInstance();
        
        ProductHierarchy__c firstProductHierarchy = [SELECT Id FROM ProductHierarchy__c LIMIT 1];
        DistributionCenter__c firstDistributionCenter = [SELECT Id FROM DistributionCenter__c LIMIT 1];
        City__c firstCity = [SELECT Id FROM City__c LIMIT 1];

        Freight__c firstFreight = (Freight__c)testFactory.createSObject(new Freight__c(
			Name = 'Test first freight',
            ProductHierarchy__c = firstProductHierarchy.Id,
            DistributionCenter__c = firstDistributionCenter.Id,
            Status__c = 'Aprovado',
            Value__c = 0.00,
            City__c = firstCity.Id
		));
        Freight__c secondFreight = (Freight__c)testFactory.createSObject(new Freight__c(
			Name = 'Test second freight',
            ProductHierarchy__c = firstProductHierarchy.Id,
            DistributionCenter__c = firstDistributionCenter.Id,
            Status__c = 'Aprovado',
            Value__c = 0.00,
            City__c = firstCity.Id
		));
        List<Freight__c> freightsToInsert = new List<Freight__c>{firstFreight, secondFreight};

        Test.startTest();

        Database.SaveResult[] freightsWeWillTryToInsert = Database.insert(freightsToInsert, false);

        Test.stopTest();

        List<Database.SaveResult> freightsNotInserted = new List<Database.SaveResult>();
        for(Database.SaveResult iFreight: freightsWeWillTryToInsert){
            if(!iFreight.isSuccess()){
                freightsNotInserted.add(iFreight);
            }
        }
        Assert.areEqual(1, freightsNotInserted.size(), 'Error: Should not be able to insert two freights with the same parameters, only one will be inserted');
    }

    @IsTest
    static void testUpdateAFreightButTheNewVersionAlreadyExist(){
        TestFactorySObject testFactory = TestFactorySObject.getInstance();
        
        ProductHierarchy__c firstProductHierarchy = [SELECT Id FROM ProductHierarchy__c LIMIT 1];
        Product2 firstProduct = [SELECT Id FROM Product2 LIMIT 1];
        DistributionCenter__c firstDistributionCenter = [SELECT Id FROM DistributionCenter__c LIMIT 1];
        State__c firstState = [SELECT Id FROM State__c LIMIT 1];
        Country__c firstCountry = [SELECT Id FROM Country__c LIMIT 1];

        Freight__c firstFreight = (Freight__c)testFactory.createSObject(new Freight__c(
			Name = 'Test first freight',
            Product__c = firstProduct.id,
            DistributionCenter__c = firstDistributionCenter.Id,
            Status__c = 'Aprovado',
            Value__c = 0.00,
            Country__c = firstCountry.Id
		));
        Freight__c secondFreight = (Freight__c)testFactory.createSObject(new Freight__c(
			Name = 'Test second freight',
            ProductHierarchy__c = firstProductHierarchy.Id,
            DistributionCenter__c = firstDistributionCenter.Id,
            Status__c = 'Aprovado',
            Value__c = 0.00,
            State__c = firstState.Id
		));
        List<Freight__c> freightsToInsert = new List<Freight__c>{firstFreight, secondFreight};

        Test.startTest();
        insert freightsToInsert;

        secondFreight.ProductHierarchy__c = null;
        secondFreight.Product__c = firstProduct.Id;
        secondFreight.State__c = null;
        secondFreight.Country__c = firstCountry.Id;

        Database.SaveResult freightWeWillTryToUpdate = Database.Update(secondFreight, false);

        Test.stopTest();

        Assert.isFalse(freightWeWillTryToUpdate.isSuccess(), 'Error: Should not be able to update one freight with the same parameters of another freight');
    }

    @IsTest
    static void testUpdateTwoFreghtsToSameCityAndProduct(){
        TestFactorySObject testFactory = TestFactorySObject.getInstance();

        ProductHierarchy__c firstProductHierarchy = [SELECT Id FROM ProductHierarchy__c LIMIT 1];
        List<Product2> productsList = [SELECT Id FROM Product2 LIMIT 2];
        DistributionCenter__c firstDistributionCenter = [SELECT Id FROM DistributionCenter__c LIMIT 1];
        City__c firstCity = [SELECT Id FROM City__c LIMIT 1];
        State__c firstState = [SELECT Id FROM State__c LIMIT 1];
        Country__c firstCountry = [SELECT Id FROM Country__c LIMIT 1];

        Freight__c firstFreight = (Freight__c)testFactory.createSObject(new Freight__c(
		    Name = 'Test first freight',
            ProductHierarchy__c = firstProductHierarchy.Id,
            DistributionCenter__c = firstDistributionCenter.Id,
            Status__c = 'Aprovado',
            Value__c = 0.00,
            Country__c = firstCountry.Id
		));
        Freight__c secondFreight = (Freight__c)testFactory.createSObject(new Freight__c(
			Name = 'Test second freight',
            Product__c = productsList.get(0).id,
            DistributionCenter__c = firstDistributionCenter.Id,
            Status__c = 'Aprovado',
            Value__c = 0.00,
            State__c = firstState.Id
		));

        List<Freight__c> freightsToInsert = new List<Freight__c>{firstFreight, secondFreight};

        Test.startTest();
        insert freightsToInsert;

        firstFreight.ProductHierarchy__c = null;
        firstFreight.Product__c = productsList.get(1).Id;
        secondFreight.Product__c = productsList.get(1).Id;
        firstFreight.Country__c = null;
        secondFreight.State__c = null;
        firstFreight.City__c = firstCity.Id;
        secondFreight.City__c = firstCity.Id;
        List<Freight__c> freightsToUpdate = new List<Freight__c>{firstFreight, secondFreight};

        Database.SaveResult[] freightWeWillTryToUpdate = Database.Update(freightsToUpdate, false);

        Test.stopTest();

        List<Database.SaveResult> freightsNotUpdated = new List<Database.SaveResult>();
        for(Database.SaveResult iFreight: freightWeWillTryToUpdate){
            if(!iFreight.isSuccess()){
                freightsNotUpdated.add(iFreight);
            }
        }

        Assert.areEqual(1, freightsNotUpdated.size(), 'Error: Should not be able to update one freight with the same parameters of another freight, only one will be updated');
    }
}