global with sharing class ExecuteCalloutGetPokemon {
    
    global static String executeCallout(String endpoint){

        System.debug('EXECUTING CALLOUT TO GET POKEMONS');

        HttpRequest request = new HttpRequest();
        request.setMethod('GET');
        request.setEndpoint(endpoint);
        HttpResponse response;

        try{
            response = new Http().send(request);
            
            System.debug('RESPONSE: '+ response.getBody());

            PokemonApiResponse pokemonApiResponse = (PokemonApiResponse) JSON.deserialize(response.getBody(), PokemonApiResponse.class);

            List<Pokemon__c> PokemonsToInsert = new List<Pokemon__c>();

            for(ApiPokemon iApiPokemon : pokemonApiResponse.results){
                PokemonsToInsert.add(new Pokemon__c(
                    Name = iApiPokemon.name,
                    Url__c = iApiPokemon.url
                ));
            }
            Database.insert(PokemonsToInsert, false);

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