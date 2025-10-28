public with sharing class DMLIntegrationLog {
    
    public static Id insertIntegrationLog(IntegrationLog__c log, Boolean attachmentIN, Boolean attachmentOUT){
        try {
			insert log;

			if (attachmentIN) createAttachment(log, 'IN');
			if (attachmentOUT) createAttachment(log, 'OUT');
		}
		catch (Exception error) {
			System.debug('EXCEPTION ON LOG - Please review parameters - ' + error.getMessage() + ' - ' + error.getStackTraceString());
			log.Status__c = 'Error';
			log.ErrorMessage__c = error.getMessage();
		}

		return log.Id;
    }

    @TestVisible
	private static void createAttachment(IntegrationLog__c log, String inOrOut){

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
}