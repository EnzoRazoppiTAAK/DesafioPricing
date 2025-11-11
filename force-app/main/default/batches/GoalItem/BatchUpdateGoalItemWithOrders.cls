global with sharing class BatchUpdateGoalItemWithOrders implements Database.Batchable<sObject>, Database.Stateful{

    Id PerformanceRecordTypeId = Schema.SObjectType.GoalItem__c.getRecordTypeInfosByDeveloperName().get('Performance').getRecordTypeId();
    Id ProdutoRecordTypeId = Schema.SObjectType.GoalItem__c.getRecordTypeInfosByDeveloperName().get('Produto').getRecordTypeId();
    Id FamiliaDeProdutoRecordTypeId = Schema.SObjectType.GoalItem__c.getRecordTypeInfosByDeveloperName().get('FamiliaDeProduto').getRecordTypeId();
    Id CondicaoDePagamentoRecordTypeId = Schema.SObjectType.GoalItem__c.getRecordTypeInfosByDeveloperName().get('CondicaoDePagamento').getRecordTypeId();

    Map<Id, GoalItem__c> goalItemsToUpdateMap = new Map<Id, GoalItem__c>();
    Integer year = Date.today().year();

    global Database.QueryLocator start(Database.BatchableContext bc){

        String orders = 'SELECT Id, Status, OrderValue__c, OwnerId, PaymentCondition__c, EndDate, ActivatedDate, ' +
        '(SELECT Id, Product2Id, Quantity, FinalTotalPrice__c FROM OrderItems) ' + 
        'FROM Order';

        return Database.getQueryLocator(orders);
    }

    global void execute(Database.BatchableContext bc, List<Order> scope){

        Map<Id, List<Order>> ownerIdToOrderMap = new Map<Id, List<Order>>(); 
        List<OrderItem> orderItems = new List<OrderItem>();
        for(Order iOrder: scope){

            if(ownerIdToOrderMap.containsKey(iOrder.OwnerId)){
                ownerIdToOrderMap.get(iOrder.OwnerId).add(iOrder);
            }else{
                ownerIdToOrderMap.put(iOrder.OwnerId, new List<Order>{iOrder});
            }
            orderItems.addAll(iOrder.OrderItems);
        }

        Map<Id, Goal__c> sellerGoals = new Map<Id, Goal__c>([
            SELECT Id, Seller__c, Year__c, SalesValue__c
            FROM Goal__c 
            WHERE Seller__c IN :ownerIdToOrderMap.keySet() AND Year__c =: year
        ]); 

        Map<id, List<Order>> goalIdsToOrdersMap = new Map<Id, List<Order>>();
        for(Goal__c iGoal: sellerGoals.values()){

            if(ownerIdToOrderMap.containsKey(iGoal.Seller__c)){
                goalIdsToOrdersMap.put(iGoal.Id, ownerIdToOrderMap.get(iGoal.Seller__c));
            }
        }
        
        List<GoalItem__c> goalItems = [
            SELECT Id, RecordTypeId, ProductId__c, ProductHierarchyId__c, PaymentConditionId__c, GoalId__c, Completed__c,
            NegotiatedValue__c, RealizedValue__c, GoalValue__c, AchievedPercentage__c, CommissionPercentage__c
            FROM GoalItem__c 
            WHERE GoalId__c IN :sellerGoals.keySet() AND Completed__c = false
        ];

        Map<Id, List<Order>> goalItemToOrdersMap = new Map<Id, List<Order>>();
        for(GoalItem__c iGoalItem: goalItems){

            if(goalIdsToOrdersMap.containsKey(iGoalItem.GoalId__c)){
                goalItemToOrdersMap.put(iGoalItem.Id, goalIdsToOrdersMap.get(iGoalItem.GoalId__c));
            }
            iGoalItem.NegotiatedValue__c = 0.0;
            iGoalItem.RealizedValue__c = 0.0;
        }

        Set<Id> productIds = new Set<Id>();
        for(OrderItem iOrderItem: orderItems){
            productIds.add(iOrderItem.Product2Id);
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

            List<Order> iGoalItemOrdersList = goalItemToOrdersMap.get(iGoalItem.Id);

            if(iGoalItem.RecordTypeId == PerformanceRecordTypeId){
                UpdateGoalItemWithOrder.performanceGoalItem(iGoalItem, iGoalItemOrdersList);
            }
            if(iGoalItem.RecordTypeId == ProdutoRecordTypeId){
                UpdateGoalItemWithOrder.productGoalItem(iGoalItem, iGoalItemOrdersList);
            }
            if(iGoalItem.RecordTypeId == FamiliaDeProdutoRecordTypeId){
                UpdateGoalItemWithOrder.productHierarchyGoalItem(iGoalItem, iGoalItemOrdersList, productToProductHierarchyMap);
            }
            if(iGoalItem.RecordTypeId == CondicaoDePagamentoRecordTypeId){
                UpdateGoalItemWithOrder.paymentConditionGoalItem(iGoalItem, iGoalItemOrdersList);
            }

            if(goalItemsToUpdateMap.containsKey(iGoalItem.Id)){
                goalItemsToUpdateMap.get(iGoalItem.Id).NegotiatedValue__c += iGoalItem.NegotiatedValue__c;
                goalItemsToUpdateMap.get(iGoalItem.Id).RealizedValue__c += iGoalItem.RealizedValue__c;
            }else{
                goalItemsToUpdateMap.put(iGoalItem.Id, iGoalItem);
            }
        }
    }

    global void finish(Database.BatchableContext bc){

        for(GoalItem__c iGoalItem: goalItemsToUpdateMap.values()){
            if(iGoalItem.RealizedValue__c >= iGoalItem.GoalValue__c){
                iGoalItem.Completed__c = true;
                iGoalItem.AchievedPercentage__c = iGoalItem.CommissionPercentage__c;
            }
        }

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

        Database.executeBatch(new BatchUpdateGoalsWithOrders());
    }
}