global with sharing class InboundOrderJSONError {
    
    global static InboundResponse.InboundResponseList makeJSONErrorResponse(Exception e){
        String error;
        List<InboundResponse> responseList = new List<InboundResponse>();

        if(e.getMessage().contains('either a decimal digit number')) {
            error = 'Quantity, UnitPrice e ListPrice devem receber números.';
            responseList.add(
                InboundResponse.builder()
                .setHasError(true)
                .setErrorMessage(error)
                .setSObjectType('OrderItem')
                .build()
            );

        }else{
            error = 'JSON mal formatado.';
            responseList.add(
                InboundResponse.builder()
                .setHasError(true)
                .setErrorMessage(error)
                .build()
            );
        }

        return new InboundResponse.InboundResponseList(responseList);
    }
}