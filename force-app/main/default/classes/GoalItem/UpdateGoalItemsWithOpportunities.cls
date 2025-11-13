public with sharing class UpdateGoalItemsWithOpportunities implements UpdateGoalItem_Interface {
    
    public static GoalItem__c performanceGoalItem(GoalItem__c goalItem, List<sObject> opportunitiesList){

        List<Opportunity> opportunities = (List<Opportunity>) opportunitiesList;
        
        for(Opportunity iOpportunity: opportunities){
            goalItem.ProjectedValue__c += iOpportunity.ExpectedRevenue;
        }
        return goalItem;
    }

    public static GoalItem__c productGoalItem(GoalItem__c goalItem, List<sObject> opportunitiesList){

        List<Opportunity> opportunities = (List<Opportunity>) opportunitiesList;

        List<OpportunityLineItem> opportunityLineItems = new List<OpportunityLineItem>();
        for(Opportunity iOpportunity: opportunities){
            opportunityLineItems.addAll(iOpportunity.OpportunityLineItems);
        }

        for(OpportunityLineItem iOpportunityLineItem: opportunityLineItems){
            if(iOpportunityLineItem.Product2Id == goalItem.ProductId__c){
                goalItem.ProjectedValue__c += iOpportunityLineItem.TotalPrice;
            }
        }
        return goalItem;
    }

    public static GoalItem__c productHierarchyGoalItem(GoalItem__c goalItem, List<sObject> opportunitiesList, Map<Id, Id> productToHierarchyMap){

        List<Opportunity> opportunities = (List<Opportunity>) opportunitiesList;

        List<OpportunityLineItem> opportunityLineItems = new List<OpportunityLineItem>();
        for(Opportunity iOpportunity: opportunities){
            opportunityLineItems.addAll(iOpportunity.OpportunityLineItems);
        }

        for(OpportunityLineItem iOpportunityLineItem: opportunityLineItems){
            if(productToHierarchyMap.containsKey(iOpportunityLineItem.Product2Id)){
                if(productToHierarchyMap.get(iOpportunityLineItem.Product2Id) == goalItem.ProductHierarchyId__c){

                    goalItem.ProjectedValue__c += iOpportunityLineItem.TotalPrice;
                }
            }
        }
        return goalItem;
    }

    public static GoalItem__c paymentConditionGoalItem(GoalItem__c goalItem, List<sObject> opportunitiesList){

        List<Opportunity> opportunities = (List<Opportunity>) opportunitiesList;

        for(Opportunity iOpportunity: opportunities){

            if(iOpportunity.PaymentCondition__c == goalItem.PaymentConditionId__c){
                goalItem.ProjectedValue__c += iOpportunity.ExpectedRevenue;
            }
        }
        return goalItem;
    }
}