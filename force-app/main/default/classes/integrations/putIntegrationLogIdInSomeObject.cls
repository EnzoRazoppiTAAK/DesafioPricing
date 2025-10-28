public with sharing class PutIntegrationLogIdInSomeObject {

    public static void updateOrder(List<Order> orderList, String integrationLogId, String integrationType) {
		List<Order> orderUpdateList = new List<Order>();

		System.debug('integrationLogId: ' + integrationLogId);

		for (Order order : [SELECT Id, ReceivedOrderLog__c, SentOrderLog__c FROM Order WHERE Id IN: orderList]) {
			if (integrationType == 'IN') order.ReceivedOrderLog__c = integrationLogId;
			else order.SentOrderLog__c = integrationLogId;

			System.debug('responseObject: ' + order.SentOrderLog__c);

			orderUpdateList.add(order);
		}

		if (!orderUpdateList.isEmpty()) update orderUpdateList;
	}
}