public with sharing class QueueGetPokemons implements Queueable, Finalizer, Database.AllowsCallouts{

    API__mdt pokemonApi = API__mdt.getInstance('PokemonAPI');
    String nextEndpoint;

    public QueueGetPokemons(){
        this.nextEndpoint = pokemonApi.Endpoint__c;
    }

    public QueueGetPokemons(String nextEndpoint){
        this.nextEndpoint = nextEndpoint;
    }

    public void execute(QueueableContext context) {
    
        nextEndpoint = ExecuteCalloutGetPokemon.executeCallout(nextEndpoint);

        if(nextEndpoint != null){
            System.attachFinalizer(new QueueGetPokemons(nextEndpoint));
        }
    }   

    public void execute(FinalizerContext ctx){

        nextEndpoint = ExecuteCalloutGetPokemon.executeCallout(nextEndpoint);

        if(nextEndpoint != null){
            System.enqueueJob(new QueueGetPokemons(nextEndpoint));
        }
    }
}



