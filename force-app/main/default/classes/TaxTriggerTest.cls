@IsTest
public with sharing class TaxTriggerTest {
    @TestSetup
    static void makeData() {
		TestFactorySObject testFactory = TestFactorySObject.getInstance();

        ProductHierarchy__c mainProductHierarchy = (ProductHierarchy__c)testFactory.createSObject(new ProductHierarchy__c(
			Name = 'Test main ProductHierarchy'
		));
        insert mainProductHierarchy;
        
        Product2 mainProduct = (Product2)testFactory.createSObject(new Product2(
			Name = 'Test main Product',
			IsActive = true,
            ProductionCost__c = 0.00d,
            ProductHierarchy__c = mainProductHierarchy.Id
		));
        Product2 secondProduct = (Product2)testFactory.createSObject(new Product2(
			Name = 'Test second Product',
			IsActive = true,
            ProductionCost__c = 0.00d,
            ProductHierarchy__c = mainProductHierarchy.Id
		));
        Product2 thirdProduct = (Product2)testFactory.createSObject(new Product2(
			Name = 'Test third Product',
			IsActive = true,
            ProductionCost__c = 0.00d,
            ProductHierarchy__c = mainProductHierarchy.Id
		));
        List<Product2> productsToInsert = new List<Product2>{mainProduct, secondProduct, thirdProduct};
        insert productsToInsert;

        DistributionCenter__c mainDistributionCenter = (DistributionCenter__c)testFactory.createSObject(new DistributionCenter__c(
			Name = 'Test Distribution Center'
		));
        insert mainDistributionCenter;

        Country__c mainCountry = (Country__c)testFactory.createSObject(new Country__c(
			Name = 'Test Country',
            Acronym__c = 'CR'
		));
        insert mainCountry;

        State__c mainState = (State__c)testFactory.createSObject(new State__c(
			Name = 'Test main State',
            Acronym__c = 'TS1',
            Country__c = mainCountry.Id
		));
        State__c secondState = (State__c)testFactory.createSObject(new State__c(
			Name = 'Test second State',
            Acronym__c = 'TS2',
            Country__c = mainCountry.Id
		));
        State__c thirdState = (State__c)testFactory.createSObject(new State__c(
			Name = 'Test third State',
            Acronym__c = 'TS3',
            Country__c = mainCountry.Id
		));
        List<State__c> statesToInsert = new List<State__c>{mainState, secondState, thirdState};
        insert statesToInsert;
	
	}
    @IsTest
    static void testInsertATaxThatAlreadyExistInDatabase(){
        TestFactorySObject testFactory = TestFactorySObject.getInstance();

        Product2 mainProduct = [SELECT Id FROM Product2 LIMIT 1];
        DistributionCenter__c mainDistributionCenter = [SELECT Id FROM DistributionCenter__c LIMIT 1];
        State__c mainState = [SELECT Id FROM State__c LIMIT 1];


        Tax__c firstTaxToInsert = (Tax__c)testFactory.createSObject(new Tax__c(
			Name = 'Test Tax',
            Product__c = mainProduct.Id,
            DistributionCenter__c = mainDistributionCenter.Id,
            TaxOnCost__c = 0.00d,
            Status__c = 'Aprovado',
            State__c = mainState.Id
		));
        Test.startTest();

		insert firstTaxToInsert;
        Tax__c secondTaxToInsert = (Tax__c)testFactory.createSObject(new Tax__c(
			Name = 'Test Tax',
            Product__c = mainProduct.Id,
            DistributionCenter__c = mainDistributionCenter.Id,
            TaxOnCost__c = 0.00d,
            Status__c = 'Aprovado',
            State__c = mainState.Id
		));

        Database.SaveResult taxWeWillTryToInsert = Database.insert(secondTaxToInsert, false);
        Test.stopTest();

        Assert.isFalse(taxWeWillTryToInsert.isSuccess() , 'Should not be able to insert two taxes with the same parameters');
    }

    @IsTest
    static void testInsertTwoSameTaxesInSameTime(){
        TestFactorySObject testFactory = TestFactorySObject.getInstance();
        
        Product2 mainProduct = [SELECT Id FROM Product2 LIMIT 1];
        DistributionCenter__c mainDistributionCenter = [SELECT Id FROM DistributionCenter__c LIMIT 1];
        State__c mainState = [SELECT Id FROM State__c LIMIT 1];

        List<Tax__c> taxesToInsert = new List<Tax__c>();
        Tax__c taxOne = (Tax__c)testFactory.createSObject(new Tax__c(
			Name = 'Test Tax',
            Product__c = mainProduct.Id,
            DistributionCenter__c = mainDistributionCenter.Id,
            TaxOnCost__c = 0.00d,
            Status__c = 'Aprovado',
            State__c = mainState.Id
		));
        Tax__c taxTwo = (Tax__c)testFactory.createSObject(new Tax__c(
			Name = 'Test Tax',
            Product__c = mainProduct.Id,
            DistributionCenter__c = mainDistributionCenter.Id,
            TaxOnCost__c = 0.00d,
            Status__c = 'Aprovado',
            State__c = mainState.Id
		));

        taxesToInsert.add(taxOne);
        taxesToInsert.add(taxTwo);

        List<Database.SaveResult> taxesNotInserted = new List<Database.SaveResult>();

        Test.startTest();
        Database.SaveResult[] taxesWeWillTryToInsert = Database.insert(taxesToInsert, false);
        for (Database.SaveResult iTax : taxesWeWillTryToInsert) {
            if (!iTax.isSuccess()) {       
                taxesNotInserted.add(iTax);
            }
        }
        Test.stopTest();

        Assert.areEqual(1, taxesNotInserted.size(), 'Should not be able to insert two taxes with the same parameters');
    }

    @IsTest
    static void testUpdateATaxButTheNewVersionAlreadyExist(){
        TestFactorySObject testFactory = TestFactorySObject.getInstance();

        List<Product2> productList = [SELECT Id FROM Product2 LIMIT 2];
        List<State__c> statesList = [SELECT Id FROM State__c LIMIT 2];
        DistributionCenter__c mainDistributionCenter = [SELECT Id FROM DistributionCenter__c LIMIT 1];
        
        Tax__c firstTaxToInsert = (Tax__c)testFactory.createSObject(new Tax__c(
			Name = 'Test Tax',
            Product__c = productList.get(0).Id,
            DistributionCenter__c = mainDistributionCenter.Id,
            TaxOnCost__c = 0.00d,
            Status__c = 'Aprovado',
            State__c = statesList.get(0).Id
		));
        Tax__c secondTaxToInsert = (Tax__c)testFactory.createSObject(new Tax__c(
			Name = 'Test Tax',
            Product__c = productList.get(1).Id,
            DistributionCenter__c = mainDistributionCenter.Id,
            TaxOnCost__c = 0.00d,
            Status__c = 'Aprovado',
            State__c = statesList.get(1).Id
		));
        List<Tax__c> taxesToInsert = new List<Tax__c>{firstTaxToInsert, secondTaxToInsert};

        Test.startTest();
		insert taxesToInsert;

        secondTaxToInsert.Product__c = productList.get(0).Id;
        secondTaxToInsert.State__c = statesList.get(0).Id;

        Database.SaveResult taxWeWillTryToUpdate = Database.Update(secondTaxToInsert, false);
        Test.stopTest();

        Assert.isFalse(taxWeWillTryToUpdate.isSuccess() , 'Should not be able to insert two taxes with the same parameters'); //mudar isso
    }
    @IsTest
    static void testUpdateTwoTaxesToSameStateAndProduct(){
        TestFactorySObject testFactory = TestFactorySObject.getInstance();

        List<Product2> productList = [SELECT Id FROM Product2 LIMIT 3];
        List<State__c> statesList = [SELECT Id FROM State__c LIMIT 3];
        DistributionCenter__c mainDistributionCenter = [SELECT Id FROM DistributionCenter__c LIMIT 1];
        
        Tax__c firstTaxToInsert = (Tax__c)testFactory.createSObject(new Tax__c(
			Name = 'Test Tax',
            Product__c = productList.get(0).Id,
            DistributionCenter__c = mainDistributionCenter.Id,
            TaxOnCost__c = 0.00d,
            Status__c = 'Aprovado',
            State__c = statesList.get(0).Id
		));
        Tax__c secondTaxToInsert = (Tax__c)testFactory.createSObject(new Tax__c(
			Name = 'Test Tax',
            Product__c = productList.get(1).Id,
            DistributionCenter__c = mainDistributionCenter.Id,
            TaxOnCost__c = 0.00d,
            Status__c = 'Aprovado',
            State__c = statesList.get(1).Id
		));
        List<Tax__c> taxesToInsert = new List<Tax__c>{firstTaxToInsert, secondTaxToInsert};

        Test.startTest();
		insert taxesToInsert;

        firstTaxToInsert.Product__c = productList.get(2).Id;
        firstTaxToInsert.State__c = statesList.get(2).Id;
        secondTaxToInsert.Product__c = productList.get(2).Id;
        secondTaxToInsert.State__c = statesList.get(2).Id;
        List<Tax__c> taxesToUpdate = new List<Tax__c>{firstTaxToInsert, secondTaxToInsert};

        List<Database.SaveResult> taxesNotUpdated = new List<Database.SaveResult>();
        Database.SaveResult[] taxesWeWillTryToInsert = Database.insert(taxesToUpdate, false);
        for (Database.SaveResult iTax : taxesWeWillTryToInsert) {
            if (!iTax.isSuccess()) {       
                taxesNotUpdated.add(iTax);
            }
        }
        Test.stopTest();

        Assert.areEqual(1, taxesNotUpdated.size(), 'Should not be able to insert two taxes with the same parameters');
    }
}