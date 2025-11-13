global interface UpdateGoalItem_Interface {
    
    GoalItem__c performanceGoalItem(GoalItem__c goalItem, List<sObject> sObjectList);

    GoalItem__c productGoalItem(GoalItem__c goalItem, List<sObject> sObjectList);

    GoalItem__c productHierarchyGoalItem(GoalItem__c goalItem, List<sObject> sObjectList, Map<Id, Id> productToHierarchyMap);

    GoalItem__c paymentConditionGoalItem(GoalItem__c goalItem, List<sObject> sObjectList);
}