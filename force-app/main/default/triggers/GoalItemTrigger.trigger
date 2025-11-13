trigger GoalItemTrigger on GoalItem__c (before insert, before update) {

    System.debug('GoalItem__c Trigger Start => ' + Trigger.operationType);
	GoalItemTriggerHandler handler = new GoalItemTriggerHandler(
		Trigger.old,
		Trigger.new,
		Trigger.oldMap,
		Trigger.newMap
	);

    if (GoalItemTriggerHandler.isTriggerEnabled()) {
		switch on Trigger.operationType {

			when BEFORE_INSERT {
				handler.beforeInsert();
			}

            when BEFORE_UPDATE {
				handler.beforeUpdate();
			}
		}
    }
}