@RestResource(urlMapping='/upsertOrder/*')
global with sharing class InboundOrder_Controller {
    
    @HttpPost
    global static CalloutResponse.CalloutResponseList upsertOrder(){
        RestRequest httpContext = RestContext.request; 
        OrderDTO orderDTO;

        try{
            orderDTO = (OrderDTO) JSON.deserialize(httpContext.requestBody.toString(), OrderDTO.class);
            CalloutResponse.CalloutResponseList responseList = InboundOrder_Service.upsertOrder(orderDTO);

            RestContext.response.statusCode = 201;
            return responseList;

        }catch(Exception e){

            RestContext.response.statusCode = 400;
            return InboundOrderJSONError.makeJSONErrorResponse(e);
        }
    }
}