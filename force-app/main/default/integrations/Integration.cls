@RestResource(urlMapping='/upsertOrder/*')
global with sharing class Integration {

    @HttpGet
    global static Order doGet(){
        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;
        String orderId = request.requestURI.substring(request.requestURI.lastIndexOf('/')+1);
        List<Order> order = [
            SELECT Id, AccountId, DistributionCenter__c, PaymentCondition__c, ContractId, AccountAddress__c, Observation__c, TotalAmount, EffectiveDate, Pricebook2Id, Status, FreightType__c 
            FROM Order 
            WHERE ExternalId__c = :orderId 
            LIMIT 1
        ];
        if(order.size() == 0){
            response.statusCode = 404;
            throw new OrderNotFoundException('Order not found with ExternalId: ' + orderId + '. ');
        }else{
            SentOrderLog__c sentOrderLog = new SentOrderLog__c();
            sentOrderLog.Order__c = order.get(0).Id;
            sentOrderLog.Application__c = 'API clients';
            sentOrderLog.LogUserId__c = UserInfo.getUserId();
            sentOrderLog.Operation__c = 'REST GET';
            sentOrderLog.Request__c = 'API';
            sentOrderLog.StartTime__c = datetime.now();
            sentOrderLog.Status__c = 'Success';

            insert sentOrderLog;
            return order.get(0);
        }
    }
    
    @HttpPut
    global static String doPut(String clienteCode, String addressCode, String conditionCode, Date effectiveDate, String freightType, 
    String distributionCenter, String orderNumber, String deliveryDate, String deliveryDateERP, String status, String obs, Integer priority, List<String> orderItems){
        String orderId = request.requestURI.substring(request.requestURI.lastIndexOf('/')+1);
        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;

        Account account = [SELECT Id, Name FROM Account WHERE ExternalId__c = :clienteCode LIMIT 1];
        AccountAddress__c accountAddress = [SELECT Id, Name FROM AccountAddress__c WHERE ExternalId__c = :addressCode LIMIT 1];
        PaymentCondition__c paymentCondition = [SELECT Id, Name FROM PaymentCondition__c WHERE ExternalId__c = :conditionCode LIMIT 1];
        DistributionCenter__c distributionCenter = [SELECT Id, Name FROM DistributionCenter__c WHERE ExternalId__c = :distributionCenter LIMIT 1];
        if(account == null){
            throw new AccountNotFoundException('Account not found with ExternalId: ' + clienteCode + '. ');
        }
        if(accountAddress == null){
            throw new AccountAddressNotFoundException('Account not found with ExternalId: ' + addressCode + '. ');
        }
        if(paymentCondition == null){
            throw new PaymentConditionNotFoundException('Account not found with ExternalId: ' + conditionCode + '. ');
        }
        if(distributionCenter == null){
            throw new DistributionCenterNotFoundException('Account not found with ExternalId: ' + distributionCenter + '. ');
        }
    }
}