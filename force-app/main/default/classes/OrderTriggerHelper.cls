public with sharing class OrderTriggerHelper {
    public static void handleBeforeInsertOrder(List<Order> newRecordList){
        String username = UserInfo.getUserName();
        insertStatusBySalesforceShouldBeNovo(newRecordList, username);
    }
    public static void handleBeforeUpdateOrder(List<Order> newRecordList, Map<Id, Order> oldRecordMap){
        String username = UserInfo.getUserName();
        calculateDiscount(newRecordList);
        cannotUpdateTheOrderAccount(newRecordList, oldRecordMap);
        isERPItem(newRecordList, username);
        statusChangesRules(newRecordList, oldRecordMap, username);
    }
    public static void handleAfterUpdateOrder(List<Order> newRecordList, Map<Id, Order> oldRecordMap){
        //sendAprovadoOrders(newRecordList, oldRecordMap);
    }
    
    public static void cannotUpdateTheOrderAccount(List<Order> newRecordList, Map<Id, Order> oldRecordMap){
        for(Order iOrder: newRecordList){
            if(iOrder.AccountId != oldRecordMap.get(iOrder.Id).AccountId){
                iOrder.addError('Não é possível trocar a conta do pedido depois de ser criado!');
            }
        }
    }
    public static void isERPItem(List<Order> newRecordList, String username){
        for(Order iOrder: newRecordList){
            if(username != 'razoppienzo@brave-shark-nskhtp.com'){
                if(iOrder.ExternalId__c != null){ ///erp e o adm podem mudar objetos erp
                    iOrder.addError('Objeto criado em ERP só pode ser modificado pelo ERP!');
                }
            }
        }
    }

    public static void sendAprovadoOrders(List<Order> newRecordList, Map<Id, Order> oldRecordMap){
        Set<Id> ordersIdsToCallout = new Set<Id>();
        for(Order iOrder: newRecordList){
            if(iOrder.Status == 'Aprovado'){ 
                ordersIdsToCallout.add(iOrder.Id);
            }
        }
        if(!ordersIdsToCallout.isEmpty()){
            executeCallout(ordersIdsToCallout);
        }
    }

    @Future(callout=true) //vai rodar em outro contexto(Assincrono) e nao pode ser chamado na trigger diretamente 
    public static void executeCallout(Set<Id> OrdersIds){
        System.debug('calloutOrders'+ OrdersIds);
        
        String result = CalloutOrderSemTemplate.calloutOrders(OrdersIds); ////////////////////RESPOSTA DO ELIAS////////////////////////

        System.debug('resposta do elias: '+ result);

        
    }

    public static void statusChangesRules(List<Order> newRecordList, Map<Id, Order> oldRecordMap, String username){

        Map<String, List<OrderItem>> orderIdToOrderItemMap = getOrderIdToOrderItemMap(newRecordList);

        for(Order iOrder: newRecordList){

            System.debug('oldRecordMap.get(iOrder.Id).Status.    ' + oldRecordMap.get(iOrder.Id).Status);
            System.debug('iOrder.Status    ' + iOrder.Status);

            if (!((oldRecordMap.get(iOrder.Id).Status == 'Novo' && iOrder.Status == 'Em aprovação') || (oldRecordMap.get(iOrder.Id).Status == 'Novo' && iOrder.Status == 'Novo'))){

                System.debug('ESTA PASANDO POR AQUI');
                if(username != 'razoppienzo@brave-shark-nskhtp.com'){
                    System.debug(username);
                    iOrder.addError('Somente é permitida ser feita a mudança de Status de Novo para Em aprovação.');
                }
            }
            if(oldRecordMap.get(iOrder.Id).Status == 'Novo' && iOrder.Status == 'Em aprovação'){
                if(!orderIdToOrderItemMap.containsKey(iOrder.Id)) {
                    Iorder.addError('Para mudar um pedido de Novo para Em Aprovação é necessário adicionar um produto');
                }else{
                    if(iOrder.Discount__c >= 20 ){
                        
                    }else{
                        iOrder.Status = 'Aprovado';
                    }
                }
            }
        }
    }

    public static void insertStatusBySalesforceShouldBeNovo(List<Order> newRecordList, String username){
        for(Order iOrder: newRecordList){
            if(!(iOrder.Status == 'Novo')){
                if(username != 'razoppienzo@brave-shark-nskhtp.com'){
                    iOrder.addError('Somente é permitida ser feita a mudança de Status de Novo para Em aprovação.');
                }
            }
        }
    }
    public static void calculateDiscount(List<Order> newRecordList){

        Map<String, List<OrderItem>> orderIdToOrderItemMap = getOrderIdToOrderItemMap(newRecordList);

        for(Order iOrder: newRecordList){
            if(orderIdToOrderItemMap.containsKey(iOrder.Id)){
                Decimal totalDiscount = 0;
                Integer count = 0;
                
                for(OrderItem iOrderItem : orderIdToOrderItemMap.get(iOrder.Id)){
                    count++;
                    totalDiscount += (iOrderItem.Discount__c/100);
                }
                System.debug('iOrder.Discount__c: '+ totalDiscount);
                iOrder.Discount__c = (totalDiscount/count)*100;
                System.debug('iOrder.Discount__c: '+ iOrder.Discount__c);
            }
        }
    }

    public static Map<String, List<OrderItem>> getOrderIdToOrderItemMap(List<Order> newRecordList){
        List<OrderItem> orderItemsList = [
            SELECT Id, Discount__c, OrderId
            FROM OrderItem
            WHERE OrderId IN: newRecordList
        ];

        Map<String, List<OrderItem>> orderIdToOrderItemMap = new Map<String, List<OrderItem>>();
        for(OrderItem iOrderItem: orderItemsList){
            if(orderIdToOrderItemMap.containsKey(iOrderItem.OrderId)) orderIdToOrderItemMap.get(iOrderItem.OrderId).add(iOrderItem);
            else orderIdToOrderItemMap.put(iOrderItem.OrderId, new List<OrderItem>{iOrderItem});
        }

        return orderIdToOrderItemMap;
    }
}