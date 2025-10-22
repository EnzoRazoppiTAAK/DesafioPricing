global with sharing class CalloutOrderSemTemplate {

    @Future(callout=true)
    global static void calloutOrders(List<Id> OrdersIds){
    
        List<Order> ordersToSendList = [SELECT Id, ExternalId__c, OrderNumber, Account.ExternalId__c, AccountAddress__r.ExternalId__c, PaymentCondition__r.ExternalId__c, 
		EffectiveDate, FreightType__c, DistributionCenter__r.ExternalId__c, deliveryDate__c, Status, Observation__c, 
		(SELECT ExternalId__c, Product2.ExternalId__c, TotvsItem__c, UnitPrice, ListPrice, Quantity, OrderItemNumber FROM OrderItems) 
		FROM Order 
		WHERE Id IN: ordersIds
		];
    

        String responseCallout = executeCallout(ordersToSendList);
        System.debug('Resposta do Elias: '+ responseCallout);

        System.debug('ordersToSendList => ' + ordersToSendList);
        Map<String, Order> orderExternalIdToOrderMap = new Map<String, Order>();
        for(Order iOrder: ordersToSendList){
            orderExternalIdToOrderMap.put(iOrder.ExternalId__c, iOrder);
        }

        if(responseCallout.substring(2, 13) == '"errorCode"'){ //caso de erro no callout 
            for(Order iOrder: ordersToSendList){
                iOrder.Status = 'Erro de Integração';
            }
        }else{
            Map<String, Object> deserializeResponsesList = (Map<String, Object>) JSON.deserializeUntyped(responseCallout);
            List<Object> responseList = (List<Object>) deserializeResponsesList.get('responses');
            System.debug('responseList => ' + responseList);

            for(Object iResponse: responseList){
                Map<String, Object> responseObject = (Map<String, Object>) iResponse;

                if(responseObject.get('externalCode') == null){
                    for(Order iOrder: ordersToSendList){
                        iOrder.Status = 'Erro de Integração';
                    }
                }
                
                if(responseObject.get('hasError') == false){
                    orderExternalIdToOrderMap.get(String.valueOf(responseObject.get('externalCode'))).Status = 'Integrado';
                }else{
                    orderExternalIdToOrderMap.get(String.valueOf(responseObject.get('externalCode'))).Status = 'Erro de Integração';
                }
            }
        }

        OrderTriggerHandler.disableTrigger();
        System.debug('ordersToSendList => ' + ordersToSendList);
        update ordersToSendList;
        OrderTriggerHandler.enableTrigger();
    }

    global static String executeCallout(List<Order> ordersToSendList){

        String orderExternalIds = '';

        List<OrderDTO.OrderData> orderDataList = new List<OrderDTO.OrderData>();
        for(Order iOrder: ordersToSendList){
            orderDataList.add(new OrderDTO.OrderData(iOrder));
            if(orderExternalIds == ''){
                orderExternalIds += iOrder.ExternalId__c;
            }else{
                orderExternalIds += ', '+ iOrder.ExternalId__c;
            }
        }

        OrderDTO orderDTO = new OrderDTO(orderDataList);

        String endpoint = 'callout:OrgDoElias/services//apexrest/upsertOrder';
        String orderJson = JSON.serialize(orderDTO);

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
                .setRecordTypeName('OUTBOUND')
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

            IntegrationLog.updateOrderWithIntegrationLogId(ordersToSendList, integrationLogId, 'OUT');

            return response.getBody();
            
        }catch(Exception e){

            integrationLogId = logBuilder
                .setPayloadOUT(JSON.serialize(e.getMessage()))
                .setHasAnyErrors(true)
                .setHasDeleted(false)
                .build();

            IntegrationLog.updateOrderWithIntegrationLogId(ordersToSendList, integrationLogId, 'OUT');
            return e.getMessage();
        }
    }
}