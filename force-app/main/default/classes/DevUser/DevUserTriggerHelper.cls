public with sharing class DevUserTriggerHelper {
    public static void handleAfterInsertDevUser(List<DevUser__c> newRecordList){
        System.debug('afterInsert');

        List<Id> devUsersIdToCallout = new List<Id>();

        for(DevUser__c iDevUser: newRecordList){
            if(iDevUser.Login__c != null){
                devUsersIdToCallout.add(iDevUser.Id);
            }
        }

        if(!devUsersIdToCallout.isEmpty()){
            executeBatchCalloutGithub(devUsersIdToCallout);
        }
    }

    public static void handleAfterUpdateDevUser(List<DevUser__c> newRecordList, Map<Id, DevUser__c> oldRecordMap){
        System.debug('afterUpdate');

        List<Id> devUsersIdToCallout = new List<Id>();

        for(DevUser__c iDevUser: newRecordList){
            if(iDevUser.Login__c != null && iDevUser.Login__c != oldRecordMap.get(iDevUser.Id).Login__c){
                devUsersIdToCallout.add(iDevUser.Id);
            }
        }

        if(!devUsersIdToCallout.isEmpty()){
            executeBatchCalloutGithub(devUsersIdToCallout);
        }
    }


    public static void executeBatchCalloutGithub(List<Id> devUsersIdToCallout){
        Database.executeBatch(new BatchCalloutGitHubUsers(devUsersIdToCallout), 10);
    }
}