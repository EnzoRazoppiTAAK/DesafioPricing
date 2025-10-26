global with sharing class CalloutOrder_Service {

    public static Map<String, Type> userToCallloutClass = new Map<String, Type>{
        'Elias' => CalloutOrderToElias.class
    };

    @Future(callout=true)
    global static void calloutOrders(List<Id> OrdersIds, String userToSend){
    
        List<Order> ordersToSendList = [SELECT Id, ExternalId__c, OrderNumber, Account.ExternalId__c, AccountAddress__r.ExternalId__c, PaymentCondition__r.ExternalId__c, 
		EffectiveDate, FreightType__c, DistributionCenter__r.ExternalId__c, deliveryDate__c, Status, Observation__c, 
		(SELECT ExternalId__c, Product2.ExternalId__c, TotvsItem__c, UnitPrice, ListPrice, Quantity, OrderItemNumber FROM OrderItems) 
		FROM Order 
		WHERE Id IN: ordersIds
		];

        if(userToSend == 'Elias'){
            CalloutOrderTo_Interface calloutOrderTo = (CalloutOrderTo_Interface) userToCallloutClass.get('Elias').newInstance();
            calloutOrderTo.makeCallout(ordersToSendList);
        }
    }
}