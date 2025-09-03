public with sharing class MarginTriggerHandler {
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

	List<Margin__c> oldRecordList { get; set; }
	List<Margin__c> newRecordList { get; set; }
	Map<Id, Margin__c> oldRecordMap { get; set; }
	Map<Id, Margin__c> newRecordMap { get; set; }

    public MarginTriggerHandler(
        List<Margin__c> oldRecordList,
		List<Margin__c> newRecordList,
		Map<Id, Margin__c> oldRecordMap,
		Map<Id, Margin__c> newRecordMap
    ) {
        this.oldRecordList = oldRecordList;
		this.newRecordList = newRecordList;
		this.oldRecordMap = oldRecordMap;
		this.newRecordMap = newRecordMap;
    }

    public void beforeInsert() {
		RequiredFields.MarginRequiredFields(this.newRecordList);
		MarginTriggerHelper.handleInsertMargin(this.newRecordList);
	}
	public void beforeUpdate() {
		RequiredFields.MarginRequiredFields(this.newRecordList);
        MarginTriggerHelper.handleUpdateMargin(this.newRecordList);
    }
}