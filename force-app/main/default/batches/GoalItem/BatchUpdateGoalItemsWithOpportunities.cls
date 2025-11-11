global with sharing class BatchUpdateGoalItemsWithOpportunities implements Database.Batchable<sObject>, Schedulable, Database.Stateful {

    Id PerformanceRecordTypeId = Schema.SObjectType.GoalItem__c.getRecordTypeInfosByDeveloperName().get('Performance').getRecordTypeId();
    Id ProdutoRecordTypeId = Schema.SObjectType.GoalItem__c.getRecordTypeInfosByDeveloperName().get('Produto').getRecordTypeId();
    Id FamiliaDeProdutoRecordTypeId = Schema.SObjectType.GoalItem__c.getRecordTypeInfosByDeveloperName().get('FamiliaDeProduto').getRecordTypeId();
    Id CondicaoDePagamentoRecordTypeId = Schema.SObjectType.GoalItem__c.getRecordTypeInfosByDeveloperName().get('CondicaoDePagamento').getRecordTypeId();

    Map<Id, GoalItem__c> goalItemsToUpdateMap = new Map<Id, GoalItem__c>();
    Date today = Date.today();
    Integer year = Date.today().year();

    global Database.QueryLocator start(Database.BatchableContext bc){

        String opportunities = 'SELECT Id, StageName, ExpectedRevenue, OwnerId, CloseDate, PaymentCondition__c , ' +
        '(SELECT Id, Product2Id, Quantity, TotalPrice FROM OpportunityLineItems) ' + 
        'FROM Opportunity WHERE CloseDate > :today';

        return Database.getQueryLocator(opportunities);
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
            iGoalItem.ProjectedValue__c = 0.0;
        }

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

            List<Opportunity> iGoalItemOpportunitiesList = goalItemToOpportunitiesMap.get(iGoalItem.Id);

            if(iGoalItem.RecordTypeId == PerformanceRecordTypeId){
                UpdateGoalItemsWithOpportunities.performanceGoalItem(iGoalItem, iGoalItemOpportunitiesList);
            }
            if(iGoalItem.RecordTypeId == ProdutoRecordTypeId){
                UpdateGoalItemsWithOpportunities.productGoalItem(iGoalItem, iGoalItemOpportunitiesList);
            }
            if(iGoalItem.RecordTypeId == FamiliaDeProdutoRecordTypeId){
                UpdateGoalItemsWithOpportunities.productHierarchyGoalItem(iGoalItem, iGoalItemOpportunitiesList, productToProductHierarchyMap);
            }
            if(iGoalItem.RecordTypeId == CondicaoDePagamentoRecordTypeId){
                UpdateGoalItemsWithOpportunities.paymentConditionGoalItem(iGoalItem, iGoalItemOpportunitiesList);
            }

            if(goalItemsToUpdateMap.containsKey(iGoalItem.Id)){
                goalItemsToUpdateMap.get(iGoalItem.Id).ProjectedValue__c += iGoalItem.ProjectedValue__c;
            }else{
                goalItemsToUpdateMap.put(iGoalItem.Id, iGoalItem);
            }
        }
    }

    global void finish(Database.BatchableContext bc){

        if(goalItemsToUpdateMap.values().size() > 10000){

            List<GoalItem__c> goalItemsToUpdateNow = new List<GoalItem__c>();
            List<GoalItem__c> goalItemsToUpdateInQueue = new List<GoalItem__c>();

            for(Integer position = 0; position < goalItemsToUpdateMap.values().size(); position++){
                if(position < 10000){
                    goalItemsToUpdateNow.add(goalItemsToUpdateMap.values()[position]);
                }else{
                    goalItemsToUpdateInQueue.add(goalItemsToUpdateMap.values()[position]);
                }
            }

            Database.update(goalItemsToUpdateNow);
            System.enqueueJob(new QueueToUpdateExcessGoalItemInBatch(goalItemsToUpdateInQueue));
        }else{
            Database.update(goalItemsToUpdateMap.values());
        }

        Database.executeBatch(new BatchUpdateGoalItemWithOrders());
    }

    global void execute(SchedulableContext sc){
        Database.executeBatch(new BatchUpdateGoalItemsWithOpportunities());
    }
}

