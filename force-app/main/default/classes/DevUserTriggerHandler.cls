public with sharing class DevUserTriggerHandler {
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

	List<DevUser__c> oldRecordList { get; set; }
	List<DevUser__c> newRecordList { get; set; }
	Map<Id, DevUser__c> oldRecordMap { get; set; }
	Map<Id, DevUser__c> newRecordMap { get; set; }

	public DevUserTriggerHandler(
		List<DevUser__c> oldRecordList,
		List<DevUser__c> newRecordList,
		Map<Id, DevUser__c> oldRecordMap,
		Map<Id, DevUser__c> newRecordMap
	) {
		this.oldRecordList = oldRecordList;
		this.newRecordList = newRecordList;
		this.oldRecordMap = oldRecordMap;
		this.newRecordMap = newRecordMap;
	}

    public void afterInsert() {
        DevUserTriggerHelper.handleAfterInsertDevUser(newRecordList);
	}
	public void afterUpdate() {
		DevUserTriggerHelper.handleAfterUpdateDevUser(newRecordList, oldRecordMap);
	}
}