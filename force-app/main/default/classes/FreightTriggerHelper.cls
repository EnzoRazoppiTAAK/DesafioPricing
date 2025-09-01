public with sharing class FreightTriggerHelper {
    public static void handleInsertFreight(List<Freight__c> newRecordList){
        FreightsRequiredFields(newRecordList);
    }
    public static void handleUpdateFreight(List<Freight__c> newRecordList){
        FreightsRequiredFields(newRecordList);
    }

    private static List<Freight__c> FreightsRequiredFields(List<Freight__c> newRecordList){
        for(Freight__c iFreight: newRecordList){
            if(iFreight.City__c == null && iFreight.State__c == null && iFreight.Country__c == null){
                iFreight.addError('Os campos Cidade, Estado e País não podem ser nulos ao mesmo tempo!');
            }
            if(iFreight.City__c != null && iFreight.State__c != null && iFreight.Country__c != null){
                iFreight.addError('Os campos Cidade, Estado e País não podem ser todos especificados ao mesmo tempo. Por favor, remova pelo menos um deles.');
            }
            if(iFreight.Product__c == null && iFreight.ProductHierarchy__c == null){
                iFreight.addError('Adicione um Produto ou uma Hierarquia de Produto!');
            }
            if(iFreight.Product__c != null && iFreight.ProductHierarchy__c != null){
                iFreight.addError('Os campos Produto e Hierarquia de Produto não podem ser especificados ao mesmo tempo. Por favor, remova um deles.');
            }
        }
        return newRecordList;
    }
}