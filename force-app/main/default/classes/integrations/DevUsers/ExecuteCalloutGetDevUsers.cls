global with sharing class ExecuteCalloutGetDevUsers {

    global static DevUser__c executeCallout(DevUser__c iDevUser){

        API__mdt githubApiEndpoint = API__mdt.getInstance('GitHubAPI');

        String endpoint = githubApiEndpoint.Endpoint__c + iDevUser.Login__c;
    
        System.debug('EXECUTING CALLOUT');

        HttpRequest request = new HttpRequest();
        request.setMethod('GET');
        request.setEndpoint(endpoint);
        HttpResponse response;

        try{
            response = new Http().send(request);

            System.debug('RESPONSE: '+ response.getBody());

            GithubApiResponse githubApiResponse = (GithubApiResponse) JSON.deserialize(response.getBody(), GithubApiResponse.class);
            iDevUser.ExternalId__c = githubApiResponse.id;
            iDevUser.Type__c = githubApiResponse.type;
            iDevUser.Bio__c = githubApiResponse.bio;

            iDevUser.Log__c = IntegrationLogBuilder.builder()
                .setIntegrationName('DevUser')
                .setExternalIdList(iDevUser.ExternalId__c)
                .setOperation('INBOUND')
                .setPayloadIN(JSON.serialize(response.getBody()))
                .setPayloadOUT('')
                .setEndpoint(endpoint)
                .setHasAnyErrors(false)
                .setHasDeleted(false)
                .build();

            
            return iDevUser;
                
        }catch(Exception e){         
            System.debug('Erro ao executar o callout: '+ e.getMessage());
            iDevUser.ExternalId__c = null;
            iDevUser.Type__c = null;
            iDevUser.Bio__c = null;

            iDevUser.Log__c = IntegrationLogBuilder.builder()
                .setIntegrationName('DevUser')
                .setExternalIdList('')
                .setOperation('INBOUND')
                .setPayloadIN(e.getMessage())
                .setPayloadOUT('')
                .setEndpoint(endpoint)
                .setHasAnyErrors(true)
                .setHasDeleted(false)
                .build();

            return iDevUser;
        }
    }

    global class GithubApiResponse{
        public String id;
        public String type;
        public String bio; 
    }
}