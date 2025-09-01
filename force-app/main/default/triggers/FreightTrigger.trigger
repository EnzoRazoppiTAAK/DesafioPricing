trigger FreightTrigger on Freight__c (before insert, before update) {
    System.debug('Freight__c Trigger Start => ' + Trigger.operationType);
	FreightTriggerHandler handler = new FreightTriggerHandler(
		Trigger.old,
		Trigger.new,
		Trigger.oldMap,
		Trigger.newMap
	);

    if (FreightTriggerHandler.isTriggerEnabled()) {
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