trigger GoalTrigger on Goal__c (before insert) {

    System.debug('Goal__c Trigger Start => ' + Trigger.operationType);
	GoalTriggerHandler handler = new GoalTriggerHandler(
		Trigger.old,
		Trigger.new,
		Trigger.oldMap,
		Trigger.newMap
	);

    if (GoalTriggerHandler.isTriggerEnabled()) {
		switch on Trigger.operationType {

			when BEFORE_INSERT {
				handler.beforeInsert();
			}
		}
    }
}