public with sharing class InvocableMethodOrder {
    @InvocableMethod(label='CalloutOrder' description='CalloutOrder' category='Order')
    public static void invocableProcessIntegration(List<Id> OrdersIds){
       OrderTriggerHelper.executeCallout(OrdersIds);
    }
}