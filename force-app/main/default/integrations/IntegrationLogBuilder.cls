public with sharing class IntegrationLogBuilder {

    public String integrationName;
	public String externalIdList;
	public String recordTypeName;
	public String payloadIN;
	public String payloadOUT;
	public String endpoint;
	public Boolean hasAnyErrors;
	public Boolean hasDeleted;    

	private IntegrationLogBuilder(Builder builder){
		this.integrationName = builder.integrationName;
		this.externalIdList = builder.externalIdList;
		this.recordTypeName = builder.recordTypeName;
		this.payloadIN = builder.payloadIN;
		this.payloadOUT = builder.payloadOUT;
		this.endpoint = builder.endpoint;
		this.hasAnyErrors = builder.hasAnyErrors;
		this.hasDeleted = builder.hasDeleted;
	}
    
	public static Builder builder(){
		return new Builder();
	}

	public class Builder{

		private String integrationName;
		private String externalIdList;
		private String recordTypeName;
		private String payloadIN;
		private String payloadOUT;
		private String endpoint;
		private Boolean hasAnyErrors;
		private Boolean hasDeleted;

		public Builder setIntegrationName(String integrationName){
			this.integrationName = integrationName;
			return this;
		}

		public Builder setExternalIdList(String externalIdList){
			this.externalIdList = externalIdList;
			return this;
		}

		public Builder setRecordTypeName(String recordTypeName){
			this.recordTypeName = recordTypeName;
			return this;
		}

		public Builder setPayloadIN(String payloadIN){
			this.payloadIN = payloadIN;
			return this;
		}

		public Builder setPayloadOUT(String payloadOUT){
			this.payloadOUT = payloadOUT;
			return this;
		}

		public Builder setEndpoint(String endpoint){
			this.endpoint = endpoint;
			return this;
		}

		public Builder setHasAnyErrors(Boolean hasAnyErrors){
			this.hasAnyErrors = hasAnyErrors;
			return this;
		}

		public Builder setHasDeleted(Boolean hasDeleted){
			this.hasDeleted = hasDeleted;
			return this;
		}

		public IntegrationLogBuilder build(){
			return new IntegrationLogBuilder(this);
		}
	}
}