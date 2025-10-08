@RestResource(urlMapping='/upsertOrder/*')
global with sharing class IntegrationInboundSemTemplate {

    @HttpPost
    global static ResponseInboundOrders upsertOrder(List<OrderData> request) {
        List<Order> ordersToUpsertList = new List<Order>();
        List<OrderItem> orderItemsToUpsertList = new List<OrderItem>();
        List<OrderItemData> orderItemDataList= new List<OrderItemData>();
        Map<String, String> externalIdsOrderItemToOrder = new  Map<String, String>();
        Map<String, Response> orderResponseMap = new Map<String, Response>();
        List<Response> responseList = new List<Response>();
        Boolean hasError = false;
        Boolean hasDeleted;
        String orderExternalIds = '';

        for(OrderData iOrderData : request){

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
					externalIdsOrderItemToOrder.put(iOrderItemData.itemCode, iOrderData.orderCode);
					iOrderItemData.orderExternalId = iOrderData.orderCode;
				}

				orderItemDataList.addAll(iOrderData.orderItems);
			}
            if(orderExternalIds == '') orderExternalIds += iOrderData.orderCode;
            else orderExternalIds += + ', ' + iOrderData.orderCode;
        }

        List<Order> ordersWithStatusActiveted = new List<Order>();
		for(Order iOrder : ordersToUpsertList) {
			if(iOrder.Status == 'Aprovado') {
				ordersWithStatusActiveted.add(iOrder);
				iOrder.Status = 'Novo';
			}
		}

        List<Database.UpsertResult> upsertOrders = Database.upsert(ordersToUpsertList, Order.ExternalId__c, false);
        Map<Id, Order> ordersIdstoOrdersMap = new Map<Id, Order>();

        for (Integer i = 0; i < upsertOrders.size(); i++){
            Order order = ordersToUpsertList[i];
			Database.UpsertResult upsertOrderResult = upsertOrders[i];

            Response responseOrder;
        
            if(upsertOrderResult.isSuccess()){
                responseOrder = new Response(upsertOrderResult.getId(), order.ExternalId__c, false, null, 'Order');
            }else{
                String error = '';
                for(Database.Error iError : upsertOrderResult.getErrors()){
                    error += iError.getMessage() + ' ';
                    hasError = true;
                }
                responseOrder = new Response(null, order.ExternalId__c, true, error, 'Order');
            }
            orderResponseMap.put(order.ExternalId__c, responseOrder);
            responseList.add(responseOrder);
        }

        List<OrderItem> orderItemsInDatabase = new List<OrderItem>([
            SELECT Id, OrderId, Product2Id, UnitPrice, Quantity
            FROM OrderItem
            WHERE ExternalId__c IN :externalIdsOrderItemToOrder.keySet()
        ]);
        delete orderItemsInDatabase;


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
                    error += iError.getMessage() + ' ';
                    hasError = true;
                }
                responseOrderItem = new Response(null, orderItem.ExternalId__c, true, error, 'OrderItem');
            }
            responseList.add(responseOrderItem);
        }

        hasDeleted = deleteOrderItemNotReceived(ordersToUpsertList, orderItemsToUpsertList);

        for(Order iOrder : ordersWithStatusActiveted) {
			iOrder.Status = 'Aprovado';
		}
        Database.upsert(ordersWithStatusActiveted, Order.ExternalId__c, false);

        for (Integer i = 0; i < upsertOrders.size(); i++){
            Order order = ordersToUpsertList[i];
			Database.UpsertResult upsertOrderResult = upsertOrders[i];
        
            if(!upsertOrderResult.isSuccess()){ 
                String error = '';
                for(Database.Error iError : upsertOrderResult.getErrors()){
                    error += iError.getMessage() + ' ';
                    hasError = true;
                }
                orderResponseMap.get(order.ExternalId__c).hasError = false;
                orderResponseMap.get(order.ExternalId__c).errorMessage = error;
            }
        }
        
        ResponseInboundOrders responseInboundOrders = new ResponseInboundOrders(responseList);

        String endpoint = 'https://brave-shark-nskhtp-dev-ed.trailblaze.my.salesforce.com/services//apexrest/upsertOrder';

        OrderTriggerHandler.disableTrigger();
        String integrationLogId = IntegrationLog.createLog('Order', orderExternalIds, 'INBOUND', JSON.serialize(request), 
        JSON.serialize(responseInboundOrders), endpoint, hasError, hasDeleted);
        IntegrationLog.updateOrderWithIntegrationLogId(ordersToUpsertList, integrationLogId, 'IN');
        
        OrderTriggerHandler.enableTrigger();
                
        RestResponse response = RestContext.response;
		response.statusCode = 201;

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