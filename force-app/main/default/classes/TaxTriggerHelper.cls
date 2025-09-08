public with sharing class TaxTriggerHelper {
    public static void handleInsertTax(List<Tax__c> newRecordList){
        verifyDuplicates(newRecordList);
    }

    public static void handleUpdateTax(List<Tax__c> newRecordList){
        verifyDuplicates(newRecordList);
    }

    public static void verifyDuplicates(List<Tax__c> newRecordList){
        Map<String, Tax__c> newTaxMap = new Map<String, Tax__c>();
        for(Tax__c iTax: newRecordList){
            String taxKey = iTax.Product__c+'-'+iTax.State__c;
            if(newTaxMap.containsKey(taxKey)){
                iTax.addError('Já existe um imposto com esses dados');
            }else{
                newTaxMap.put(taxKey, iTax);
            }
        }
        
        Set<Id> productsIds = new Set<Id>();
        Set<Id> statesIds = new Set<Id>();
        for(Tax__c iTax: newRecordList){
            productsIds.add(iTax.Product__c);
            statesIds.add(iTax.State__c);
        }

        List<Tax__c> taxesInDatabase = [
            SELECT Id, Product__c, State__c
            FROM Tax__c 
            WHERE Product__c IN :productsIds
            AND State__c IN :statesIds
        ];

        for(Tax__c iTax: taxesInDatabase){
            String taxKey = iTax.Product__c+'-'+iTax.State__c;
            if(newTaxMap.containsKey(taxKey)){
                if(iTax.Id != newTaxMap.get(taxKey).Id){
                    newTaxMap.get(taxKey).addError('Já existe um imposto com esses dados');
                }
            }
        }
    }
}