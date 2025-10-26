global with sharing class CalloutOrderToElias implements CalloutOrderTo_Interface{

    global static void makeCallout(List<Order> ordersToSendList){

        System.debug('ordersToSendList => ' + ordersToSendList);

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

        String responseCallout = ExecuteCalloutOrders.executeCallout(endpoint, orderJson, ordersToSendList, orderExternalIds);

        System.debug('Resposta do Elias: '+ responseCallout);

        processingEliasResponse(responseCallout, ordersToSendList);
    }

    global static void processingEliasResponse(String responseCallout, List<Order> ordersToSendList){

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

            OrderTriggerHandler.disableTrigger();
            System.debug('ordersToSendList => ' + ordersToSendList);
            update ordersToSendList;
            OrderTriggerHandler.enableTrigger();
        }
    }
}