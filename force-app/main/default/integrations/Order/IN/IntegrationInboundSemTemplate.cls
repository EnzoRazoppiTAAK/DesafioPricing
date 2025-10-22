@RestResource(urlMapping='/upsertOrder/*')
global with sharing class IntegrationInboundSemTemplate {

    @HttpPost
    global static CalloutResponse.CalloutResponseList upsertOrder() {
        RestRequest httpContext = RestContext.request; 
        OrderDTO orderDTO;

        try{
            orderDTO = (OrderDTO) JSON.deserialize(httpContext.requestBody.toString(), OrderDTO.class);

        }catch(Exception e){

            RestContext.response.statusCode = 400;
            String error;
            List<CalloutResponse> responseList = new List<CalloutResponse>();

            if(e.getMessage().contains('either a decimal digit number')) {
                error = 'Quantity, UnitPrice e ListPrice devem receber números.';
                responseList.add(
                    CalloutResponse.builder()
                    .setHasError(true)
                    .setErrorMessage(error)
                    .setSObjectType('OrderItem')
                    .build()
                );

            }else{
                error = 'JSON mal formatado.';
                responseList.add(
                    CalloutResponse.builder()
                    .setHasError(true)
                    .setErrorMessage(error)
                    .build()
                );
            }
            return new CalloutResponse.CalloutResponseList(responseList);
        }

        List<Order> ordersToUpsertList = new List<Order>();
        List<OrderItem> orderItemsToUpsertList = new List<OrderItem>();
        List<OrderDTO.OrderItemData> orderItemDataList= new List<OrderDTO.OrderItemData>();

        Map<String, List<String>> externalIdsOrderToOrderItem = new  Map<String, List<String>>();
        Map<String, CalloutResponse> orderResponseMap = new Map<String, CalloutResponse>();
        Map<String, List<CalloutResponse>> orderToOrderItemResponseMap = new Map<String, List<CalloutResponse>>();
        Map<String, List<OrderItem>> orderToIncorrectOrderItemMap = new Map<String, List<OrderItem>>();
        List<CalloutResponse> responseList = new List<CalloutResponse>();
        
        Boolean hasError = false;
        Boolean hasDeleted;
        String orderExternalIds = '';

        for(OrderDTO.OrderData iOrderData : orderDTO.request){

            ordersToUpsertList.add(new Order(
				ExternalId__c			= iOrderData.orderCode,
				EffectiveDate			= iOrderData.effectiveDate,
				FreightType__c			= iOrderData.freightType,
				deliveryDate__c			= iOrderData.deliveryDate,
				Status					= iOrderData.status,
				Observation__c			= iOrderData.obs,
				Account					= new Account(ExternalId__c = iOrderData.accountCode),
				AccountAddress__r		= new AccountAddress__c(ExternalId__c = iOrderData.addressCode),
				PaymentCondition__r		= new PaymentCondition__c(ExternalId__c = iOrderData.paymentCode),
				DistributionCenter__r	= new DistributionCenter__c(ExternalId__c = iOrderData.distributionCenterCode)
            ));

			if (iOrderData.orderItems != null) {
				for (OrderDTO.OrderItemData iOrderItemData : iOrderData.orderItems) {
                    if(externalIdsOrderToOrderItem.containsKey(iOrderData.orderCode)) {
						externalIdsOrderToOrderItem.get(iOrderData.orderCode).add(iOrderItemData.itemCode);
					}else{
						externalIdsOrderToOrderItem.put(iOrderData.orderCode, new List<String>{iOrderItemData.itemCode});
                    }

					iOrderItemData.orderExternalId = iOrderData.orderCode;
				}

				orderItemDataList.addAll(iOrderData.orderItems);
			}
            if(orderExternalIds == '') orderExternalIds += iOrderData.orderCode;
            else orderExternalIds += + ', ' + iOrderData.orderCode;
        }

        List<Order> ordersStatusToIntegrado = new List<Order>();
		for(Order iOrder : ordersToUpsertList) {
			ordersStatusToIntegrado.add(iOrder);
			iOrder.Status = 'Novo';
		}

        List<Database.UpsertResult> upsertOrders = Database.upsert(ordersToUpsertList, Order.ExternalId__c, false);
        Map<Id, Order> ordersIdstoOrdersMap = new Map<Id, Order>();
        List<String> orderItemsToDeleteInDatabase = new List<String>();

        for (Integer i = 0; i < upsertOrders.size(); i++){
            Order order = ordersToUpsertList[i];
			Database.UpsertResult upsertOrderResult = upsertOrders[i];

            CalloutResponse responseOrder;
        
            if(upsertOrderResult.isSuccess()){
                responseOrder = CalloutResponse.builder()
                    .setSalesforceId(upsertOrderResult.getId())
                    .setExternalCode(order.ExternalId__c)
                    .setHasError(false)
                    .setSObjectType('Order')
                    .build();

                if(externalIdsOrderToOrderItem.containsKey(order.ExternalId__c)) {
                    orderItemsToDeleteInDatabase.addAll(externalIdsOrderToOrderItem.get(order.ExternalId__c));
                }
            }else{
                hasError = true;
                String error = '';
                for(Database.Error iError : upsertOrderResult.getErrors()){
                    if(iError.getMessage().contains('not found for field ExternalId__c in entity Account')){
                        error = 'AccountCode não pode ser null ou Conta não encontrada com esse código.';
                    }
                    else if(iError.getMessage().contains('not found for field ExternalId__c in entity DistributionCenter__c')) {
                        error = 'DistributionCenterCode não pode ser null ou Centro de Distribuição não encontrado com esse código.';
                    }
                    else if(iError.getMessage().contains('not found for field ExternalId__c in entity PaymentCondition__c')) {
                        error = 'PaymentCode não pode ser null ou Condição de Pagamento não encontrado com esse código.';
                    }
                    else if(iError.getMessage().contains('not found for field ExternalId__c in entity PaymentCondition__c')) {
                        error = 'AddressCode não pode ser null ou Endereço de Conta não encontrado com esse código.';
                    }
                    else if(iError.getMessage().contains('Tipo de Frete: bad value for restricted picklist field:')) {
                        error = 'Tipo de frete inválido.';
                    }
                    else{
                        error += iError.getMessage() + ' ';
                    }
                }
                responseOrder = CalloutResponse.builder()
                    .setExternalCode(order.ExternalId__c)
                    .setHasError(true)
                    .setErrorMessage(error)
                    .setSObjectType('Order')
                    .build();
            }
            orderResponseMap.put(order.ExternalId__c, responseOrder);
            responseList.add(responseOrder);
        }

        List<OrderItem> orderItemsInDatabase = new List<OrderItem>([
            SELECT Id, OrderId, Product2Id, UnitPrice, Quantity
            FROM OrderItem
            WHERE ExternalId__c IN :orderItemsToDeleteInDatabase
        ]);

        if(!orderItemsInDatabase.isEmpty()){
            delete orderItemsInDatabase;
        }

        for(OrderDTO.OrderItemData iOrderItemData : orderItemDataList){
            orderItemsToUpsertList.add(new OrderItem(
                Order			= new Order(ExternalId__c = iOrderItemData.orderExternalId),
                Product2        = new Product2(ExternalId__c = iOrderItemData.productCode),
                Quantity		= iOrderItemData.quantity,
                UnitPrice		= iOrderItemData.unitPrice,
                ListPrice 		= iOrderItemData.listPrice,
                TotvsItem__c	= iOrderItemData.totvsItem,
                ExternalId__c	= iOrderItemData.itemCode
            ));
        }

        List<Database.UpsertResult> upsertOrderItems = Database.upsert(orderItemsToUpsertList, OrderItem.ExternalId__c, false);
        
        for (Integer i = 0; i < upsertOrderItems.size(); i++){
            OrderItem orderItem = orderItemsToUpsertList[i];
			Database.UpsertResult upsertOrderItemResult = upsertOrderItems[i];

            CalloutResponse responseOrderItem;

            if(upsertOrderItemResult.isSuccess()){
                responseOrderItem = CalloutResponse.builder()
                    .setSalesforceId(upsertOrderItemResult.getId())
                    .setExternalCode(orderItem.ExternalId__c)
                    .setHasError(false)
                    .setSObjectType('OrderItem')
                    .build();

            }else{
                String error = '';
                for(Database.Error iError : upsertOrderItemResult.getErrors()){
                    if(iError.getMessage().contains('not found for field ExternalId__c in entity Product2')){
                        error = 'ProductCode não pode ser null ou produto não encontrado com esse código.';
                    }else{
                        error += iError.getMessage() + ' ';
                    }
                }
                if(orderToIncorrectOrderItemMap.containsKey(orderItem.Order.ExternalId__c)) {
                    orderToIncorrectOrderItemMap.get(orderItem.Order.ExternalId__c).add(orderItem);
                }else{
                    orderToIncorrectOrderItemMap.put(orderItem.Order.ExternalId__c, new List<OrderItem>{orderItem});
                }

                responseOrderItem = CalloutResponse.builder()
                    .setExternalCode(orderItem.ExternalId__c)
                    .setHasError(true)
                    .setErrorMessage(error)
                    .setSObjectType('OrderItem')
                    .build();
            }

            if(orderToOrderItemResponseMap.containsKey(orderItem.Order.ExternalId__c)) {
                orderToOrderItemResponseMap.get(orderItem.Order.ExternalId__c).add(responseOrderItem);
            }else{
                orderToOrderItemResponseMap.put(orderItem.Order.ExternalId__c, new List<CalloutResponse>{responseOrderItem});
            }

            responseList.add(responseOrderItem);
        }

        hasDeleted = deleteOrderItemNotReceived(ordersToUpsertList, orderItemsToUpsertList);

        for(Order iOrder : ordersStatusToIntegrado) {
			iOrder.Status = 'Integrado';
		}

        Database.upsert(ordersStatusToIntegrado, Order.ExternalId__c, false);
        List<Order> ordersTodeleteList = new List<Order>();

        for (Integer i = 0; i < upsertOrders.size(); i++){
            Order order = ordersToUpsertList[i];
			Database.UpsertResult upsertOrderResult = upsertOrders[i];

        
            if(!upsertOrderResult.isSuccess()){
                hasError = true;
                String error = '';
                for(Database.Error iError : upsertOrderResult.getErrors()){
                    error += iError.getMessage() + ' ';
                }
                if(orderResponseMap.get(order.ExternalId__c).hasError == false){
                    orderResponseMap.get(order.ExternalId__c).hasError = true;
                    orderResponseMap.get(order.ExternalId__c).errorMessage = error;
                }
            }

            if(orderToIncorrectOrderItemMap.containsKey(order.ExternalId__c)){
                if(orderResponseMap.get(order.ExternalId__c).hasError == false){
                    ordersTodeleteList.add(order);
                    orderResponseMap.get(order.ExternalId__c).hasError = true;
                    orderResponseMap.get(order.ExternalId__c).errorMessage = 'Order não adicionado e se já existia no banco de dados, foi deletado, por erro nem um ou mais OrderItems.';
                }

                for(CalloutResponse iOrderItemResponse : orderToOrderItemResponseMap.get(order.ExternalId__c)){
                    iOrderItemResponse.hasError = true;
                    iOrderItemResponse.salesforceId = null;
                    iOrderItemResponse.errorMessage = 'OrderItem não adicionado por erro em algum OrderItem da sua mesma Order.';
                }
            }
        }

        if(!ordersTodeleteList.isEmpty()){
            delete ordersTodeleteList;
        }

        CalloutResponse.CalloutResponseList calloutResponseList = new CalloutResponse.CalloutResponseList(responseList);

        OrderTriggerHandler.disableTrigger();

        String integrationLogId = IntegrationLogBuilder.builder()
            .setIntegrationName('Order')
            .setExternalIdList(orderExternalIds)
            .setRecordTypeName('INBOUND')
            .setPayloadIN(JSON.serialize(orderDTO))
            .setPayloadOUT(JSON.serialize(calloutResponseList))
            .setEndpoint('https://brave-shark-nskhtp-dev-ed.trailblaze.my.salesforce.com/services//apexrest/upsertOrder')
            .setHasAnyErrors(hasError)
            .setHasDeleted(hasDeleted)
            .build();

        IntegrationLogBuilder.updateOrderWithIntegrationLogId(ordersToUpsertList, integrationLogId, 'IN');
        
        OrderTriggerHandler.enableTrigger();
                
		RestContext.response.statusCode = 201;

        return calloutResponseList;
    }

    public static Boolean deleteOrderItemNotReceived(List<Order> ordersToUpsertList, List<OrderItem> orderItemsToUpsertList){
        Set<Id> orderIds = new Set<Id>();
        Set<Id> orderItemIds = new Set<Id>();
        List<OrderItem> orderItemsToUpdate = new List<OrderItem>();

        for(OrderItem iOrderItem : orderItemsToUpsertList){
            orderItemIds.add(iOrderItem.Id);
        }
        for(Order iOrder : ordersToUpsertList){
            orderIds.add(iOrder.Id);
        }

        List<OrderItem> orderItemsToDelete = [
            SELECT Id, ExternalId__c
            FROM OrderItem 
            WHERE Id NOT IN :orderItemIds 
            AND OrderId IN :orderIds
        ];
        
        System.debug('OrderItems To Delete: ' + orderItemsToDelete);

        if(orderItemsToDelete.size() > 0){ 
            delete orderItemsToDelete;
            return true;
        }else{
            return false;
        }
    }
}