public with sharing class OrderTriggerHandler {
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

    List<Order> oldRecordList { get; set; }
	List<Order> newRecordList { get; set; }
	Map<Id, Order> oldRecordMap { get; set; }
	Map<Id, Order> newRecordMap { get; set; }


    public OrderTriggerHandler(
        List<Order> oldRecordList,
		List<Order> newRecordList,
		Map<Id, Order> oldRecordMap,
		Map<Id, Order> newRecordMap
    ) {
        this.oldRecordList = oldRecordList;
		this.newRecordList = newRecordList;
		this.oldRecordMap = oldRecordMap;
		this.newRecordMap = newRecordMap;
    }
    public void beforeInsert() {
        OrderTriggerHelper.handleBeforeInsertOrder(newRecordList);
    }
	public void beforeUpdate() {
        OrderTriggerHelper.handleBeforeUpdateOrder(newRecordList, oldRecordMap);
    }
}