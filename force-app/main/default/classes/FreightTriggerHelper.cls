public with sharing class FreightTriggerHelper {
    public static void handleInsertFreight(List<Freight__c> newRecordList){
        verifyDuplicates(newRecordList);
    }

    public static void handleUpdateFreight(List<Freight__c> newRecordList){
        verifyDuplicates(newRecordList);
    }

    public static void verifyDuplicates(List<Freight__c> newRecordList){
        Map<String, Freight__c> newFreightMap = new Map<String, Freight__c>();
        for(Freight__c iFreight: newRecordList){
            String freightKey = iFreight.Product__c+'-'+iFreight.ProductHierarchy__c+'-'+iFreight.City__c+'-'+iFreight.State__c+'-'+iFreight.Country__c+'-'+iFreight.DistributionCenter__c;
            if(newFreightMap.containsKey(freightKey)){
                iFreight.addError('Já existe um frete com esses dados');
            }else{
                newFreightMap.put(freightKey, iFreight);
            }
        }

        Set<Id> productsIds = new Set<Id>();
        Set<Id> productsHierarchyIds = new Set<Id>();
        Set<Id> citiesIds = new Set<Id>();
        Set<Id> statesIds = new Set<Id>();
        Set<Id> countriesIds = new Set<Id>();
        Set<Id> distributionCentersIds = new Set<Id>();
        for(Freight__c iFreight: newRecordList){
            productsIds.add(iFreight.Product__c);
            productsHierarchyIds.add(iFreight.ProductHierarchy__c);
            citiesIds.add(iFreight.City__c);
            statesIds.add(iFreight.State__c);
            countriesIds.add(iFreight.Country__c);
            distributionCentersIds.add(iFreight.DistributionCenter__c);
        }

        List<Freight__c> freightsInDatabase = [
            SELECT Id, Product__c, ProductHierarchy__c, City__c, State__c, Country__c, DistributionCenter__c
            FROM Freight__c 
            WHERE Product__c IN :productsIds
            OR ProductHierarchy__c IN :productsHierarchyIds
            OR City__c IN :citiesIds
            OR State__c IN :statesIds
            OR Country__c IN :countriesIds
            OR DistributionCenter__c IN :distributionCentersIds
        ];

        for(Freight__c iFreight: freightsInDatabase){
            String freightKey = iFreight.Product__c+'-'+iFreight.ProductHierarchy__c+'-'+iFreight.City__c+'-'+iFreight.State__c+'-'+iFreight.Country__c+'-'+iFreight.DistributionCenter__c;
            if(newFreightMap.containsKey(freightKey)){
                if(iFreight.Id != newFreightMap.get(freightKey).Id){
                    newFreightMap.get(freightKey).addError('Já existe um frete com esses dados');
                }
            }
        }
    }
    public static void FreightsRequiredFields(List<Freight__c> newRecordList){
        for(Freight__c iFreight: newRecordList){
            if(iFreight.Product__c == null && iFreight.ProductHierarchy__c == null){
                iFreight.addError('Adicione um Produto ou uma Hierarquia de Produto!');
            }
            if(iFreight.Product__c != null && iFreight.ProductHierarchy__c != null){
                iFreight.addError('Os campos Produto e Hierarquia de Produto não podem ser especificados ao mesmo tempo. Por favor, remova um deles.');
            }
            if(iFreight.City__c == null && iFreight.State__c == null && iFreight.Country__c == null){
                iFreight.addError('Os campos Cidade, Estado e País não podem ser nulos ao mesmo tempo!');
            }
            if(iFreight.City__c != null && iFreight.State__c != null && iFreight.Country__c != null){
                iFreight.addError('Os campos Cidade, Estado e País não podem ser todos especificados ao mesmo tempo. Por favor, remova dois deles.');
            }
            if(iFreight.City__c != null && iFreight.State__c != null && iFreight.Country__c == null){
                iFreight.addError('Somente um campo entre Cidade, Estado e País pode ser especificado. Por favor, remova pelo menos um deles.');
            }
            if(iFreight.City__c != null && iFreight.State__c == null && iFreight.Country__c != null){
                iFreight.addError('Somente um campo entre Cidade, Estado e País pode ser especificado. Por favor, remova pelo menos um deles.');
            }
            if(iFreight.City__c == null && iFreight.State__c != null && iFreight.Country__c != null){
                iFreight.addError('Somente um campo entre Cidade, Estado e País pode ser especificado. Por favor, remova pelo menos um deles.');
            }
        }
    }
}