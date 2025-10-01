global with sharing class DataIntegrationFields {
	public interface FieldData {
		List<String> getRequiredFields();
		String getFieldKey();
		String getFieldId();
		String getExternalId();
		SObject deserialize();
	}

	public interface FieldDataChild {
		List<String> getRequiredFields();
		String getFieldId();
		String getFieldExternal();
		String getParentId();
		String getParentKey();
		SObject deserialize();
	}

	global class OrderINData implements FieldData { // extends OrderBase
		public String id;
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

		public List<OrderItemINData> orderItems {get; set;}

		public Order deserialize() {
			
			return new Order(
				Id						= this.id,
				ExternalId__c			= this.orderCode,
				EffectiveDate			= this.effectiveDate,
				FreightType__c			= this.freightType,
				deliveryDate__c			= this.deliveryDate,
				Status					= this.status,
				Observation__c			= this.obs,
				Account					= new Account(ExternalId__c = this.accountCode),
				AccountAddress__r		= new AccountAddress__c(ExternalId__c = this.addressCode),
				PaymentCondition__r		= new PaymentCondition__c(ExternalId__c = this.paymentCode),
				DistributionCenter__r	= new DistributionCenter__c(ExternalId__c = this.distributionCenterCode)
			);
		}

		public List<String> getRequiredFields() {
			return new List<String>{
				'ExternalId__c',
				'EffectiveDate',
				'Status',
				'FreightType__c'
			};
		}
		public List<String> getRequiredLookups() {
			return new List<String>{
				'AccountId',
				'DistributionCenter__c',
				'PaymentCondition__c',
				'AccountAddress__c'
			};
		}

		public String getFieldKey() {
			return 'ExternalId__c';
		}
		public String getFieldId() {
			return 'Id';
		}
		public String getExternalId() {
			return this.orderCode;
		}
	}
	global class OrderItemINData implements FieldDataChild { // extends OrderItemBase
		public String id;
		public String orderExternalId;
		public String itemCode;
		public Decimal quantity;
		public Decimal unitPrice;
		public Decimal listPrice;
		public String productCode;
		public Boolean totvsItem;

		public OrderItem deserialize() {
			OrderItem orderItem = new OrderItem(
				ExternalId__c	= this.itemCode,
				Quantity		= this.quantity,
				UnitPrice		= this.unitPrice,
				ListPrice 		= this.listPrice,
				TotvsItem__c	= this.totvsItem
			);

			if (this.id == null || this.id == '') {
				orderItem.Order				= new Order(ExternalId__c = this.orderExternalId);
				orderItem.Product2			= new Product2(ExternalId__c = this.productCode);
			}
			else orderItem.Id = this.id;

			return orderItem;
		}

		public List<String> getRequiredFields() {
			return new List<String>{
				'UnitPrice',
				'Quantity',
				'ExternalId__c',
				'ListPrice'
			};
		}
		public List<String> getRequiredLookups() {
			return new List<String>{
				'OrderId',
				'Product2Id'
			};
		}

		public String getFieldId() {
			return 'Id';
		}
		public String getFieldExternal() {
			return 'ExternalId__c';
		}
		public String getParentId() {
			return 'OrderId';
		}
		public String getParentKey() {
			return this.orderExternalId;
		}
	}

	global virtual class Response {
		public String salesforceId;
		public String externalId;
		public String sobjectType;
		public Boolean hasError;
		public String errorMessage;

		public void success(String salesforceId, String externalId, String sobjectType){
			this.salesforceId	= salesforceId;
			this.externalId		= externalId;
			this.sobjectType	= sobjectType;
			this.hasError		= false;
		}

		public void error(String externalId, String errorMessage, String sobjectType){
			this.externalId		= externalId;
			this.sobjectType	= sobjectType;
			this.hasError		= true;
			this.errorMessage	= errorMessage;
		}

		public void error(String salesforceId, String externalId, String errorMessage, String sobjectType){
			this.salesforceId	= salesforceId;
			this.externalId		= externalId;
			this.sobjectType	= sobjectType;
			this.hasError		= true;
			this.errorMessage	= errorMessage;
		}
	}
	global class ResponseParent extends Response {
		public List<DataIntegrationFields.Response> items;
	}
}