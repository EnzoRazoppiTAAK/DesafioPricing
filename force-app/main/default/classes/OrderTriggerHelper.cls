public with sharing class OrderTriggerHelper {
    public static void handleBeforeUpdateOrder(List<Order> newRecordList, Map<Id, Order> oldRecordMap){
        cannotUpdateTheOrderAccount(newRecordList, oldRecordMap);
        //updateAfterActivate(newRecordList, oldRecordMap);
        isERPItem(newRecordList);
        verifyActivatedOrders(newRecordList, oldRecordMap);
    }
    public static void handleAfterUpdateOrder(List<Order> newRecordList, Map<Id, Order> oldRecordMap){
    }
    
    public static void cannotUpdateTheOrderAccount(List<Order> newRecordList, Map<Id, Order> oldRecordMap){
        for(Order iOrder: newRecordList){
            if(iOrder.AccountId != oldRecordMap.get(iOrder.Id).AccountId){
                iOrder.addError('Não é possível trocar a conta do pedido depois de ser criado!');
            }
        }
    }
    public static void updateAfterActivate(List<Order> newRecordList, Map<Id, Order> oldRecordMap){
        for(Order iOrder: newRecordList){
            if(oldRecordMap.get(iOrder.Id).Status == 'Activated'){
                if(iOrder.Status == 'Activated' || iOrder.Status == 'Draft'){
                    iOrder.addError('Não é possível atualizar o pedido depois de marcado como ativo!');
                }
            }
        }
    }
    public static void isERPItem(List<Order> newRecordList){
        for(Order iOrder: newRecordList){
            if(iOrder.ERPItem__c == true){
                if(UserInfo.getUserName() != 'integration@00dbm00000s4xofean.com'){
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
        CalloutOrderSemTemplate.calloutOrders(OrdersIds);
    }
}