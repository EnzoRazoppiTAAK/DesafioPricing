public with sharing class PutLogIdInPokemon {
    
    public static void updatePokemon(List<Pokemon__c> pokemonList, String integrationLogId) {
		List<Pokemon__c> pokemonToUpdateList = new List<Pokemon__c>();

		System.debug('integrationLogId: ' + integrationLogId);

		for (Pokemon__c iPokemon : [SELECT Id, Log__c  FROM Pokemon__c WHERE Id IN: pokemonList]) {
			iPokemon.Log__c =  integrationLogId;

			pokemonToUpdateList.add(iPokemon);
		}

		if (!pokemonToUpdateList.isEmpty()) update pokemonToUpdateList;
	}
}