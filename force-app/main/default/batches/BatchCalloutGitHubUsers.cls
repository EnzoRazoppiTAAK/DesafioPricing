global with sharing class BatchCalloutGitHubUsers implements Database.Batchable<sObject>, Database.AllowsCallouts{

    global List<Id> devUsersIds;

    global BatchCalloutGitHubUsers(List<Id> devUsersIds){
        this.devUsersIds = devUsersIds;
    }

    global Database.QueryLocator start(Database.BatchableContext bc){

        String devUsers = 'SELECT Id, Login__c, Type__c, Bio__c FROM DevUser__c WHERE Id = :devUsersIds';

        return Database.getQueryLocator(devUsers);
    }

    global void execute(Database.BatchableContext bc, List<DevUser__c> scope){

        List<DevUser__c> devUsersToUpdate = new List<DevUser__c>();

        for(DevUser__c iDevUser: scope){

            devUsersToUpdate.add(ExecuteCalloutGetDevUsers.executeCallout(iDevUser));
        }

        DevUserTriggerHandler.disableTrigger();
        update devUsersToUpdate;
        DevUserTriggerHandler.enableTrigger();
        
    }

    global void finish(Database.BatchableContext bc){}

}