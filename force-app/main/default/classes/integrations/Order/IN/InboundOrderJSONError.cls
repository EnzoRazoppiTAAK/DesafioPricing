global with sharing class InboundOrderJSONError {
    
    global static CalloutResponse.CalloutResponseList makeJSONErrorResponse(Exception e){
        String error;
        List<CalloutResponse> responseList = new List<CalloutResponse>();

        if(e.getMessage().contains('either a decimal digit number')) {
            error = 'Quantity, UnitPrice e ListPrice devem receber números.';
            responseList.add(
                CalloutResponse.builder()
                .setHasError(true)
                .setErrorMessage(error)
                .setSObjectType('OrderItem')
                .build()
            );

        }else{
            error = 'JSON mal formatado.';
            responseList.add(
                CalloutResponse.builder()
                .setHasError(true)
                .setErrorMessage(error)
                .build()
            );
        }

        return new CalloutResponse.CalloutResponseList(responseList);
    }
}