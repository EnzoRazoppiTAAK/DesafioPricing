@RestResource(urlMapping='/Order/*')
global with sharing class Integration {

    /*global class receivedOrderItemsFromTOTVS {
        public String productCode;
        public String orderitemCode;
        public Boolean totvsItem;
        public Date deliveryDate;
        public Decimal unitPrice;
        public Decimal motorPrice;
        public Integer quantity;
        public String status;
    }

    global class receivedOrderFromTOTVS {
        public String clienteCode;
        public String addressCode;
        public String conditionCode;
        public Date effectiveDate;
        public String freightType;
        public String distributionCenter;
        public String orderNumber;
        public Date deliveryDate;
        public Date deliveryDateERP;
        public String status;
        public String obs;
        public Integer priority;
        List<receivedOrderItemsFromTOTVS> orderItems;
    }

    global class ResponsePut{
        public String salesforceId;
        public String externalCode;
        public Boolean status;
        public String errorMessage;
        public String sObjectType;
    }

    @HttpGet
    global static Order doGet(){
        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;
        String orderExternalId = request.requestURI.substring(request.requestURI.lastIndexOf('/')+1);
        try{
            Order order = [
                SELECT Id, AccountId, DistributionCenter__c, PaymentCondition__c, ContractId, AccountAddress__c, Observation__c, TotalAmount, EffectiveDate, Pricebook2Id, Status, FreightType__c 
                FROM Order 
                WHERE ExternalId__c = :orderExternalId 
                LIMIT 1
            ];
            if(order == null){
                response.statusCode = 404;
                throw new NotFoundException('Order not found with ExternalId: ' + orderExternalId + '.');
            }else{
                SentOrderLog__c sentOrderLog = new SentOrderLog__c();
                sentOrderLog.Order__c = order.Id;
                sentOrderLog.Application__c = 'API clients';
                sentOrderLog.LogUserId__c = UserInfo.getUserId();
                sentOrderLog.Operation__c = 'REST GET';
                sentOrderLog.Request__c = 'API';
                sentOrderLog.StartTime__c = datetime.now();
                sentOrderLog.Status__c = 'Success';

                insert sentOrderLog;
                return order;
            }
        }catch(Exception e){
            response.statusCode = 404;
            return null;
        }
    }
    
    @HttpPut
    global static List<ResponsePut> doPut(List<receivedOrderFromTOTVS> request){
        RestResponse response = RestContext.response;

        Set<String> accountsExtenalIds = new Set<String>();
        Set<String> accountAddressesExternalIds = new Set<String>();
        Set<String> PaymentConditionsExternalIds = new Set<String>();
        Set<String> distributionCenterExternalIds = new Set<String>();
        Set<String> productsExternalIds = new Set<String>();
        Set<Id> productsIds = new Set<Id>();

        for(receivedOrderFromTOTVS iReceivedOrderFromTOTVS: request){
            accountsExtenalIds.add(iReceivedOrderFromTOTVS.clienteCode);
            accountAddressesExternalIds.add(iReceivedOrderFromTOTVS.addressCode);
            PaymentConditionsExternalIds.add(iReceivedOrderFromTOTVS.conditionCode);
            distributionCenterExternalIds.add(iReceivedOrderFromTOTVS.distributionCenter);
            for(receivedOrderItemsFromTOTVS iReceivedOrderItemsFromTOTVS: iReceivedOrderFromTOTVS.orderItems){
                productsExternalIds.add(iReceivedOrderItemsFromTOTVS.productCode);
            }
        }

       List<Account> accountsList = new List<Account>([
            SELECT Id, ExternalId__c
            FROM Account
            WHERE ExternalId__c IN :accountsExtenalIds
        ]);
        Map<String, Account> accountsMap = new Map<String, Account>();
        for(Account iAccount: accountsList){
            accountsMap.put(iAccount.ExternalId__c, iAccount);
        }
        List<AccountAddress__c> accountsAddressesList = new List<AccountAddress__c>([
            SELECT Id, ExternalId__c
            FROM AccountAddress__c
            WHERE ExternalId__c IN :accountAddressesExternalIds
        ]);
        Map<String, AccountAddress__c> accountAddressesMap = new Map<String, AccountAddress__c>();
        for(AccountAddress__c iAccountAddress: accountsAddressesList){
            accountAddressesMap.put(iAccountAddress.ExternalId__c, iAccountAddress);
        }
        List<PaymentCondition__c> PaymentConditionList = new List<PaymentCondition__c>([
            SELECT Id, ExternalId__c
            FROM PaymentCondition__c
            WHERE ExternalId__c IN :PaymentConditionsExternalIds
        ]);
        Map<String, PaymentCondition__c> PaymentConditionMap = new Map<String, PaymentCondition__c>();
        for(PaymentCondition__c iPaymentCondition: PaymentConditionList){
            PaymentConditionMap.put(iPaymentCondition.ExternalId__c, iPaymentCondition);
        }
        List<DistributionCenter__c> distributionCenterList = new List<DistributionCenter__c>([
            SELECT Id, ExternalId__c
            FROM DistributionCenter__c
            WHERE ExternalId__c IN :distributionCenterExternalIds
        ]);
        Map<String, DistributionCenter__c> distributionCenterMap = new Map<String, DistributionCenter__c>();
        for(DistributionCenter__c iDistributionCenter: distributionCenterList){
            distributionCenterMap.put(iDistributionCenter.ExternalId__c, iDistributionCenter);
        }
        List<Product2> productsList = new List<Product2>([
            SELECT Id, ExternalId__c
            FROM Product2
            WHERE ExternalId__c IN :productsExternalIds
        ]);
        Map<String, Product2> productsMap = new Map<String, Product2>();
        for(Product2 iProduct: productsList){
            productsMap.put(iProduct.ExternalId__c, iProduct);
            productsIds.add(iProduct.Id);
        }

        Savepoint sp = Database.setSavepoint();

        try{
            List<Order> receivedOrdersList = new List<Order>();
            Integer count = 0;
            for(receivedOrderFromTOTVS iReceivedOrderFromTOTVS: request){
                count++;
                Order order = new Order();
                if(iReceivedOrderFromTOTVS.clienteCode == null || !accountsMap.containsKey(iReceivedOrderFromTOTVS.clienteCode)){
                    throw new NotFoundException('Client not found with code: ' + iReceivedOrderFromTOTVS.clienteCode + 'in order '+ count + '.');
                }else{
                    order.AccountId = accountsMap.get(iReceivedOrderFromTOTVS.clienteCode).Id;
                }
                if(iReceivedOrderFromTOTVS.addressCode == null || !accountAddressesMap.containsKey(iReceivedOrderFromTOTVS.addressCode)){
                    throw new NotFoundException('Address not found with code: ' + iReceivedOrderFromTOTVS.addressCode + 'in order '+ count + '.');
                }else{
                    order.AccountAddress__c = accountAddressesMap.get(iReceivedOrderFromTOTVS.addressCode).Id;
                }
                if(iReceivedOrderFromTOTVS.conditionCode == null || !PaymentConditionMap.containsKey(iReceivedOrderFromTOTVS.conditionCode)){
                    throw new NotFoundException('Payment condition not found with code: ' + iReceivedOrderFromTOTVS.conditionCode + 'in order '+ count + '.');
                }else{
                    order.PaymentCondition__c = PaymentConditionMap.get(iReceivedOrderFromTOTVS.conditionCode).Id;
                }
                if(iReceivedOrderFromTOTVS.distributionCenter == null || !distributionCenterMap.containsKey(iReceivedOrderFromTOTVS.distributionCenter)){
                    throw new NotFoundException('Distribution center not found with code: ' + iReceivedOrderFromTOTVS.distributionCenter + 'in order '+ count + '.');
                }else{
                    order.DistributionCenter__c = distributionCenterMap.get(iReceivedOrderFromTOTVS.distributionCenter).Id;
                }
                if(iReceivedOrderFromTOTVS.orderNumber == null){
                    throw new NotFoundException('Order not found with code: ' + iReceivedOrderFromTOTVS.orderNumber + 'in order '+ count + '.');
                }else{
                    order.ExternalId__c = iReceivedOrderFromTOTVS.orderNumber;
                }

                order.EffectiveDate = iReceivedOrderFromTOTVS.effectiveDate;
                order.FreightType__c = iReceivedOrderFromTOTVS.freightType;
                order.deliveryDate__c = iReceivedOrderFromTOTVS.deliveryDate;
                order.deliveryDateERP__c = iReceivedOrderFromTOTVS.deliveryDateERP;
                order.Status = iReceivedOrderFromTOTVS.status;
                order.Observation__c = iReceivedOrderFromTOTVS.obs;
                order.Priority__c = iReceivedOrderFromTOTVS.priority;
                order.ERPItem__c = true;

                receivedOrdersList.add(order);
            }
            Database.upsert(receivedOrdersList, Order.ExternalId__c, true);

            Map<String, Order> ordersMap = new Map<String, Order>();
            for(Order iOrder: receivedOrdersList){
                ordersMap.put(iOrder.ExternalId__c, iOrder);
            }

            Set<String> ordersItemsExternalIds = new Set<String>();
            List<OrderItem> receivedOrdersItermsList = new List<OrderItem>();
            count = 0;
            for(receivedOrderFromTOTVS iReceivedOrderFromTOTVS: request){
                count++;
                for(receivedOrderItemsFromTOTVS iReceivedOrderItemsFromTOTVS: iReceivedOrderFromTOTVS.orderItems){
                    OrderItem orderItem = new OrderItem();
                    if(iReceivedOrderItemsFromTOTVS.productCode == null || !productsMap.containsKey(iReceivedOrderItemsFromTOTVS.productCode)){
                        response.statusCode = 400;
                        throw new NotFoundException('Product not found with code:' + iReceivedOrderItemsFromTOTVS.productCode + ' in order '+ count + '.');
                    }else{
                        orderItem.Product2Id = productsMap.get(iReceivedOrderItemsFromTOTVS.productCode).Id;
                    }
                    ordersItemsExternalIds.add(iReceivedOrderItemsFromTOTVS.orderitemCode);
                    orderItem.ExternalId__c = iReceivedOrderItemsFromTOTVS.orderitemCode;
                    orderItem.TotvsItem__c = iReceivedOrderItemsFromTOTVS.totvsItem;
                    orderItem.UnitPrice = iReceivedOrderItemsFromTOTVS.unitPrice;
                    orderItem.deliveryDate__c = date.valueOf(iReceivedOrderItemsFromTOTVS.deliveryDate);
                    orderItem.ListPrice	 = iReceivedOrderItemsFromTOTVS.motorPrice;
                    orderItem.Quantity = iReceivedOrderItemsFromTOTVS.quantity;
                    orderItem.OrderId = ordersMap.get(iReceivedOrderFromTOTVS.orderNumber).Id;

                    receivedOrdersItermsList.add(orderItem);
                }
            }

            List<OrderItem> orderItemsInDatabase = new List<OrderItem>([
                SELECT Id, OrderId, Product2Id, UnitPrice, Quantity
                FROM OrderItem
                WHERE ExternalId__c IN :ordersItemsExternalIds
            ]);

            delete orderItemsInDatabase;

            Database.upsert(receivedOrdersItermsList, OrderItem.ExternalId__c, true);

            List<ReceivedOrderLog__c> receivedOrderLogsToInsert = new List<ReceivedOrderLog__c>();
            List<ResponsePut> responsePutList = new List<ResponsePut>();
            for(Order iOrder: receivedOrdersList){
                ReceivedOrderLog__c receivedOrderLog = new ReceivedOrderLog__c();
                receivedOrderLog.Application__c = 'API clients';
                receivedOrderLog.LogUserId__c = UserInfo.getUserId();
                receivedOrderLog.Operation__c = 'REST PUT';
                receivedOrderLog.Request__c = 'API';
                receivedOrderLog.StartTime__c = datetime.now();
                receivedOrderLog.Status__c = 'Success';
                receivedOrderLog.Order__c = iOrder.Id;
                receivedOrderLogsToInsert.add(receivedOrderLog);
                
                ResponsePut responsePut = new ResponsePut();
                responsePut.salesforceId = iOrder.Id;
                responsePut.externalCode = iOrder.orderNumber;
                responsePut.status = true;
                responsePut.errorMessage = '';
                responsePut.sObjectType = 'Order';
                responsePutList.add(responsePut);
            }

            insert receivedOrderLogsToInsert;
            response.statusCode = 201;
            return responsePutList;

        }catch(Exception e){
            Database.rollback(sp);

            response.statusCode = 400;
            ResponsePut responsePut = new ResponsePut();
            responsePut.errorMessage = e.getMessage();
            responsePut.status = false;
            List<ResponsePut> responsePutList = new List<ResponsePut>{responsePut};

            return responsePutList;
        }
    }

    @HttpDelete
    global static void doDelete(){
        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;
        String orderExternalId = request.requestURI.substring(request.requestURI.lastIndexOf('/')+1);
        try{
            Order order = [
                SELECT Id, AccountId, DistributionCenter__c, PaymentCondition__c, ContractId, AccountAddress__c, Observation__c, TotalAmount, EffectiveDate, Pricebook2Id, Status, FreightType__c 
                FROM Order 
                WHERE ExternalId__c = :orderExternalId 
                LIMIT 1
            ];
            if(order == null){
                throw new NotFoundException('Order not found with ExternalId: ' + orderExternalId + '.');
            }else{
                ReceivedOrderLog__c receivedOrderLog = new ReceivedOrderLog__c();
                receivedOrderLog.Application__c = 'API clients';
                receivedOrderLog.LogUserId__c = UserInfo.getUserId();
                receivedOrderLog.Operation__c = 'REST DELETE';
                receivedOrderLog.Request__c = 'API';
                receivedOrderLog.StartTime__c = datetime.now();
                receivedOrderLog.Status__c = 'Success';
                receivedOrderLog.Order__c = order.Id;

                order.DeleteFromERP__c = true;
                update order;
                response.statusCode = 204;
                insert receivedOrderLog;
            }
        }catch(Exception e){
            response.statusCode = 404;
        }
    }*/
}

