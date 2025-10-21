global with sharing class OrderDTO {
    public List<OrderData> request;

    public OrderDTO(List<OrderData> request){
        this.request = request;
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

        public OrderData(Order order){
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

            this.orderItems = new List<OrderItemData>();

            for (OrderItem iOrderItem : order.OrderItems) {
                orderItems.add(new OrderItemData(iOrderItem));
            }
        }
    }

    global class OrderItemData{
        public String orderExternalId;
		public String itemCode;
		public Decimal quantity;
		public Decimal unitPrice;
		public Decimal listPrice;
		public String productCode;
		public Boolean totvsItem;

        public OrderItemData(OrderItem orderItem){
            this.productCode = orderItem.Product2.ExternalId__c;
            this.itemCode = orderItem.ExternalId__c;
            this.totvsItem = orderItem.TotvsItem__c;
            this.unitPrice = orderItem.UnitPrice;
            this.listPrice = orderItem.ListPrice;
            this.quantity = orderItem.Quantity;
        }
    }
}