public with sharing class MarginTriggerHelper {
    public static void handleInsertMargin(List<Margin__c> newRecordList){
        Map<String, Margin__c> mapMargin = new Map<String, Margin__c>();
        for(Margin__c iMargin: newRecordList){
            String marginKey = iMargin.Product__c+'-'+iMargin.ProductHierarchy__c+'-'+iMargin.Account__c+'-'+iMargin.AccountGroup__c+'-'+
            iMargin.City__c+'-'+iMargin.State__c+'-'+iMargin.Country__c;

            if(mapMargin.containsKey(marginKey)){
                iMargin.addError('Já existe uma margem com esses dados');
            }else{
                mapMargin.put(marginKey, iMargin);
            }
        }
        Set<Id> productsIds = new Set<Id>();
        Set<Id> productsHierarchyIds = new Set<Id>();
        Set<Id> accountsIds = new Set<Id>();
        Set<Id> accountsGrupsIds = new Set<Id>();
        Set<Id> citiesIds = new Set<Id>();
        Set<Id> statesIds = new Set<Id>();
        Set<Id> countriesIds = new Set<Id>();
        Set<Id> distributionCenterIds = new Set<Id>();
        for(Margin__c iMargin: newRecordList){
            productsIds.add(iMargin.Product__c);
            productsHierarchyIds.add(iMargin.ProductHierarchy__c);
            accountsIds.add(iMargin.Account__c);
            accountsGrupsIds.add(iMargin.AccountGroup__c);
            citiesIds.add(iMargin.City__c);
            statesIds.add(iMargin.State__c);
            countriesIds.add(iMargin.Country__c);
            distributionCenterIds.add(iMargin.DistributionCenter__c);
        }
        List<Margin__c> marginsInDatabase = [
            SELECT Id, Product__c, ProductHierarchy__c, Account__c, AccountGroup__c, City__c, State__c, Country__c, DistributionCenter__c 
            FROM Margin__c 
            WHERE Product__c IN :productsIds
            OR ProductHierarchy__c IN :productsHierarchyIds
            OR Account__c IN :accountsIds
            OR AccountGroup__c IN :accountsGrupsIds
            OR City__c IN :citiesIds
            OR State__c IN :statesIds
            OR Country__c IN :countriesIds
            OR DistributionCenter__c IN :distributionCenterIds
        ];
        for(Margin__c iMargin: marginsInDatabase){
            String marginKey = iMargin.Product__c+'-'+iMargin.ProductHierarchy__c+'-'+iMargin.Account__c+'-'+iMargin.AccountGroup__c+'-'+
            iMargin.City__c+'-'+iMargin.State__c+'-'+iMargin.Country__c;
            if(mapMargin.containsKey(marginKey)){
                mapMargin.get(marginKey).addError('Já existe uma margem com esses dados');
            }
        }
    }
    public static void handleUpdateMargin(List<Margin__c> newRecordList){
        Map<String, Margin__c> mapMargin = new Map<String, Margin__c>();
        for(Margin__c iMargin: newRecordList){
            String marginKey = iMargin.Product__c+'-'+iMargin.ProductHierarchy__c+'-'+iMargin.Account__c+'-'+iMargin.AccountGroup__c+'-'+
            iMargin.City__c+'-'+iMargin.State__c+'-'+iMargin.Country__c;

            if(mapMargin.containsKey(marginKey)){
                iMargin.addError('Já existe uma margem com esses dados');
            }else{
                mapMargin.put(marginKey, iMargin);
            }
        }
        Set<Id> productsIds = new Set<Id>();
        Set<Id> productsHierarchyIds = new Set<Id>();
        Set<Id> accountsIds = new Set<Id>();
        Set<Id> accountsGrupsIds = new Set<Id>();
        Set<Id> citiesIds = new Set<Id>();
        Set<Id> statesIds = new Set<Id>();
        Set<Id> countriesIds = new Set<Id>();
        Set<Id> distributionCenterIds = new Set<Id>();
        for(Margin__c iMargin: newRecordList){
            productsIds.add(iMargin.Product__c);
            productsHierarchyIds.add(iMargin.ProductHierarchy__c);
            accountsIds.add(iMargin.Account__c);
            accountsGrupsIds.add(iMargin.AccountGroup__c);
            citiesIds.add(iMargin.City__c);
            statesIds.add(iMargin.State__c);
            countriesIds.add(iMargin.Country__c);
            distributionCenterIds.add(iMargin.DistributionCenter__c);
        }
        List<Margin__c> marginsInDatabase = [
            SELECT Id, Product__c, ProductHierarchy__c, Account__c, AccountGroup__c, City__c, State__c, Country__c, DistributionCenter__c 
            FROM Margin__c 
            WHERE Product__c IN :productsIds
            OR ProductHierarchy__c IN :productsHierarchyIds
            OR Account__c IN :accountsIds
            OR AccountGroup__c IN :accountsGrupsIds
            OR City__c IN :citiesIds
            OR State__c IN :statesIds
            OR Country__c IN :countriesIds
            OR DistributionCenter__c IN :distributionCenterIds
        ];
        for(Margin__c iMargin: marginsInDatabase){
            String marginKey = iMargin.Product__c+'-'+iMargin.ProductHierarchy__c+'-'+iMargin.Account__c+'-'+iMargin.AccountGroup__c+'-'+
            iMargin.City__c+'-'+iMargin.State__c+'-'+iMargin.Country__c;
            if(mapMargin.containsKey(marginKey)){
                if(iMargin.Id != mapMargin.get(marginKey).Id){
                    mapMargin.get(marginKey).addError('Já existe uma margem com esses dados');
                }
            }
        }
    }
}