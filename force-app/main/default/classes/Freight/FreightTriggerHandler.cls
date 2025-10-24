public with sharing class FreightTriggerHandler {
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

	List<Freight__c> oldRecordList { get; set; }
	List<Freight__c> newRecordList { get; set; }
	Map<Id, Freight__c> oldRecordMap { get; set; }
	Map<Id, Freight__c> newRecordMap { get; set; }

	public FreightTriggerHandler(
		List<Freight__c> oldRecordList,
		List<Freight__c> newRecordList,
		Map<Id, Freight__c> oldRecordMap,
		Map<Id, Freight__c> newRecordMap
	) {
		this.oldRecordList = oldRecordList;
		this.newRecordList = newRecordList;
		this.oldRecordMap = oldRecordMap;
		this.newRecordMap = newRecordMap;
	}

    public void beforeInsert() {
		FreightTriggerHelper.FreightsRequiredFields(this.newRecordList);
		FreightTriggerHelper.handleInsertFreight(this.newRecordList);
	}
	public void beforeUpdate() {
		FreightTriggerHelper.FreightsRequiredFields(this.newRecordList);
        FreightTriggerHelper.handleUpdateFreight(this.newRecordList);
	}
}