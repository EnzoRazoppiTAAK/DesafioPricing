public with sharing class CalloutOrder {
	

	public static IntegrationUtils.CalloutResponse processIntegration(String orderCode){

		Order parentOrder = [SELECT Id, ExternalId__c ,(SELECT Id, ExternalId__c FROM OrderItems) FROM Order WHERE ExternalId__c = :orderCode];
		
		List<Order> allOrders = new List<Order>{parentOrder};
		
		IntegrationUtils.CalloutResponse calloutResponse = sendOrder(allOrders);

		if (calloutResponse.success) {
			
			ResponseParameters resp = (ResponseParameters) calloutResponse.parsedResponse;
			
			Map<String, Order> orderMap = new Map<String, Order>();

			for (Order ord : allOrders) {
				orderMap.put(ord.OrderNumber, ord);
			}

			List<Order> orderList = new List<Order>();

			for (ResponseParametersWrapper respWrapper : resp.responses) {
				if (orderMap.containsKey(respWrapper.chaveSF)) {

					Order ord = orderMap.get(respWrapper.chaveSF);

					if (respWrapper.erro == 'TRUE') {
						//Error Treatments
					} else {
						//Success Treatments
					}
					
					orderList.add(ord);
				}
			}

			if (!orderList.isEmpty()) {
				update orderList;
			}
		}
		
		return calloutResponse;
	}
	public static IntegrationUtils.CalloutResponse sendOrder(List<Order> orders) {
			
		List<RequestParameters> request = new List<RequestParameters>();

		for (Order ord : orders) {
			request.add(new RequestParameters(ord));
		}

		String payload = JSON.serialize(request);

		//Metodo para busca de Access Token, depende de cada projeto, podendo estar presente dentro de uma custom settings ou relacionado com outra requisição.
		String accessToken = '';
		
		//Path geralmente cadastrado dentro de ua customSettings
		String endpoint = (!Test.isRunningTest() ? 'callout:HANA_Oncoprod/PrePedido_SFOut' : 'http://callout.My_Named_Credential.com/some/path');
		Map<String, String> headersMap = new Map<String, String>();
		headersMap.put('Content-type', 'application/json');
		headersMap.put('Authorization', 'Bearer '+ accessToken);
		
		IntegrationUtils.RequestResponseObject responseObject = IntegrationUtils.executeCallout(endpoint, payload, headersMap);

		if (responseObject.success) {

			HttpResponse response = responseObject.response;

			IntegrationUtils.WSLog('Pedido', 'OUTBOUND', response.getBody(), payload, false);
			try {

				List<ResponseParametersWrapper> responses = (List<ResponseParametersWrapper>) JSON.deserialize(response.getBody(), List<ResponseParametersWrapper>.class);
				return new IntegrationUtils.CalloutResponse(new ResponseParameters(responses));
			} catch (Exception e) {
				
				String defaultErrorMessage = 'Malformatted HTTP Response Exception: ' + e.getMessage();

				return new IntegrationUtils.CalloutResponse(defaultErrorMessage);
			}
		} else {
			IntegrationUtils.WSLog('Pedido', 'OUTBOUND', responseObject.exceptionObject.getMessage(), payload, true);
			return new IntegrationUtils.CalloutResponse(responseObject.exceptionObject.getMessage());
		}
	}

	public class RequestParameters {
		//Order Fields
		//Example

        public String accountCode;
        public String addressCode;
        public String paymentCode;
        public String distributionCenterCode;
        public Date effectiveDate;
        public Date deliveryDate;
        public String freightType;
        public String status;
        public String obs;
		public String orderCode;
		public OrderItemParameters[] orderItems;

		public RequestParameters(Order order) {
			this.orderCode = order.ExternalId__c;			
			this.orderItems = new List<OrderItemParameters>();

			for (OrderItem iOrderItem : order.OrderItems) {
				orderItems.add(new OrderItemParameters(iOrderItem));
			}
		}
	}

	public class OrderItemParameters {
		//OrderItem Fields
		//Example

		public String orderExternalId;
		public String itemCode;
		public Decimal quantity;
		public Decimal unitPrice;
		public Decimal listPrice;
		public String productCode;
		public Boolean totvsItem;


		public OrderItemParameters(OrderItem iOrderItem) {
			this.itemCode = iOrderItem.ExternalId__c;
		}
	}

	public class ResponseParameters {
		public List<ResponseParametersWrapper> responses;

		public ResponseParameters(List<ResponseParametersWrapper> responses) {
			this.responses = responses;
		}
	}

	public class ResponseParametersWrapper {
		public String Status;
		public String Error;
		public String SalesforceCode;
		public String ERPCode;
	}
}