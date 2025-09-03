public with sharing class TaxTriggerHandler {
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

	List<Tax__c> oldRecordList { get; set; }
	List<Tax__c> newRecordList { get; set; }
	Map<Id, Tax__c> oldRecordMap { get; set; }
	Map<Id, Tax__c> newRecordMap { get; set; }

    public TaxTriggerHandler(
        List<Tax__c> oldRecordList,
		List<Tax__c> newRecordList,
		Map<Id, Tax__c> oldRecordMap,
		Map<Id, Tax__c> newRecordMap
    ) {
		this.oldRecordList = oldRecordList;
		this.newRecordList = newRecordList;
		this.oldRecordMap = oldRecordMap;
		this.newRecordMap = newRecordMap;
	}

    public void beforeInsert() {
		TaxTriggerHelper.handleInsertTax(this.newRecordList);
	}
	public void beforeUpdate() {
        TaxTriggerHelper.handleUpdateTax(this.newRecordList);
    }
}