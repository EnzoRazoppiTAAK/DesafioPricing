global with sharing class CalloutOrderSemTemplate {

    global static String calloutOrders(Set<Id> OrdersIds){
    
        List<Order> ordersToSendList = [SELECT Id, ExternalId__c, OrderNumber, Account.ExternalId__c, AccountAddress__r.ExternalId__c, PaymentCondition__r.ExternalId__c, 
		EffectiveDate, FreightType__c, DistributionCenter__r.ExternalId__c, deliveryDate__c, Status, Observation__c, 
		(SELECT ExternalId__c, Product2.ExternalId__c, TotvsItem__c, UnitPrice, ListPrice, Quantity FROM OrderItems) 
		FROM Order 
		WHERE Id IN: ordersIds
		];

        for(Order iOrder: ordersToSendList){
            iOrder.ExternalId__c = iOrder.OrderNumber;
        }
        update ordersToSendList;

        String response = sendOrder(ordersToSendList);
        
        return response;
    }

    global static String sendOrder(List<Order> ordersToSendList){

        String orderExternalIds = '';

        List<OrderDataParameters> orderDataParametersList = new List<OrderDataParameters>();
        for(Order iOrder: ordersToSendList){
            orderDataParametersList.add(new OrderDataParameters(iOrder));
            if(orderExternalIds == ''){
                orderExternalIds += iOrder.ExternalId__c;
            }else{
                orderExternalIds += ', '+ iOrder.ExternalId__c;
            }
        }

        OrdersToSerialize ordersToSerialize = new OrdersToSerialize(orderDataParametersList);

        String endpoint = 'callout:OrgDoElias/services//apexrest/upsertOrder';
        String orderJson = JSON.serialize(ordersToSerialize);

        System.debug('EXECUTING CALLOUT');
        System.debug('CALLOUT JSON: '+ orderJson);

        HttpRequest request = new HttpRequest();
        request.setMethod('POST');
        request.setEndpoint(endpoint);
        request.setBody(orderJson);
        request.setHeader('Content-Type', 'application/json');

        HttpResponse response;
        try{
            response = new Http().send(request);

            System.debug('RESPONSE: '+ response.getBody());

            ///////////////MELHORAR A RESPOSTA dO LOG//////////////////////

            String integrationLogId = IntegrationLog.createLog('Order', orderExternalIds, 'OUTBOUND', JSON.serialize(orderJson), 
            JSON.serialize(response.getBody()), endpoint, false, false);
            IntegrationLog.updateOrderWithIntegrationLogId(ordersToSendList, integrationLogId, 'OUT');

            return response.getBody();
            
        }catch(Exception e){
            String integrationLogId = IntegrationLog.createLog('Order', orderExternalIds, 'OUTBOUND', JSON.serialize(orderJson), 
            JSON.serialize(e.getMessage()), endpoint, true, false);
            IntegrationLog.updateOrderWithIntegrationLogId(ordersToSendList, integrationLogId, 'OUT');
            return e.getMessage();
        }
    }

    global class OrdersToSerialize{
        List<OrderDataParameters> request;

        public OrdersToSerialize(List<OrderDataParameters> orderDataParametersList){
            this.request = orderDataParametersList;
        }
    }

    global class OrderDataParameters{
        public String orderCode;
        public String accountCode;
        public String addressCode;
        public String paymentCode;
        public Date effectiveDate;
        public String freightType;
        public String distributionCenterCode;
        public Date deliveryDate;
        public String status;
        public String obs;

        public List<OrderItemDataParameters> orderItems;

        public OrderDataParameters(Order order){
            this.orderCode = order.ExternalId__c;
            this.accountCode = order.Account.ExternalId__c;
            this.addressCode = order.AccountAddress__r.ExternalId__c;
            this.paymentCode = order.PaymentCondition__r.ExternalId__c;
            this.distributionCenterCode = order.DistributionCenter__r.ExternalId__c;
            this.effectiveDate = order.EffectiveDate;
            this.freightType = order.FreightType__c;
            this.deliveryDate = order.deliveryDate__c;
            this.status = order.Status;
            this.obs = order.Observation__c;

            this.orderItems = new List<OrderItemDataParameters>();

            for (OrderItem iOrderItem : order.OrderItems) {
                orderItems.add(new OrderItemDataParameters(iOrderItem));
            }
        }
    }

    global class OrderItemDataParameters{
        public String productCode;
        public String itemCode;
        public Boolean totvsItem;
        public Decimal unitPrice;
        public Decimal listPrice;
        public Decimal quantity;

        public OrderItemDataParameters(OrderItem orderItem){
            this.productCode = orderItem.Product2.ExternalId__c;
            this.itemCode = orderItem.ExternalId__c;
            this.totvsItem = orderItem.TotvsItem__c;
            this.unitPrice = orderItem.UnitPrice;
            this.listPrice = orderItem.ListPrice;
            this.quantity = orderItem.Quantity;
        }
    }
}