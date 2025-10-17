global with sharing class BatchCleanupOldOrders implements Database.Batchable<sObject>, Schedulable{
    global Database.QueryLocator start(Database.BatchableContext bc){

        Date sixMonthsAgo = Date.today().addMonths(-6);
        String orders = 'SELECT Id, CreatedDate, ReceivedOrderLog__c, SentOrderLog__c FROM Order WHERE CreatedDate < :sixMonthsAgo';

        return Database.getQueryLocator(orders);
    }

    global void execute(Database.BatchableContext bc, List<Order> scope){

        List<Id> logsIdsToDelete = new List<Id>();
        for(Order iOrder: scope){
            iOrder.Status = 'Novo';
            logsIdsToDelete.add(iOrder.ReceivedOrderLog__c);
            logsIdsToDelete.add(iOrder.SentOrderLog__c);
            System.debug(iOrder);
        }

        List<IntegrationLog__c> logsToDeleteList = [
            SELECT Id
            FROM IntegrationLog__c
            WHERE Id IN :logsIdsToDelete
        ];

        update scope;
        delete logsToDeleteList;
        delete scope;
    }

    global void finish(Database.BatchableContext bc){}

    global void execute(SchedulableContext sc){
        BatchCleanupOldOrders batchCleanupOldOrders = new BatchCleanupOldOrders();
        Database.executeBatch(batchCleanupOldOrders, 10);
    }
}