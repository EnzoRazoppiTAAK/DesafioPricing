public with sharing class OrderTriggerHelper {
    public static void handleBeforeInsertOrder(List<Order> newRecordList){
        insertStatusBySalesforceShouldBeNovo(newRecordList);
    }
    public static void handleBeforeUpdateOrder(List<Order> newRecordList, Map<Id, Order> oldRecordMap){
        cannotUpdateTheOrderAccount(newRecordList, oldRecordMap);
        isERPItem(newRecordList);
        changeStatusRules(newRecordList, oldRecordMap);
    }
    public static void handleAfterUpdateOrder(List<Order> newRecordList, Map<Id, Order> oldRecordMap){
        verifyActivatedOrders(newRecordList, oldRecordMap);
    }
    
    public static void cannotUpdateTheOrderAccount(List<Order> newRecordList, Map<Id, Order> oldRecordMap){
        for(Order iOrder: newRecordList){
            if(iOrder.AccountId != oldRecordMap.get(iOrder.Id).AccountId){
                iOrder.addError('Não é possível trocar a conta do pedido depois de ser criado!');
            }
        }
    }
    public static void isERPItem(List<Order> newRecordList){
        for(Order iOrder: newRecordList){
            if(iOrder.ExternalId__c != null){
                if(UserInfo.getUserName() != 'userintegration@api.com'){
                    iOrder.addError('Objeto criado em ERP só pode ser modificado pelo ERP!');
                }
            }
        }
    }

    public static void verifyActivatedOrders(List<Order> newRecordList, Map<Id, Order> oldRecordMap){
        Set<Id> ordersIdsToCallout = new Set<Id>();
        for(Order iOrder: newRecordList){
            if(iOrder.Status == 'Activated' && oldRecordMap.get(iOrder.Id).Status == 'Draft'){ 
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
        
        String result = CalloutOrderSemTemplate.calloutOrders(OrdersIds);

        System.debug('resposta do elias: '+ result);
    }

    public static void changeStatusRules(List<Order> newRecordList, Map<Id, Order> oldRecordMap){
        for(Order iOrder: newRecordList){
            if(oldRecordMap.get(iOrder.Id).Status == 'Novo' && iOrder.Status == 'Em Aprovação'){
                if(iOrder.OrderItems.size() == 0) {
                    Iorder.addError('Para mudar um pedido de Novo para Em Aprovação é necessário adicionar um produto');
                }
            }
            if(!(oldRecordMap.get(iOrder.Id).Status == 'Novo' && iOrder.Status == 'Em Aprovação')){
                if(UserInfo.getUserName() != 'userintegration@api.com'){
                    iOrder.addError('Somente é permitida ser feita a mudança de Status de Novo para Em aprovação.');
                }
            }
        }
    }

    public static void insertStatusBySalesforceShouldBeNovo(List<Order> newRecordList){
        for(Order iOrder: newRecordList){
            if(!(iOrder.Status == 'Novo')){
                if(UserInfo.getUserName() != 'userintegration@api.com'){
                    iOrder.addError('Somente é permitida ser feita a mudança de Status de Novo para Em aprovação.');
                }
            }
        }
    }
}