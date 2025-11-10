global with sharing class BatchLoadGoalItemWithOrders implements Database.Batchable<sObject>, Database.Stateful{

    Map<Id, GoalItem__c> goalItemsToUpdateMap = new Map<Id, GoalItem__c>();

    global Database.QueryLocator start(Database.BatchableContext bc){

        Date today = Date.today();

        String opportunities = 'SELECT Id, Status, ExpectedRevenue, OwnerId, CloseDate, PaymentCondition__c , ' +
        '(SELECT Id, Product2Id, Quantity, TotalPrice FROM OpportunityLineItems) ' + 
        'FROM Opportunity WHERE CloseDate > :today';

        return Database.getQueryLocator(opportunities);
    }

    global void execute(Database.BatchableContext bc, List<Opportunity> scope){

        
    }

    global void finish(Database.BatchableContext bc){
        Database.update(goalItemsToUpdateMap.values());
    }
}