public with sharing class OrderItemTriggerHandler {
    private static Boolean isEnabled;
	static {
		isEnabled = true;
	}
	public static Boolean isTriggerEnabled() {
		return isEnabled;
	}
	public static Boolean disableTrigger() {
		return isEnabled = false;
	}
	public static Boolean enableTrigger() {
		return isEnabled = true;
	}

    List<OrderItem> oldRecordList { get; set; }
	List<OrderItem> newRecordList { get; set; }
	Map<Id, OrderItem> oldRecordMap { get; set; }
	Map<Id, OrderItem> newRecordMap { get; set; }


    public OrderItemTriggerHandler(
        List<OrderItem> oldRecordList,
		List<OrderItem> newRecordList,
		Map<Id, OrderItem> oldRecordMap,
		Map<Id, OrderItem> newRecordMap
    ) {
        this.oldRecordList = oldRecordList;
		this.newRecordList = newRecordList;
		this.oldRecordMap = oldRecordMap;
		this.newRecordMap = newRecordMap;
    }

    public void beforeInsert() {
		OrderItemTriggerHelper.handleInsertOrderItem(this.newRecordList);
		//RequiredFields.verifyRequiredParametersInOrderItem(this.newRecordList);
	}
	public void beforeUpdate() {
        OrderItemTriggerHelper.handleUpdateOrderItem(this.newRecordList);
		//RequiredFields.verifyRequiredParametersInOrderItem(this.newRecordList);
    }
}