trigger OrderItemTrigger on OrderItem (before insert, before update) {
    System.debug('OrderItem Trigger Start => ' + Trigger.operationType);
	OrderItemTriggerHandler handler = new OrderItemTriggerHandler(
		Trigger.old,
		Trigger.new,
		Trigger.oldMap,
		Trigger.newMap
	);

    if (OrderItemTriggerHandler.isTriggerEnabled()) {
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