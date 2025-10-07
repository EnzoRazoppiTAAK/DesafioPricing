public with sharing class CalloutOrder {
	

	public static IntegrationUtils.CalloutResponse processIntegration(Set<Id> ordersIds){

		List<Order> parentOrders = [SELECT Id, ExternalId__c, Account.ExternalId__c, AccountAddress__r.ExternalId__c, PaymentCondition__r.ExternalId__c, 
		EffectiveDate, FreightType__c, DistributionCenter__r.ExternalId__c, deliveryDate__c, Status, Observation__c, 
		(SELECT ExternalId__c, Product2.ExternalId__c, TotvsItem__c, UnitPrice, ListPrice, Quantity FROM OrderItems) 
		FROM Order 
		WHERE Id IN: ordersIds
		];
		
		List<Order> allOrders = new List<Order>();
		allOrders.addAll(parentOrders);
		
		IntegrationUtils.CalloutResponse calloutResponse = sendOrder(allOrders);
		
		return calloutResponse;
	}
	public static IntegrationUtils.CalloutResponse sendOrder(List<Order> orders) {
			
		List<RequestParameters> requestOrders = new List<RequestParameters>();
        String orderExternalIds = '';
        Integer count = 0;
		for (Order ord : orders) {
            count++;
			requestOrders.add(new RequestParameters(ord));
            if(!(count == orders.size())){
                orderExternalIds += ord.ExternalId__c + ', ';
            }else{
                orderExternalIds += ord.ExternalId__c;
            }
		}

		RequestListOfOrders requestToSerialize = new RequestListOfOrders(requestOrders);

		System.debug('requestToSerialize: ' + requestToSerialize);
		String payloadOUT = JSON.serialize(requestToSerialize);

		//Metodo para busca de Access Token, depende de cada projeto, podendo estar presente dentro de uma custom settings ou relacionado com outra requisição.
		String accessToken = '';

        String enpointToGetAccessToken = 'https://wise-unicorn-s16esy-dev-ed.trailblaze.my.salesforce.com/services/oauth2/token?grant_type=password&username=eliascesariocunha@wise-unicorn-s16esy.com&password=@Isaias12345m7ynR1UY7OtHq3LL8j05KmsZt&client_id=3MVG91oqviqJKoEFS_xc5vonpnfCPHaFnq8llaEQ.dRofKn5V6H9ozppUEyEe6gxobgfaTGcgzvF4YXFEtCF_&client_secret=A1F4834D18708BF4CD04E896B98D4C0FAC4AA55AF0647C7AD6059A120F69B1DD';
        String payloadOutToGetAccessToken = '';
        Map<String, String> headersTogGetAccessTokenMap = new Map<String, String>();
        IntegrationUtils.RequestResponseObject responseObjectToGetAccessToken = IntegrationUtils.executeCallout(
			enpointToGetAccessToken, 
			payloadOutToGetAccessToken, 
			headersTogGetAccessTokenMap
		);

        if(responseObjectToGetAccessToken.success){
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(responseObjectToGetAccessToken.response.getBody());
            accessToken = (String) responseMap.get('access_token');
        }

		System.debug('accessToken: ' + accessToken);
		
		//Path geralmente cadastrado dentro de ua customSettings
		String endpoint = 'https://wise-unicorn-s16esy-dev-ed.trailblaze.my.salesforce.com/services//apexrest/upsertOrder';
		Map<String, String> headersMap = new Map<String, String>();
		headersMap.put('Content-type', 'application/json');
		headersMap.put('Authorization', 'Bearer '+ accessToken);

		System.debug('payloadOUT: ' + payloadOUT);
		
		IntegrationUtils.RequestResponseObject responseObject = IntegrationUtils.executeCallout(endpoint, payloadOUT, headersMap);

		System.debug('responseObject: ' + responseObject);

		OrderTriggerHandler.disableTrigger();
		if (responseObject.success) {

			HttpResponse httpResponse = responseObject.response;

			String integrationLogId = IntegrationLog.createLog('Order', orderExternalIds, 'OUTBOUND', httpResponse.getBody(), payloadOUT, endpoint, false, false);
			IntegrationLog.updateOrderWithIntegrationLogId(orders, integrationLogId, 'OUT');
			OrderTriggerHandler.enableTrigger();
			try {

				List<ResponseParametersWrapper> responses = (List<ResponseParametersWrapper>) JSON.deserialize(httpResponse.getBody(), List<ResponseParametersWrapper>.class);
				return new IntegrationUtils.CalloutResponse(new ResponseParameters(responses));
			} catch (Exception e) {
				
				String defaultErrorMessage = 'Malformatted HTTP Response Exception: ' + e.getMessage();

				return new IntegrationUtils.CalloutResponse(defaultErrorMessage);
			}
		} else {
			String integrationLogId = IntegrationLog.createLog('Order', orderExternalIds, 'OUTBOUND', responseObject.exceptionObject.getMessage(), payloadOUT, endpoint, true, false);
			IntegrationLog.updateOrderWithIntegrationLogId(orders, integrationLogId, 'OUT');
			OrderTriggerHandler.enableTrigger();
			return new IntegrationUtils.CalloutResponse(responseObject.exceptionObject.getMessage());
		}
	}

	public class RequestParameters {
		//Order Fields
		//Example

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

		public OrderItemParameters[] orderItems;

		public RequestParameters(Order order) {

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
			
			this.orderItems = new List<OrderItemParameters>();

			for (OrderItem iOrderItem : order.OrderItems) {
				orderItems.add(new OrderItemParameters(iOrderItem));
			}
		}
	}

	public class OrderItemParameters {
		//OrderItem Fields
		//Example

		public String itemCode;
		public Decimal quantity;
		public Decimal unitPrice;
		public Decimal listPrice;
		public String productCode;
		public Boolean totvsItem;


		public OrderItemParameters(OrderItem iOrderItem) {
			this.itemCode = iOrderItem.ExternalId__c;
			this.quantity = iOrderItem.Quantity;
			this.unitPrice = iOrderItem.UnitPrice;
			this.listPrice = iOrderItem.ListPrice;
			this.productCode = iOrderItem.Product2.ExternalId__c;
			this.totvsItem = iOrderItem.TotvsItem__c;
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
		public String error;
		public String SalesforceCode;
		public String ERPCode;
	}

	public class requestListOfOrders {
		//JSON enviado é uma lista com o nome request
		List<RequestParameters> request;

		public requestListOfOrders(List<RequestParameters> orders) {
			this.request = orders;
		}
	}
}