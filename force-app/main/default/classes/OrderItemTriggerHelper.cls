public with sharing class OrderItemTriggerHelper {
    public static void handleInsertOrderItem(List<OrderItem> newRecordList){
        /* Map<OrderItem, Integer> mapOrderItem = new Map<OrderItem, Integer>();
        for(OrderItem iOrderItem: newRecordList){
            mapOrderItem.put(iOrderItem, 0);
        }
        Set<id> productsId = new Set<id>();
        Set<id> productHierarchyId = new Set<id>();
        for(OrderItem iOrderItem: mapOrderItem.keySet()){
            productsId.add(iOrderItem.Product2Id);
        }
        List<Product2> productsList = [
            SELECT Id, ProductHierarchy__c 
            FROM Product2 
            WHERE Id IN :productsId
            ];
        for(Product2 iProduct: productsList){
            productHierarchyId.add(iProduct.ProductHierarchy__c);
        }
        List<Margin__c> listMargin = [
            SELECT Id, ProductHierarchy__c, Product__c 
            FROM Margin__c 
            WHERE Product__c IN :productsId
            OR ProductHierarchy__c IN :productHierarchyId
            ];
        for(Margin__c iMargin: listMargin){
            OrderItem newOrderItem = new OrderItem();
            newOrderItem.Product2Id = iMargin.Product__c;
            newOrderItem = iMargin.ProductHierarchy__c;
            if(mapOrderItem.containsKey(newOrderItem)){
                mapOrderItem.put(newOrderItem, mapOrderItem.get(newOrderItem) + 1);
            }
        }*/
    }
    public static void handleUpdateOrderItem(List<OrderItem> newRecordList){
        
    }
}