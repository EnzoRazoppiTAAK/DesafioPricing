trigger TaxTrigger on Tax__c (before insert, before update) {
    System.debug('Tax__c Trigger Start => ' + Trigger.operationType);
	TaxTriggerHandler handler = new TaxTriggerHandler(
		Trigger.old,
		Trigger.new,
		Trigger.oldMap,
		Trigger.newMap
	);

    if (TaxTriggerHandler.isTriggerEnabled()) {
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