global with sharing class CalloutResponse {

    public String salesforceId;
    public String externalCode;
    public Boolean hasError;
    public String errorMessage;
    public String sobjectType;

    public CalloutResponse(ResponseBuilder builder){
        this.salesforceId = builder.salesforceId;
        this.externalCode = builder.externalCode;
        this.hasError = builder.hasError;
        this.errorMessage = builder.errorMessage;
        this.sobjectType = builder.sobjectType;
    }

    public static ResponseBuilder builder(){
        return new ResponseBuilder();
    }

    global class ResponseBuilder{
        public String salesforceId;
        public String externalCode;
        public Boolean hasError;
        public String errorMessage;
        public String sObjectType;

        public ResponseBuilder setSalesforceId(String salesforceId){
            this.salesforceId = salesforceId;
            return this;
        }

        public ResponseBuilder setExternalCode(String externalCode){
            this.externalCode = externalCode;
            return this;
        }

        public ResponseBuilder setHasError(Boolean hasError){
            this.hasError = hasError;
            return this;
        }

        public ResponseBuilder setErrorMessage(String errorMessage){
            this.errorMessage = errorMessage;
            return this;
        }

        public ResponseBuilder setSObjectType(String sObjectType){
            this.sObjectType = sObjectType;
            return this;
        }

        public CalloutResponse build(){
            return new CalloutResponse(this);
        }
    }

    global class CalloutResponseList{

        public List<CalloutResponse> response;

        public CalloutResponseList(List<CalloutResponse> response){
            this.response = response;
        }
    }
}