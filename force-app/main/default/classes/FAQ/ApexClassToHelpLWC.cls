public with sharing class ApexClassToHelpLWC {

    @AuraEnabled(cacheable=true)
    public static List<FAQ__c> searchForAllFAQs(){

        List<FAQ__c> allFAQs = [
            SELECT Id, Question__c, Answer__c 
            FROM FAQ__c
        ];

        for(FAQ__c iFAQ: allFAQs){
            iFAQ.Answer__c = iFAQ.Answer__c.stripHtmlTags();
            System.debug(iFAQ);
        }
        
        return allFAQs;
    }
}