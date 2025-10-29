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
            String endpoint = 'https://api.github.com/users/' + iDevUser.Login__c;

            System.debug('EXECUTING CALLOUT');

            HttpRequest request = new HttpRequest();
            request.setMethod('GET');
            request.setEndpoint(endpoint);
            HttpResponse response;
            try{
                response = new Http().send(request);

                System.debug('RESPONSE: '+ response.getBody());

                GithubResponse githubResponse = (GithubResponse) JSON.deserialize(response.getBody(), GithubResponse.class);
                iDevUser.ExternalId__c = githubResponse.id;
                iDevUser.Type__c = githubResponse.type;
                iDevUser.Bio__c = githubResponse.bio;
                devUsersToUpdate.add(iDevUser);
            
            }catch(Exception e){         
                System.debug('Erro ao executar o callout: '+ e.getMessage());
            }
        }

        DevUserTriggerHandler.disableTrigger();
        update devUsersToUpdate;
        DevUserTriggerHandler.enableTrigger();
        
    }

    global void finish(Database.BatchableContext bc){}

    global class GithubResponse{
        public String id;
        public String type;
        public String bio; 
    }

}