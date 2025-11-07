public with sharing class UpdateProjectedValueInGoalItem {
    
    public static GoalItem__c performanceGoalItem(GoalItem__c goalItem, List<Opportunity> opportunities){
        
        for(Opportunity iOpportunity: opportunities){
            goalItem.ProjectedValue__c += iOpportunity.ExpectedRevenue;
        }
        return goalItem;
    }

    public static GoalItem__c productGoalItem(GoalItem__c goalItem, List<Opportunity> opportunities){

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

    public static GoalItem__c productHierarchyGoalItem(GoalItem__c goalItem, List<Opportunity> opportunities, Map<Id, Id> productToProductHierarchyMap){

        List<OpportunityLineItem> opportunityLineItems = new List<OpportunityLineItem>();
        for(Opportunity iOpportunity: opportunities){
            opportunityLineItems.addAll(iOpportunity.OpportunityLineItems);
        }
        for(OpportunityLineItem iOpportunityLineItem: opportunityLineItems){
            if(productToProductHierarchyMap.containsKey(iOpportunityLineItem.Product2Id)){
                if(productToProductHierarchyMap.get(iOpportunityLineItem.Product2Id) == goalItem.ProductHierarchyId__c){
                    goalItem.ProjectedValue__c += iOpportunityLineItem.TotalPrice;
                }
            }
        }
        return goalItem;
    }

    public static GoalItem__c paymentConditionGoalItem(GoalItem__c goalItem, List<Opportunity> opportunities){

        for(Opportunity iOpportunity: opportunities){
            System.debug('goalItem: PaymentCondition__c' + iOpportunity.PaymentCondition__c);
            if(iOpportunity.PaymentCondition__c == goalItem.PaymentConditionId__c){
                System.debug('Passou Aqui');
                goalItem.ProjectedValue__c += iOpportunity.ExpectedRevenue;
            }
        }
        return goalItem;
    }
}