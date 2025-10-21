public with sharing class IntegrationLog {

	public static Id createLog(IntegrationLogBuilder integrationLogBuilder){

		System.debug('');
		// Se os dados forem maiores que 100.000 TRUE, se não FALSE
		Boolean attachmentIN = (integrationLogBuilder.payloadIN.length() > 130000);
		Boolean attachmentOUT = (integrationLogBuilder.payloadOUT.length() > 130000);
		Datetime datetimeNow = System.now(); // Data Atual
		// Pega Id do log de integração (IN ou OUT)
		Id recordTypeId = Schema.SObjectType.IntegrationLog__c.getRecordTypeInfosByDeveloperName().containsKey(integrationLogBuilder.recordTypeName) ?
							Schema.SObjectType.IntegrationLog__c.getRecordTypeInfosByName().get(integrationLogBuilder.recordTypeName).getRecordTypeId()
							: null;

		if (recordTypeId == null) System.debug('Falha ao pegar o recordTypeId do log de integração => ' + recordTypeId);

		IntegrationLog__c log = createIntegrationLogRecord(
			integrationLogBuilder.integrationName, integrationLogBuilder.externalIdList, integrationLogBuilder.recordTypeName, 
			attachmentIN, attachmentOUT, integrationLogBuilder.payloadIN, integrationLogBuilder.payloadOUT, integrationLogBuilder.endpoint, 
			integrationLogBuilder.hasAnyErrors, datetimeNow, integrationLogBuilder.hasDeleted
		);

		try { // Insere o log de integração e cria anexo se for necessario
			insert log;

			// Confere se é necessario criar anexo
			if (attachmentIN) createAttachment(log.Id, integrationLogBuilder.integrationName, 'IN', log.Name, String.valueOf(datetimeNow), integrationLogBuilder.payloadIN);
			if (attachmentOUT) createAttachment(log.Id, integrationLogBuilder.integrationName, 'OUT', log.Name, String.valueOf(datetimeNow), integrationLogBuilder.payloadOUT);
		}
		catch (Exception error) {
			System.debug('EXCEPTION ON LOG - Please review parameters - ' + error.getMessage() + ' - ' + error.getStackTraceString());
			log.Status__c = 'Error';
			log.ErrorMessage__c = error.getMessage();
		}

		return log.Id;
	}

	public static IntegrationLog__c createIntegrationLogRecord(String integrationName, String externalIdList,
									String recordTypeName, Boolean attachmentIN, Boolean attachmentOUT, String payloadIN,
									String payloadOUT, String endpoint, Boolean hasAnyErrors, Datetime datetimeNow, Boolean hasDeleted) {
		return new IntegrationLog__c(
			Name = integrationName + ' ' + recordTypeName,
			Endpoint__c = endpoint,
			ExternalIdList__c = externalIdList.length() > 255 ? externalIdList.substring(0, 256) : externalIdList,
			Attachment__c = (attachmentIN || attachmentOUT),
			PayloadIN__c = (attachmentIN  ? '' : payloadIN),
			PayloadOUT__c = (attachmentOUT ? '' : payloadOUT),
			ExecutionDate__c = datetimeNow,
			Status__c = (hasAnyErrors ? 'Error' : 'Success'),
			ErrorMessage__c = '',
			HasDeleted__c = hasDeleted
		);
	}

	@TestVisible
	private static Id createAttachment(String recordId, String integrationName, String inOrOut, String logName, String timeAsString, String payload){
		Attachment attachment = new Attachment(
			Name = 'LOG-' + integrationName + '-' + inOrOut + '-' + timeAsString + '.txt',
			Body = Blob.valueOf(payload),
			ParentId = recordId
		);

		insert attachment;

		return attachment.Id;
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