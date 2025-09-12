public with sharing class OrderTriggerHelper {
    public static void handleUpdateOrder(List<Order> newRecordList, Map<Id, Order> oldRecordMap){
        cannotUpdateTheOrderAccount(newRecordList, oldRecordMap);
        updateAfterActivate(newRecordList, oldRecordMap);
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
}