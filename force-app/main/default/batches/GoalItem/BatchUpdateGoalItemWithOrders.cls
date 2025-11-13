global with sharing class BatchUpdateGoalItemWithOrders implements Database.Batchable<sObject>, Database.Stateful{

    String year = String.ValueOf(Date.today().year());

    global Database.QueryLocator start(Database.BatchableContext bc){

        return Database.getQueryLocator([
            SELECT Id, Status, OrderValue__c, OwnerId, PaymentCondition__c, EndDate, ActivatedDate,
            (SELECT Id, Product2Id, Quantity, FinalTotalPrice__c FROM OrderItems)
            FROM Order
        ]);
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
        }


        UpdateGoalItem_Service updateGoalItemService = UpdateGoalItem_ServiceBuilder.builder()
            .setOtherObjectToHelpUpdate('Order')
            .setGoalItemsToUpdate(goalItems)
            .setMapOfGoalItemsToObjectsList(goalItemToOrdersMap)
            .setProductToHierarchyMap(orderItems)
            .build();

        List<GoalItem__c> goalItemsToUpdate = updateGoalItemService.updateGoalItems();

        for(GoalItem__c iGoalItem: goalItemsToUpdate){
            if(iGoalItem.RealizedValue__c >= iGoalItem.GoalValue__c){
                iGoalItem.Completed__c = true;
                iGoalItem.AchievedPercentage__c = iGoalItem.CommissionPercentage__c;
            }
        }

        Database.update(goalItemsToUpdate);

    }

    global void finish(Database.BatchableContext bc){
        Database.executeBatch(new BatchUpdateGoalsWithOrders());
    }
}