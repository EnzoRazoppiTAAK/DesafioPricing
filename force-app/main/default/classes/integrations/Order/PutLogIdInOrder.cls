public with sharing class PutLogIdInOrder {
    
    public static void updateOrder(List<Order> orderList, String integrationLogId, String integrationType) {
		List<Order> orderUpdateList = new List<Order>();

		System.debug('integrationLogId: ' + integrationLogId);

		for (Order iOrder : [SELECT Id, ReceivedOrderLog__c, SentOrderLog__c FROM Order WHERE Id IN: orderList]) {
			if (integrationType == 'IN') iOrder.ReceivedOrderLog__c = integrationLogId;
			else iOrder.SentOrderLog__c = integrationLogId;

			System.debug('responseObject: ' + iOrder.SentOrderLog__c);

			orderUpdateList.add(iOrder);
		}

		if (!orderUpdateList.isEmpty()) update orderUpdateList;
	}
}