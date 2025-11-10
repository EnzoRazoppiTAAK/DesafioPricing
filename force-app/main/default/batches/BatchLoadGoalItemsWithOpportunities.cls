global with sharing class BatchLoadGoalItemsWithOpportunities implements Database.Batchable<sObject>, Schedulable, Database.Stateful {

    Map<Id, GoalItem__c> goalItemsToUpdateMap = new Map<Id, GoalItem__c>();

    global Database.QueryLocator start(Database.BatchableContext bc){

        Date today = Date.today();
        Integer year = Date.today().year();

        String opportunities = 'SELECT Id, StageName, ExpectedRevenue, OwnerId, CloseDate, PaymentCondition__c , ' +
        '(SELECT Id, Product2Id, Quantity, TotalPrice FROM OpportunityLineItems) ' + 
        'FROM Opportunity WHERE CloseDate > :today AND ';

        return Database.getQueryLocator(opportunities);
    }

    global void execute(Database.BatchableContext bc, List<Opportunity> scope){

        Map<Id, List<Opportunity>> ownerIdToOpportunitiesMap = new Map<Id, List<Opportunity>>(); 
        List<OpportunityLineItem> opportunityLineItems = new List<OpportunityLineItem>();
        for(Opportunity iOpportunity: scope){

            System.debug('iOpportunity: ' + iOpportunity);

            if(ownerIdToOpportunitiesMap.containsKey(iOpportunity.OwnerId)){
                ownerIdToOpportunitiesMap.get(iOpportunity.OwnerId).add(iOpportunity);
            }else{
                ownerIdToOpportunitiesMap.put(iOpportunity.OwnerId, new List<Opportunity>{iOpportunity});
            }
            opportunityLineItems.addAll(iOpportunity.OpportunityLineItems);
        }

        Integer year = Date.today().year();
        Map<Id, Goal__c> sellerGoals = new Map<Id, Goal__c>([
            SELECT Id, Seller__c, Year__c 
            FROM Goal__c 
            WHERE Seller__c IN :ownerIdToOpportunitiesMap.keySet() AND Year__c =: year
        ]); 

        Map<id, List<Opportunity>> goalIdsToOpportunitiesMap = new Map<Id, List<Opportunity>>();
        for(Goal__c iGoal: sellerGoals.values()){
            System.debug('iGoal: ' + iGoal);
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
        Set<Id> recordTypeIds = new Set<Id>();

        for(GoalItem__c iGoalItem: goalItems){
            if(goalIdsToOpportunitiesMap.containsKey(iGoalItem.GoalId__c)){
                goalItemToOpportunitiesMap.put(iGoalItem.Id, goalIdsToOpportunitiesMap.get(iGoalItem.GoalId__c));
            }
            recordTypeIds.add(iGoalItem.RecordTypeId);
            iGoalItem.ProjectedValue__c = 0.0;
        }

        Map<Id, RecordType> recordTypes = new Map<Id, RecordType>([SELECT Id, DeveloperName FROM RecordType WHERE Id IN :recordTypeIds]);

        Set<Id> productIds = new Set<Id>();
        for(OpportunityLineItem iOpportunityLineItem: opportunityLineItems){
            productIds.add(iOpportunityLineItem.Product2Id);
        }
        List<Product2> products = [
            SELECT Id, ProductHierarchy__c
            FROM Product2
            WHERE Id IN :productIds
        ];
        Map<Id, Id> productToProductHierarchyMap = new Map<Id, Id>();
        for(Product2 iProduct: products){
            productToProductHierarchyMap.put(iProduct.Id, iProduct.ProductHierarchy__c);
        }

        List<GoalItem__c> goalItemsToUpdate = new List<GoalItem__c>();
        for(GoalItem__c iGoalItem: goalItems){

            if(recordTypes.get(iGoalItem.RecordTypeId).DeveloperName == 'Performance'){
                UpdateProjectedValueInGoalItem.performanceGoalItem(iGoalItem, goalItemToOpportunitiesMap.get(iGoalItem.Id));
            }
            if(recordTypes.get(iGoalItem.RecordTypeId).DeveloperName == 'Produto'){
                UpdateProjectedValueInGoalItem.productGoalItem(iGoalItem, goalItemToOpportunitiesMap.get(iGoalItem.Id));
            }
            if(recordTypes.get(iGoalItem.RecordTypeId).DeveloperName == 'FamiliaDeProduto'){
                UpdateProjectedValueInGoalItem.productHierarchyGoalItem(iGoalItem, goalItemToOpportunitiesMap.get(iGoalItem.Id), productToProductHierarchyMap);
            }
            if(recordTypes.get(iGoalItem.RecordTypeId).DeveloperName == 'CondicaoDePagamento'){
                UpdateProjectedValueInGoalItem.paymentConditionGoalItem(iGoalItem, goalItemToOpportunitiesMap.get(iGoalItem.Id));
            }
            System.debug('2iGoalItem: ' + iGoalItem);
            if(goalItemsToUpdateMap.containsKey(iGoalItem.Id)){
                goalItemsToUpdateMap.get(iGoalItem.Id).ProjectedValue__c += iGoalItem.ProjectedValue__c;
            }else{
                goalItemsToUpdateMap.put(iGoalItem.Id, iGoalItem);
            }
        }
    }

    global void finish(Database.BatchableContext bc){
        Database.update(goalItemsToUpdateMap.values());
        Database.executeBatch(new BatchLoadGoalItemWithOrders());
    }

    global void execute(SchedulableContext sc){
        Database.executeBatch(new BatchLoadGoalItemsWithOpportunities());
    }
}