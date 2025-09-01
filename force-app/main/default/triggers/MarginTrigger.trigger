trigger MarginTrigger on Margin__c (before insert, before update) {
    System.debug('Margin__c Trigger Start => ' + Trigger.operationType);
	MarginTriggerHandler handler = new MarginTriggerHandler(
		Trigger.old,
		Trigger.new,
		Trigger.oldMap,
		Trigger.newMap
	);

    if (MarginTriggerHandler.isTriggerEnabled()) {
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