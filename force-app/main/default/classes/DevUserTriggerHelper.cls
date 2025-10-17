public with sharing class DevUserTriggerHelper {
    public static void afterInsert(List<DevUser__c> newRecordList){
        System.debug('afterInsert');

        List<DevUser__c> devUsersToCallout = new List<DevUser__c>();

        for(DevUser__c iDevUser: newRecordList){
            if(iDevUser.Login__c != null){
                if(iDevUser.Type__c == null && iDevUser.Bio__c == null){
                    devUsersToCallout.add(iDevUser);
                }
            }
        }

        if(!devUsersToCallout.isEmpty()){
            executeBatchCalloutGithub();
        }
    }

    public static void afterUpdate(List<DevUser__c> newRecordList, Map<Id, DevUser__c> oldRecordMap){
        System.debug('afterUpdate');

        List<DevUser__c> devUsersToCallout = new List<DevUser__c>();

        for(DevUser__c iDevUser: newRecordList){
            if(iDevUser.Login__c != null && iDevUser.Login__c != oldRecordMap.get(iDevUser.Id).Login__c){
                devUsersToCallout.add(iDevUser);
            }
        }

        if(!devUsersToCallout.isEmpty()){
            executeBatchCalloutGithub();
        }
    }


    public static void executeBatchCalloutGithub(){
        Database.executeBatch(new BatchCalloutGitHubUsers(), 10);
    }
}