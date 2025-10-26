public with sharing class IntegrationLogBuilder {

	public String integrationName;
	public String externalIdList;
	public String recordTypeName;
	public String payloadIN;
	public String payloadOUT;
	public String endpoint;
	public Boolean hasAnyErrors;
	public Boolean hasDeleted;
	public Boolean attachmentIN;
	public Boolean attachmentOUT;
    
	public static IntegrationLogBuilder builder(){
		return new IntegrationLogBuilder();
	}

	public IntegrationLogBuilder setIntegrationName(String integrationName){
		this.integrationName = integrationName;
		return this;
	}

	public IntegrationLogBuilder setExternalIdList(String externalIdList){
		this.externalIdList = externalIdList;
		return this;
	}

	public IntegrationLogBuilder setRecordTypeName(String recordTypeName){
		this.recordTypeName = recordTypeName;
		return this;
	}

	public IntegrationLogBuilder setPayloadIN(String payloadIN){
		this.payloadIN = payloadIN;
		this.attachmentIN = (this.payloadIN.length() > 130000);
		return this;
	}

	public IntegrationLogBuilder setPayloadOUT(String payloadOUT){
		this.payloadOUT = payloadOUT;
		this.attachmentOUT = (this.payloadOUT.length() > 130000);
		return this;
	}

	public IntegrationLogBuilder setEndpoint(String endpoint){
		this.endpoint = endpoint;
		return this;
	}

	public IntegrationLogBuilder setHasAnyErrors(Boolean hasAnyErrors){
		this.hasAnyErrors = hasAnyErrors;
		return this;
	}

	public IntegrationLogBuilder setHasDeleted(Boolean hasDeleted){
		this.hasDeleted = hasDeleted;
		return this;
	}

	public Id build(){

		IntegrationLog__c log = new IntegrationLog__c(
			Name = integrationName + ' ' + recordTypeName,
			Endpoint__c = endpoint,
			ExternalIdList__c = externalIdList.length() > 255 ? externalIdList.substring(0, 256) : externalIdList,
			Attachment__c = (attachmentIN || attachmentOUT),
			PayloadIN__c = (attachmentIN  ? '' : payloadIN),
			PayloadOUT__c = (attachmentOUT ? '' : payloadOUT),
			ExecutionDate__c = System.now(),
			Status__c = (hasAnyErrors ? 'Error' : 'Success'),
			ErrorMessage__c = '',
			HasDeleted__c = hasDeleted
		);

		Id logId = DMLIntegrationLog.insertIntegrationLog(log, attachmentIN, attachmentOUT);

		return logId;
	}
}