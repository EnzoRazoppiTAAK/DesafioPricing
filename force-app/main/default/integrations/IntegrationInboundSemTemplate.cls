@RestResource(urlMapping='/upsertOrder/*')
global with sharing class IntegrationInboundSemTemplate {

    @HttpPost
    global static ResponseInboundOrders upsertOrder() {
        RestRequest context = RestContext.request; 
        RequestOrders requestOrders;

        try{
            requestOrders = (RequestOrders) JSON.deserialize(context.requestBody.toString(), RequestOrders.class);
        }catch(Exception e){
            RestContext.response.statusCode = 400;
            String error;
            List<Response> responseList;

            if(e.getMessage().contains('either a decimal digit number')) {
                error = 'Quantity, UnitPrice e ListPrice devem receber números.';
                responseList = new List<Response>{new Response(null, null, true, error, 'OrderItem')};

            }else{
                error = 'JSON mal formatado.';
                responseList = new List<Response>{new Response(null, null, true, error, '')};

            }
            return new ResponseInboundOrders(responseList);
        }

        List<Order> ordersToUpsertList = new List<Order>();
        List<OrderItem> orderItemsToUpsertList = new List<OrderItem>();
        List<OrderItemData> orderItemDataList= new List<OrderItemData>();
        Map<String, List<String>> externalIdsOrderToOrderItem = new  Map<String, List<String>>();
        Map<String, Response> orderResponseMap = new Map<String, Response>();
        Map<String, List<Response>> orderToOrderItemResponseMap = new Map<String, List<Response>>();
        Map<String, List<OrderItem>> orderToIncorrectOrderItemMap = new Map<String, List<OrderItem>>();
        List<Response> responseList = new List<Response>();
        Boolean hasError = false;
        Boolean hasDeleted;
        String orderExternalIds = '';

        for(OrderData iOrderData : requestOrders.request){

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
				for (OrderItemData iOrderItemData : iOrderData.orderItems) {
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

            Response responseOrder;
        
            if(upsertOrderResult.isSuccess()){
                responseOrder = new Response(upsertOrderResult.getId(), order.ExternalId__c, false, null, 'Order');
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
                    else if(order.FreightType__c != 'FOB' && order.FreightType__c != 'CIF') {
                        error = 'FreightType inválido.';
                    }else{
                        error += iError.getMessage() + ' ';
                    }
                }
                responseOrder = new Response(null, order.ExternalId__c, true, error, 'Order');
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

        for(OrderItemData iOrderItemData : orderItemDataList){
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

            Response responseOrderItem;

            if(upsertOrderItemResult.isSuccess()){
                responseOrderItem = new Response(upsertOrderItemResult.getId(), orderItem.ExternalId__c, false, null, 'OrderItem');
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

                responseOrderItem = new Response(null, orderItem.ExternalId__c, true, error, 'OrderItem');
            }

            if(orderToOrderItemResponseMap.containsKey(orderItem.Order.ExternalId__c)) {
                    orderToOrderItemResponseMap.get(orderItem.Order.ExternalId__c).add(responseOrderItem);
            }else{
                orderToOrderItemResponseMap.put(orderItem.Order.ExternalId__c, new List<Response>{responseOrderItem});
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
                    orderResponseMap.get(order.ExternalId__c).errorMessage = 'Order não adcionado por erro nem um ou mais OrderItems.';
                }

                for(Response iOrderItemResponse : orderToOrderItemResponseMap.get(order.ExternalId__c)){
                    iOrderItemResponse.hasError = true;
                    iOrderItemResponse.salesforceId = null;
                    iOrderItemResponse.errorMessage = 'OrderItem não adcionado por erro em algum OrderItem da sua mesma Order.';
                }
            }
        }

        if(!ordersTodeleteList.isEmpty()){
            delete ordersTodeleteList;
        }
        
        ResponseInboundOrders responseInboundOrders = new ResponseInboundOrders(responseList);

        String endpoint = 'https://brave-shark-nskhtp-dev-ed.trailblaze.my.salesforce.com/services//apexrest/upsertOrder';

        OrderTriggerHandler.disableTrigger();
        String integrationLogId = IntegrationLog.createLog('Order', orderExternalIds, 'INBOUND', JSON.serialize(RequestOrders), 
        JSON.serialize(responseInboundOrders), endpoint, hasError, hasDeleted);
        IntegrationLog.updateOrderWithIntegrationLogId(ordersToUpsertList, integrationLogId, 'IN');
        
        OrderTriggerHandler.enableTrigger();
                
		RestContext.response.statusCode = 201;

        return responseInboundOrders;
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

    global class RequestOrders{
        public List<OrderData> request;

        public RequestOrders(List<OrderData> request){
            this.request = request;
        }
    }

    global class OrderData{
		public String accountCode;
        public String addressCode;
        public String paymentCode;
        public Date effectiveDate;
        public String freightType;
        public String distributionCenterCode;
        public String orderCode;
        public Date deliveryDate;
        public String status;
        public String obs;

		public List<OrderItemData> orderItems;
    }

    global class OrderItemData{
        public String orderExternalId;
		public String itemCode;
		public Decimal quantity;
		public Decimal unitPrice;
		public Decimal listPrice;
		public String productCode;
		public Boolean totvsItem;
    }
    
    global virtual class Response{
        public String salesforceId;
        public String externalCode;
        public Boolean hasError;
        public String errorMessage;
        public String sobjectType;

        public Response(String salesforceId, String externalCode, Boolean hasError, String errorMessage, String sobjectType){
            this.salesforceId = salesforceId;
            this.externalCode = externalCode;
            this.hasError = hasError;
            this.errorMessage = errorMessage;
            this.sobjectType = sobjectType;
        }
    }

    global class ResponseInboundOrders{
        public List<Response> response;

        public ResponseInboundOrders(List<Response> response){
            this.response = response;
        }
    }
}