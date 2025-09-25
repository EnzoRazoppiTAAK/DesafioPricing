@IsTest
public with sharing class TaxTrigger_Test {
    @TestSetup
    static void makeData() {
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
        Product2 thirdProduct = (Product2)testFactory.createSObject(new Product2(
			Name = 'Test third Product',
			IsActive = true,
            ProductionCost__c = 0.00d,
            ProductHierarchy__c = firstProductHierarchy.Id
		));
        List<Product2> productsToInsert = new List<Product2>{firstProduct, secondProduct, thirdProduct};
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
        State__c secondState = (State__c)testFactory.createSObject(new State__c(
			Name = 'Test second State',
            Acronym__c = 'TS2',
            Country__c = firstCountry.Id
		));
        State__c thirdState = (State__c)testFactory.createSObject(new State__c(
			Name = 'Test third State',
            Acronym__c = 'TS3',
            Country__c = firstCountry.Id
		));
        List<State__c> statesToInsert = new List<State__c>{firstState, secondState, thirdState};
        insert statesToInsert;
	
	}
    @IsTest
    static void testInsertATaxThatAlreadyExistInDatabase(){
        TestFactorySObject testFactory = TestFactorySObject.getInstance();

        Product2 firstProduct = [SELECT Id FROM Product2 LIMIT 1];
        DistributionCenter__c firstDistributionCenter = [SELECT Id FROM DistributionCenter__c LIMIT 1];
        State__c firstState = [SELECT Id FROM State__c LIMIT 1];


        Tax__c firstTax = (Tax__c)testFactory.createSObject(new Tax__c(
			Name = 'Test Tax',
            Product__c = firstProduct.Id,
            DistributionCenter__c = firstDistributionCenter.Id,
            TaxOnCost__c = 0.00d,
            Status__c = 'Aprovado',
            State__c = firstState.Id
		));
        Tax__c secondTax = (Tax__c)testFactory.createSObject(new Tax__c(
			Name = 'Test Tax',
            Product__c = firstProduct.Id,
            DistributionCenter__c = firstDistributionCenter.Id,
            TaxOnCost__c = 0.00d,
            Status__c = 'Aprovado',
            State__c = firstState.Id
		));
        Test.startTest();

		insert firstTax;

        Database.SaveResult taxWeWillTryToInsert = Database.insert(secondTax, false);
        Test.stopTest();

        Assert.isFalse(taxWeWillTryToInsert.isSuccess() , 'Error: Should not be able to insert two taxes with the same parameters');
    }

    @IsTest
    static void testInsertTwoSameTaxesInSameTime(){
        TestFactorySObject testFactory = TestFactorySObject.getInstance();
        
        Product2 firstProduct = [SELECT Id FROM Product2 LIMIT 1];
        DistributionCenter__c firstDistributionCenter = [SELECT Id FROM DistributionCenter__c LIMIT 1];
        State__c firstState = [SELECT Id FROM State__c LIMIT 1];

        List<Tax__c> taxesToInsert = new List<Tax__c>();
        Tax__c taxOne = (Tax__c)testFactory.createSObject(new Tax__c(
			Name = 'Test Tax',
            Product__c = firstProduct.Id,
            DistributionCenter__c = firstDistributionCenter.Id,
            TaxOnCost__c = 0.00d,
            Status__c = 'Aprovado',
            State__c = firstState.Id
		));
        Tax__c taxTwo = (Tax__c)testFactory.createSObject(new Tax__c(
			Name = 'Test Tax',
            Product__c = firstProduct.Id,
            DistributionCenter__c = firstDistributionCenter.Id,
            TaxOnCost__c = 0.00d,
            Status__c = 'Aprovado',
            State__c = firstState.Id
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

        Assert.areEqual(1, taxesNotInserted.size(), 'Error: Should not be able to insert two taxes with the same parameters, only one will be inserted');
    }

    @IsTest
    static void testUpdateATaxButTheNewVersionAlreadyExist(){
        TestFactorySObject testFactory = TestFactorySObject.getInstance();

        List<Product2> productList = [SELECT Id FROM Product2 LIMIT 2];
        List<State__c> statesList = [SELECT Id FROM State__c LIMIT 2];
        DistributionCenter__c firstDistributionCenter = [SELECT Id FROM DistributionCenter__c LIMIT 1];
        
        Tax__c firstTax= (Tax__c)testFactory.createSObject(new Tax__c(
			Name = 'Test Tax',
            Product__c = productList.get(0).Id,
            DistributionCenter__c = firstDistributionCenter.Id,
            TaxOnCost__c = 0.00d,
            Status__c = 'Aprovado',
            State__c = statesList.get(0).Id
		));
        Tax__c secondTax = (Tax__c)testFactory.createSObject(new Tax__c(
			Name = 'Test Tax',
            Product__c = productList.get(1).Id,
            DistributionCenter__c = firstDistributionCenter.Id,
            TaxOnCost__c = 0.00d,
            Status__c = 'Aprovado',
            State__c = statesList.get(1).Id
		));
        List<Tax__c> taxesToInsert = new List<Tax__c>{firstTax, secondTax};

        Test.startTest();
		insert taxesToInsert;

        secondTax.Product__c = productList.get(0).Id;
        secondTax.State__c = statesList.get(0).Id;

        Database.SaveResult taxWeWillTryToUpdate = Database.Update(secondTax, false);
        Test.stopTest();

        Assert.isFalse(taxWeWillTryToUpdate.isSuccess() , 'Error: Should not be able to have two taxes with the same parameters'); 
    }

    @IsTest
    static void testUpdateTwoTaxesToSameStateAndProduct(){
        TestFactorySObject testFactory = TestFactorySObject.getInstance();

        List<Product2> productList = [SELECT Id FROM Product2 LIMIT 3];
        List<State__c> statesList = [SELECT Id FROM State__c LIMIT 3];
        DistributionCenter__c firstDistributionCenter = [SELECT Id FROM DistributionCenter__c LIMIT 1];
        
        Tax__c firstTax = (Tax__c)testFactory.createSObject(new Tax__c(
			Name = 'Test Tax',
            Product__c = productList.get(0).Id,
            DistributionCenter__c = firstDistributionCenter.Id,
            TaxOnCost__c = 0.00d,
            Status__c = 'Aprovado',
            State__c = statesList.get(0).Id
		));
        Tax__c secondTax = (Tax__c)testFactory.createSObject(new Tax__c(
			Name = 'Test Tax',
            Product__c = productList.get(1).Id,
            DistributionCenter__c = firstDistributionCenter.Id,
            TaxOnCost__c = 0.00d,
            Status__c = 'Aprovado',
            State__c = statesList.get(1).Id
		));
        List<Tax__c> taxesToInsert = new List<Tax__c>{firstTax, secondTax};

        Test.startTest();
		insert taxesToInsert;

        firstTax.Product__c = productList.get(2).Id;
        firstTax.State__c = statesList.get(2).Id;
        secondTax.Product__c = productList.get(2).Id;
        secondTax.State__c = statesList.get(2).Id;
        List<Tax__c> taxesToUpdate = new List<Tax__c>{firstTax, secondTax};

        List<Database.SaveResult> taxesNotUpdated = new List<Database.SaveResult>();
        Database.SaveResult[] taxesWeWillTryToInsert = Database.Update(taxesToUpdate, false);
        for (Database.SaveResult iTax : taxesWeWillTryToInsert) {
            if (!iTax.isSuccess()) {       
                taxesNotUpdated.add(iTax);
            }
        }
        Test.stopTest();

        Assert.areEqual(1, taxesNotUpdated.size(), 'Error: Should not be able to have two taxes with the same parameters, only one will be updated');
    }
}