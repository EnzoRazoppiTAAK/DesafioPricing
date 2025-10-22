public with sharing class IntegrationLogUtils {

	@TestVisible
	public static void createAttachment(IntegrationLog__c log, String inOrOut){

		Blob attachmentBody;
		if(inOrOut == 'IN') attachmentBody = Blob.valueOf(log.PayloadIN__c);
		if(inOrOut == 'OUT') attachmentBody = Blob.valueOf(log.PayloadOUT__c);

		Attachment attachment = new Attachment(
			Name = 'LOG-' + log.Name + '-' + inOrOut + '-' + String.valueOf(log.ExecutionDate__c) + '.txt',
			body = attachmentBody,
			ParentId = log.Id
		);

		insert attachment;
	}

	public static void updateOrderWithIntegrationLogId(List<Order> orderList, String integrationLogId, String integrationType) {
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