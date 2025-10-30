public with sharing class InvocableMethodOrder {
    @InvocableMethod(label='CalloutOrder' description='Método para o flow chamar uma callout' category='Order')
    public static void invocableProcessIntegration(List<Id> OrdersIds){
       CalloutOrder_Service.calloutOrders(OrdersIds, 'Elias');
    }
}