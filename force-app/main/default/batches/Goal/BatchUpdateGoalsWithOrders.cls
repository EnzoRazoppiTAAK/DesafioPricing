global with sharing class BatchUpdateGoalsWithOrders implements Database.Batchable<sObject>, Database.Stateful {
    
    Map<Id, Goal__c> goalsToUpdateMap = new Map<Id, Goal__c>();
    
    Integer year = Date.today().year();

    global Database.QueryLocator start(Database.BatchableContext bc){

        return Database.getQueryLocator([
            SELECT Id, OrderValue__c, OwnerId, ActivatedDate 
            FROM Order 
            WHERE ActivatedDate = THIS_YEAR
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

        Map<Id, List<Order>> goalIdsToOrdersMap = new Map<Id, List<Order>>();

        for(Goal__c iGoal: sellerGoals.values()){

            if(ownerIdToOrderMap.containsKey(iGoal.Seller__c)){
                goalIdsToOrdersMap.put(iGoal.Id, ownerIdToOrderMap.get(iGoal.Seller__c));
            }
        }

        for(Goal__c iGoal: sellerGoals.values()){
            iGoal.SalesValue__c = 0.0;
            if(goalIdsToOrdersMap.containsKey(iGoal.Id)){
                for(Order iOrder: goalIdsToOrdersMap.get(iGoal.Id)){
                    iGoal.SalesValue__c += iOrder.OrderValue__c;
                }
            }

            if(goalsToUpdateMap.containsKey(iGoal.Id)){
                goalsToUpdateMap.get(iGoal.Id).SalesValue__c += iGoal.SalesValue__c;
            }else{
                goalsToUpdateMap.put(iGoal.Id, iGoal);
            }
        }
    }

    global void finish(Database.BatchableContext bc){
        Database.update(goalsToUpdateMap.values());
    }
}