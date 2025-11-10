public with sharing class UpdateGoalItemWithOrder {

    static Date today = Date.today();

    public static GoalItem__c performanceGoalItem(GoalItem__c goalItem, List<Order> orders){
        
        for(Order iOrder: orders){
            if(iOrder.ActivatedDate == null){
                if(iOrder.EndDate >= today){
                    goalItem.NegotiatedValue__c += iOrder.OrderValue__c;
                }
            }else{
                goalItem.RealizedValue__c += iOrder.OrderValue__c;
            }
        }
        return goalItem;
    }

    public static GoalItem__c productGoalItem(GoalItem__c goalItem, List<Order> orders){

        List<OrderItem> negotiatedOrderItems = new List<OrderItem>();
        List<OrderItem> realizedOrderItems = new List<OrderItem>();
        for(Order iOrder: orders){
            if(iOrder.ActivatedDate == null){
                if(iOrder.EndDate >= today){
                    negotiatedOrderItems.addAll(iOrder.OrderItems);
                }
            }else{
                realizedOrderItems.addAll(iOrder.OrderItems);
            }
        }

        for(OrderItem iOrderItem: negotiatedOrderItems){
            if(iOrderItem.Product2Id == goalItem.ProductId__c){
                goalItem.NegotiatedValue__c += iOrderItem.FinalTotalPrice__c;
            }
        }

        for(OrderItem iOrderItem: realizedOrderItems){
            if(iOrderItem.Product2Id == goalItem.ProductId__c){
                goalItem.RealizedValue__c += iOrderItem.FinalTotalPrice__c;
            }
        }
        return goalItem;
    }

    public static GoalItem__c productHierarchyGoalItem(GoalItem__c goalItem, List<Order> orders, Map<Id, Id> productToProductHierarchyMap){

        List<OrderItem> negotiatedOrderItems = new List<OrderItem>();
        List<OrderItem> realizedOrderItems = new List<OrderItem>();
        for(Order iOrder: orders){
            if(iOrder.ActivatedDate == null){
                if(iOrder.EndDate >= today){
                    negotiatedOrderItems.addAll(iOrder.OrderItems);
                }
            }else{
                realizedOrderItems.addAll(iOrder.OrderItems);
            }
        }

        for(OrderItem iOrderItem: negotiatedOrderItems){
            if(productToProductHierarchyMap.containsKey(iOrderItem.Product2Id)){
                if(productToProductHierarchyMap.get(iOrderItem.Product2Id) == goalItem.ProductHierarchyId__c){
                    goalItem.NegotiatedValue__c += iOrderItem.FinalTotalPrice__c;
                }
            }
        }

        for(OrderItem iOrderItem: realizedOrderItems){
            if(productToProductHierarchyMap.containsKey(iOrderItem.Product2Id)){
                if(productToProductHierarchyMap.get(iOrderItem.Product2Id) == goalItem.ProductHierarchyId__c){
                    goalItem.RealizedValue__c += iOrderItem.FinalTotalPrice__c;
                }
            }
        }
        return goalItem;
    }

    public static GoalItem__c paymentConditionGoalItem(GoalItem__c goalItem, List<Order> orders){
        
        for(Order iOrder: orders){
            if(iOrder.ActivatedDate == null){
                if(iOrder.EndDate >= today){
                    goalItem.NegotiatedValue__c += iOrder.OrderValue__c;
                }
            }else{
                goalItem.RealizedValue__c += iOrder.OrderValue__c;
            }
        }
        return goalItem;
    }
}