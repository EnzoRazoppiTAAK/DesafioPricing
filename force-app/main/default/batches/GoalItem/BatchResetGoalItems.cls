global with sharing class BatchResetGoalItems implements Database.Batchable<sObject>, Database.Stateful, Schedulable {
    
    String year = String.ValueOf(Date.today().year());

    global Database.QueryLocator start(Database.BatchableContext bc){

        Map<Id, Goal__c> goalsOfThisYear = new Map<Id, Goal__c>([
            SELECT Id, Year__c 
            FROM Goal__c 
            WHERE Year__c =: year
        ]); 

        return Database.getQueryLocator([
            SELECT Id, GoalId__c, ProjectedValue__c, NegotiatedValue__c, RealizedValue__c, Completed__c
            FROM GoalItem__c 
            WHERE GoalId__c IN :goalsOfThisYear.keySet() AND Completed__c = false
        ]);
    }

    global void execute(Database.BatchableContext bc, List<GoalItem__c> scope){

        for(GoalItem__c iGoalItem: scope){
            iGoalItem.ProjectedValue__c = 0.0;
            iGoalItem.NegotiatedValue__c = 0.0;
            iGoalItem.RealizedValue__c = 0.0;
        }

        Database.update(scope);
        
    }

    global void finish(Database.BatchableContext bc){
        Database.executeBatch(new BatchUpdateGoalItemsWithOpportunities());
    }

    global void execute(SchedulableContext sc){
        Database.executeBatch(new BatchResetGoalItems());
    }
}