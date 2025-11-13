public with sharing class GoalItemTriggerHandler {
    
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

	List<GoalItem__c> oldRecordList { get; set; }
	List<GoalItem__c> newRecordList { get; set; }
	Map<Id, GoalItem__c> oldRecordMap { get; set; }
	Map<Id, GoalItem__c> newRecordMap { get; set; }

	public GoalItemTriggerHandler(
		List<GoalItem__c> oldRecordList,
		List<GoalItem__c> newRecordList,
		Map<Id, GoalItem__c> oldRecordMap,
		Map<Id, GoalItem__c> newRecordMap
	) {
		this.oldRecordList = oldRecordList;
		this.newRecordList = newRecordList;
		this.oldRecordMap = oldRecordMap;
		this.newRecordMap = newRecordMap;
	}

	public void beforeInsert() {
		GoalItemTriggerHelper.handleBeforeInsertGoalItem(newRecordList);
	}

    public void beforeUpdate() {
		GoalItemTriggerHelper.handleBeforeUpdateGoalItem(newRecordList);
	}
}