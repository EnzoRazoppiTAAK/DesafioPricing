global with sharing class ExecuteCalloutGetPokemon {
    
    global static String executeCallout(String endpoint){

        System.debug('EXECUTING CALLOUT TO GET POKEMONS');

        API__mdt pokemonApi = API__mdt.getInstance('PokemonAPI');

        HttpRequest request = new HttpRequest();
        request.setMethod('GET');
        request.setEndpoint(endpoint);
        HttpResponse response;

        try{
            response = new Http().send(request);
            
            System.debug('RESPONSE: '+ response.getBody());

            PokemonApiResponse pokemonApiResponse = (PokemonApiResponse) JSON.deserialize(response.getBody(), PokemonApiResponse.class);

            String externalIdList = '';
            List<Pokemon__c> PokemonsToUpsert = new List<Pokemon__c>();

            for(ApiPokemon iApiPokemon : pokemonApiResponse.results){

                Pokemon__c pokemon = new Pokemon__c(
                    Name = iApiPokemon.name,
                    Url__c = iApiPokemon.url,
                    ExternalId__c = iApiPokemon.url.remove(pokemonApi.Endpoint__c).remove('/')
                );

                PokemonsToUpsert.add(pokemon);
                externalIdList += pokemon.ExternalId__c + ', ';
            }
            Database.upsert(PokemonsToUpsert, Pokemon__c.ExternalId__c, false);

            Id integrationLogId = IntegrationLogBuilder.builder()
                .setIntegrationName('Pokemon')
                .setExternalIdList(externalIdList)
                .setOperation('INBOUND')
                .setPayloadIN(JSON.serialize(response.getBody()))
                .setPayloadOUT('')
                .setEndpoint(endpoint)
                .setHasAnyErrors(false)
                .setHasDeleted(false)
                .build();

            PutLogIdInPokemon.updatePokemon(PokemonsToUpsert, integrationLogId);

            return pokemonApiResponse.next;

        }catch(Exception e){         
            System.debug('Erro ao executar o callout: '+ e.getMessage());
            return null;
        }
    }

    global class PokemonApiResponse{
        public String next;
        public List<ApiPokemon> results;
    }

    global class ApiPokemon{
        public String name;
        public String url;
    }
}