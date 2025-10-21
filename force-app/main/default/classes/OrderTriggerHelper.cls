public with sharing class OrderTriggerHelper {
    public static void handleBeforeInsertOrder(List<Order> newRecordList){
        insertStatusBySalesforceShouldBeNovo(newRecordList);
    }

    public static void handleBeforeUpdateOrder(List<Order> newRecordList, Map<Id, Order> oldRecordMap){
        Map<Id, List<OrderItem>> orderIdToOrderItemMap =  getOrderIdToOrderItemMap(newRecordList);

        calculateDiscount(newRecordList, orderIdToOrderItemMap);
        cannotUpdateTheOrderAccount(newRecordList, oldRecordMap);
        cannotUpdateIntegradoItem(newRecordList, oldRecordMap);
        statusChangesRules(newRecordList, oldRecordMap, orderIdToOrderItemMap);
        putExternalId(newRecordList, orderIdToOrderItemMap);
    }

    public static void handleAfterUpdateOrder(List<Order> newRecordList, Map<Id, Order> oldRecordMap){
        sendOrders(newRecordList);
    }

    public static void insertStatusBySalesforceShouldBeNovo(List<Order> newRecordList){
        for(Order iOrder: newRecordList){
            if(!(iOrder.Status == 'Novo')){
                iOrder.addError('Somente é permitida ser feita a mudança de Status de Novo para Em aprovação.');
            }
        }
    }

    public static Map<Id, List<OrderItem>> getOrderIdToOrderItemMap(List<Order> newRecordList){
        List<OrderItem> orderItemsList = [
            SELECT Id, Discount__c, OrderId, OrderItemNumber
            FROM OrderItem
            WHERE OrderId IN: newRecordList
        ];

        Map<Id, List<OrderItem>> orderIdToOrderItemMap = new Map<Id, List<OrderItem>>();
        for(OrderItem iOrderItem: orderItemsList){
            if(orderIdToOrderItemMap.containsKey(iOrderItem.OrderId)) orderIdToOrderItemMap.get(iOrderItem.OrderId).add(iOrderItem);
            else orderIdToOrderItemMap.put(iOrderItem.OrderId, new List<OrderItem>{iOrderItem});
        }

        return orderIdToOrderItemMap;
    }

    public static void calculateDiscount(List<Order> newRecordList, Map<Id, List<OrderItem>> orderIdToOrderItemMap){

        for(Order iOrder: newRecordList){
            if(orderIdToOrderItemMap.containsKey(iOrder.Id)){
                Decimal totalDiscount = 0;
                Integer count = 0;
                
                for(OrderItem iOrderItem : orderIdToOrderItemMap.get(iOrder.Id)){
                    count++;
                    totalDiscount += (iOrderItem.Discount__c/100);
                }

                iOrder.Discount__c = (totalDiscount/count)*100;
            }
        }
    }
    
    public static void cannotUpdateTheOrderAccount(List<Order> newRecordList, Map<Id, Order> oldRecordMap){
        for(Order iOrder: newRecordList){
            if(iOrder.AccountId != oldRecordMap.get(iOrder.Id).AccountId){
                iOrder.addError('Não é possível trocar a conta do pedido depois de ser criado!');
            }
        }
    }

    public static void cannotUpdateIntegradoItem(List<Order> newRecordList, Map<Id, Order> oldRecordMap){
        for(Order iOrder: newRecordList){
            if(oldRecordMap.get(iOrder.id).Status == 'Integrado' && iOrder.Status == 'Integrado'){
                if(UserInfo.getUserName() != 'razoppienzo@brave-shark-nskhtp.com'){
                    iOrder.addError('Order com status Integrado não pode ser modificada!');
                }
            }
        }
    }

    public static void statusChangesRules(List<Order> newRecordList, Map<Id, Order> oldRecordMap, Map<Id, List<OrderItem>> orderIdToOrderItemMap ){

        Set<Id> ordersIdsToCallout = new Set<Id>();

        for(Order iOrder: newRecordList){
            if(oldRecordMap.get(iOrder.Id).Status == 'Novo' && iOrder.Status == 'Em aprovação'){
  
                if(!orderIdToOrderItemMap.containsKey(iOrder.Id)) {
                    iOrder.addError('Para mudar um pedido de Novo para Em Aprovação é necessário adicionar um produto');
                }else{
                    if(iOrder.Discount__c >= 20 ){
                        Approval.processSubmitRequest req = new Approval.processSubmitRequest();
                        req.setObjectId(iOrder.Id);
                        req.setSubmitterId(UserInfo.getUserId());
                        req.setProcessDefinitionNameOrId('EmAprovadoToAprovadoInOrder');
                        Approval.process(req);
                    }else{
                        iOrder.Status = 'Aprovado';
                    }
                }
            }
            System.debug('order.status'+iOrder.Status);
        }
    }
    public static void putExternalId(List<Order> newRecordList, Map<Id, List<OrderItem>> orderIdToOrderItemMap){
        System.debug('puExternalId');
        List<OrderItem> orderItemsToUpdate = new List<OrderItem>();
        for(Order iOrder: newRecordList){
            if(iOrder.Status == 'Aprovado'){
                iOrder.ExternalId__c = iOrder.OrderNumber;
                for(OrderItem iOrderItem: orderIdToOrderItemMap.get(iOrder.Id)){
                    iOrderItem.ExternalId__c = iOrderItem.OrderItemNumber;
                    orderItemsToUpdate.add(iOrderItem);
                }
            }
        }

        OrderTriggerHandler.disableTrigger();
        if(!orderItemsToUpdate.isEmpty()){
            update orderItemsToUpdate;
        }
        OrderTriggerHandler.enableTrigger();
    }

    public static void sendOrders(List<Order> newRecordList){
        System.debug('sendOrders');
        List<Id> ordersIdsToCallout = new List<Id>();
        for(Order iOrder: newRecordList){
            if(iOrder.Status == 'Aprovado'){
                ordersIdsToCallout.add(iOrder.Id);
            }
        }
        if(!ordersIdsToCallout.isEmpty()){
            if(System.IsBatch() == false && System.isFuture() == false){
                CalloutOrderSemTemplate.calloutOrders(ordersIdsToCallout);
            }
        }
    }
}