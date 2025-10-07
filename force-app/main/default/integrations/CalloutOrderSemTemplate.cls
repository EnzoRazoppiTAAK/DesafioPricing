global with sharing class CalloutOrderSemTemplate {

    global static void calloutOrders(Set<Id> OrdersIds){
    
        List<Order> ordersToSendList = [SELECT Id, ExternalId__c, Account.ExternalId__c, AccountAddress__r.ExternalId__c, PaymentCondition__r.ExternalId__c, 
		EffectiveDate, FreightType__c, DistributionCenter__r.ExternalId__c, deliveryDate__c, Status, Observation__c, 
		(SELECT ExternalId__c, Product2.ExternalId__c, TotvsItem__c, UnitPrice, ListPrice, Quantity FROM OrderItems) 
		FROM Order 
		WHERE Id IN: ordersIds
		];

        HttpResponse response = sendOrder(ordersToSendList);
    }

    global static HttpResponse sendOrder(List<Order> ordersToSendList){

        String orderJson = JSON.serialize(new RequestParameters(ordersToSendList));
        String endpoint = 'callout:OrgDoElias/services//apexrest/upsertOrder';

        HttpRequest request = new HttpRequest();
        request.setMethod('POST');
        request.setEndpoint(endpoint);
        request.setBody(orderJson);

        HttpResponse response;
        try{
            response = new Http().send(request);

            

            return response;
        }catch(Exception e){
            return response;
        }
    }

    global class RequestParameters{
        List<Order> request;

        public RequestParameters(List<Order> orders){
            this.request = orders;
        }
    }
}