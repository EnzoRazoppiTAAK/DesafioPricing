global with sharing class ExecuteCalloutOrders {
    
    global static String executeCallout(String endpoint, String orderJson, List<Order> ordersToSendList, String orderExternalIds){

        System.debug('EXECUTING CALLOUT');
        System.debug('CALLOUT JSON: '+ orderJson);

        HttpRequest request = new HttpRequest();
        request.setMethod('POST');
        request.setEndpoint(endpoint);
        request.setBody(orderJson);
        request.setHeader('Content-Type', 'application/json');

        HttpResponse response;

        String integrationLogId;
        IntegrationLogBuilder logBuilder = IntegrationLogBuilder.builder()
                .setIntegrationName('Order')
                .setExternalIdList(orderExternalIds)
                .setOperation('OUTBOUND')
                .setEndpoint(endpoint)
                .setPayloadIN(JSON.serialize(orderJson));
        try{
            response = new Http().send(request);

            System.debug('RESPONSE: '+ response.getBody());

            integrationLogId = logBuilder
                .setPayloadOUT(JSON.serialize(response.getBody()))
                .setHasAnyErrors(false)
                .setHasDeleted(false)
                .build();

            PutIntegrationLogIdInSomeObject.updateOrder(ordersToSendList, integrationLogId, 'OUT');

            return response.getBody();
            
        }catch(Exception e){

            integrationLogId = logBuilder
                .setPayloadOUT(e.getMessage())
                .setHasAnyErrors(true)
                .setHasDeleted(false)
                .build();

            PutIntegrationLogIdInSomeObject.updateOrder(ordersToSendList, integrationLogId, 'OUT');
            return e.getMessage();
        }
    }
}