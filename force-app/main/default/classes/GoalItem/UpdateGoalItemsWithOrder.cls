public with sharing class UpdateGoalItemsWithOrder implements UpdateGoalItem_Interface {

    static Date today = Date.today();
    static Integer year = Date.today().year();

    public static GoalItem__c performanceGoalItem(GoalItem__c goalItem, List<sObject> ordersList){

        List<Order> orders = (List<Order>) ordersList;
        
        for(Order iOrder: orders){
            if(iOrder.ActivatedDate == null){
                if(iOrder.EndDate >= today){
                    goalItem.NegotiatedValue__c += iOrder.OrderValue__c;
                }
            }else{
                if(iOrder.ActivatedDate.year() == year){
                    goalItem.RealizedValue__c += iOrder.OrderValue__c;
                }
            }
        }
        return goalItem;
    }

    public static GoalItem__c productGoalItem(GoalItem__c goalItem, List<sObject> ordersList){

        List<Order> orders = (List<Order>) ordersList;

        List<OrderItem> negotiatedOrderItems = new List<OrderItem>();
        List<OrderItem> realizedOrderItems = new List<OrderItem>();
        for(Order iOrder: orders){
            if(iOrder.ActivatedDate == null){
                if(iOrder.EndDate >= today){
                    negotiatedOrderItems.addAll(iOrder.OrderItems);
                }
            }else{
                if(iOrder.ActivatedDate.year() == year){
                    realizedOrderItems.addAll(iOrder.OrderItems);
                }
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

    public static GoalItem__c productHierarchyGoalItem(GoalItem__c goalItem, List<sObject> ordersList, Map<Id, Id> productToHierarchyMap){

        List<Order> orders = (List<Order>) ordersList;

        List<OrderItem> negotiatedOrderItems = new List<OrderItem>();
        List<OrderItem> realizedOrderItems = new List<OrderItem>();
        for(Order iOrder: orders){
            if(iOrder.ActivatedDate == null){
                if(iOrder.EndDate >= today){
                    negotiatedOrderItems.addAll(iOrder.OrderItems);
                }
            }else{
                if(iOrder.ActivatedDate.year() == year){
                    realizedOrderItems.addAll(iOrder.OrderItems);
                }
            }
        }

        for(OrderItem iOrderItem: negotiatedOrderItems){
            if(productToHierarchyMap.containsKey(iOrderItem.Product2Id)){
                if(productToHierarchyMap.get(iOrderItem.Product2Id) == goalItem.ProductHierarchyId__c){
                    goalItem.NegotiatedValue__c += iOrderItem.FinalTotalPrice__c;
                }
            }
        }

        for(OrderItem iOrderItem: realizedOrderItems){
            if(productToHierarchyMap.containsKey(iOrderItem.Product2Id)){
                if(productToHierarchyMap.get(iOrderItem.Product2Id) == goalItem.ProductHierarchyId__c){
                    goalItem.RealizedValue__c += iOrderItem.FinalTotalPrice__c;
                }
            }
        }
        return goalItem;
    }

    public static GoalItem__c paymentConditionGoalItem(GoalItem__c goalItem, List<sObject> ordersList){

        List<Order> orders = (List<Order>) ordersList;
        
        for(Order iOrder: orders){
            if(iOrder.ActivatedDate == null){
                if(iOrder.EndDate >= today){
                    goalItem.NegotiatedValue__c += iOrder.OrderValue__c;
                }
            }else{
                if(iOrder.ActivatedDate.year() == year){
                    goalItem.RealizedValue__c += iOrder.OrderValue__c;
                }
            }
        }
        return goalItem;
    }
}