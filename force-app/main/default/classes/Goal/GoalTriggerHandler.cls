public with sharing class GoalTriggerHandler {
    
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

	List<Goal__c> oldRecordList { get; set; }
	List<Goal__c> newRecordList { get; set; }
	Map<Id, Goal__c> oldRecordMap { get; set; }
	Map<Id, Goal__c> newRecordMap { get; set; }

	public GoalTriggerHandler(
		List<Goal__c> oldRecordList,
		List<Goal__c> newRecordList,
		Map<Id, Goal__c> oldRecordMap,
		Map<Id, Goal__c> newRecordMap
	) {
		this.oldRecordList = oldRecordList;
		this.newRecordList = newRecordList;
		this.oldRecordMap = oldRecordMap;
		this.newRecordMap = newRecordMap;
	}

	public void beforeInsert() {
		GoalTriggerHelper.handleBeforeInsertGoal(newRecordList);
	}
}