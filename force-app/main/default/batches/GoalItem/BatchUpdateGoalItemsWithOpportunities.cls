global with sharing class BatchUpdateGoalItemsWithOpportunities implements Database.Batchable<sObject>, Database.Stateful {

    Date today = Date.today();
    String year = String.ValueOf(Date.today().year());

    global Database.QueryLocator start(Database.BatchableContext bc){

        return Database.getQueryLocator([
            SELECT Id, StageName, ExpectedRevenue, OwnerId, CloseDate, PaymentCondition__c ,
            (SELECT Id, Product2Id, Quantity, TotalPrice FROM OpportunityLineItems)
            FROM Opportunity WHERE CloseDate > :today
        ]);
    }

    global void execute(Database.BatchableContext bc, List<Opportunity> scope){

        Map<Id, List<Opportunity>> ownerIdToOpportunitiesMap = new Map<Id, List<Opportunity>>(); 
        List<OpportunityLineItem> opportunityLineItems = new List<OpportunityLineItem>();
        for(Opportunity iOpportunity: scope){

            if(ownerIdToOpportunitiesMap.containsKey(iOpportunity.OwnerId)){
                ownerIdToOpportunitiesMap.get(iOpportunity.OwnerId).add(iOpportunity);
            }else{
                ownerIdToOpportunitiesMap.put(iOpportunity.OwnerId, new List<Opportunity>{iOpportunity});
            }
            opportunityLineItems.addAll(iOpportunity.OpportunityLineItems);
        }

        Map<Id, Goal__c> sellerGoals = new Map<Id, Goal__c>([
            SELECT Id, Seller__c, Year__c 
            FROM Goal__c 
            WHERE Seller__c IN :ownerIdToOpportunitiesMap.keySet() AND Year__c =: year
        ]); 

        Map<id, List<Opportunity>> goalIdsToOpportunitiesMap = new Map<Id, List<Opportunity>>();
        for(Goal__c iGoal: sellerGoals.values()){

            if(ownerIdToOpportunitiesMap.containsKey(iGoal.Seller__c)){
                goalIdsToOpportunitiesMap.put(iGoal.Id, ownerIdToOpportunitiesMap.get(iGoal.Seller__c));
            }
        }

        List<GoalItem__c> goalItems = [
            SELECT Id, RecordTypeId, ProductId__c, ProductHierarchyId__c, PaymentConditionId__c, ProjectedValue__c, GoalId__c, Completed__c
            FROM GoalItem__c 
            WHERE GoalId__c IN :sellerGoals.keySet() AND Completed__c = false
        ];

        Map<Id, List<Opportunity>> goalItemToOpportunitiesMap = new Map<Id, List<Opportunity>>();
        for(GoalItem__c iGoalItem: goalItems){

            if(goalIdsToOpportunitiesMap.containsKey(iGoalItem.GoalId__c)){
                goalItemToOpportunitiesMap.put(iGoalItem.Id, goalIdsToOpportunitiesMap.get(iGoalItem.GoalId__c));
            }
        }

        UpdateGoalItem_Service updateGoalItemService = UpdateGoalItem_ServiceBuilder.builder()
            .setOtherObjectToHelpUpdate('Opportunity')
            .setGoalItemsToUpdate(goalItems)
            .setMapOfGoalItemsToObjectsList(goalItemToOpportunitiesMap)
            .setProductToHierarchyMap(opportunityLineItems)
            .build();

        List<GoalItem__c> goalItemsToUpdate = updateGoalItemService.updateGoalItems();

        Database.update(goalItemsToUpdate);
    }

    global void finish(Database.BatchableContext bc){
        Database.executeBatch(new BatchUpdateGoalItemWithOrders());
    }
}

