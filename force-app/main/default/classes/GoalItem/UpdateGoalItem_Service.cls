global with sharing class UpdateGoalItem_Service {
    
    static Map<String, Type> classToUpdateMap = new Map<String, Type>{
        'Order' => UpdateGoalItemsWithOrder.class,
        'Opportunity' => UpdateGoalItemsWithOpportunities.class
    };

    Id PerformanceRecordTypeId = Schema.SObjectType.GoalItem__c.getRecordTypeInfosByDeveloperName().get('Performance').getRecordTypeId();
    Id ProdutoRecordTypeId = Schema.SObjectType.GoalItem__c.getRecordTypeInfosByDeveloperName().get('Produto').getRecordTypeId();
    Id FamiliaDeProdutoRecordTypeId = Schema.SObjectType.GoalItem__c.getRecordTypeInfosByDeveloperName().get('FamiliaDeProduto').getRecordTypeId();
    Id CondicaoDePagamentoRecordTypeId = Schema.SObjectType.GoalItem__c.getRecordTypeInfosByDeveloperName().get('CondicaoDePagamento').getRecordTypeId();

    List<GoalItem__c> goalItemsToUpdateList = new List<GoalItem__c>();
    String otherObjectToHelpUpdate;
    Map<Id, List<SObject>> goalItemsToObjectsListMap = new Map<Id, List<SObject>>();
    Map<Id, Id> productToHierarchyMap = new Map<Id, Id>();


    global UpdateGoalItem_Service(
        List<GoalItem__c> goalItemsToUpdateList,
        String otherObjectToHelpUpdate,
        Map<Id, List<SObject>> goalItemsToObjectsListMap,
        Map<Id, Id> productToHierarchyMap
    ){
        this.goalItemsToUpdateList = goalItemsToUpdateList;
        this.otherObjectToHelpUpdate = otherObjectToHelpUpdate;
        this.goalItemsToObjectsListMap = goalItemsToObjectsListMap;
        this.productToHierarchyMap = productToHierarchyMap;
    }

    global List<GoalItem__c> updateGoalItems(){

        UpdateGoalItem_Interface updateGoalItem;

        if(otherObjectToHelpUpdate == 'Opportunity'){
            updateGoalItem = (UpdateGoalItem_Interface)classToUpdateMap.get('Opportunity').newInstance();
        }

        if(otherObjectToHelpUpdate == 'Order'){
            updateGoalItem = (UpdateGoalItem_Interface)classToUpdateMap.get('Order').newInstance();
        }

        for(GoalItem__c iGoalItem: goalItemsToUpdateList){

            List<sObject> iGoalItemOrdersList = (List<sObject>) goalItemsToObjectsListMap.get(iGoalItem.Id);

            if(iGoalItem.RecordTypeId == PerformanceRecordTypeId){
                updateGoalItem.performanceGoalItem(iGoalItem, iGoalItemOrdersList);
            }
            if(iGoalItem.RecordTypeId == ProdutoRecordTypeId){
                updateGoalItem.productGoalItem(iGoalItem, iGoalItemOrdersList);
            }
            if(iGoalItem.RecordTypeId == FamiliaDeProdutoRecordTypeId){
                updateGoalItem.productHierarchyGoalItem(iGoalItem, iGoalItemOrdersList, productToHierarchyMap);
            }
            if(iGoalItem.RecordTypeId == CondicaoDePagamentoRecordTypeId){
                updateGoalItem.paymentConditionGoalItem(iGoalItem, iGoalItemOrdersList);
            }
        }

        return goalItemsToUpdateList;
    }
}