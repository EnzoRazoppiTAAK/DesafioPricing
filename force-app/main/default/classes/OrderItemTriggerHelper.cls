public with sharing class OrderItemTriggerHelper {
    public static void handleInsertOrderItem(List<OrderItem> newRecordList){
        searchForTheTax(newRecordList);
        
        /*Map<Id, List<OrderItem>> orderItemMap = new Map<Id, OrderItem>();
        for(OrderItem iOrderItem: newRecordList){
            if(orderItemMap.containsKey(iOrderItem.Product2Id)){
                orderItemMap.get(iOrderItem.Product2erId).add(iOrderItem);
            }else{
                orderItemMap.put(iOrderItem.Product2Id, new List<OrderItem>{iOrderItem});
            }
        }
        Set<id> productId = new Set<id>();
        Set<id> productHierarchyId = new Set<id>();
        Set<id> orderId = new Set<id>();
        Set<id> accountId = new Set<id>();
        Set<id> accountGroupId = new Set<id>();
        Set<id> cityId = new Set<id>();
        Set<id> stateId = new Set<id>();
        Set<id> countryId = new Set<id>();
        for(OrderItem iOrderItem: orderItemMap.values()){
            productId.add(iOrderItem.Product2Id);
        }
        List<Product2> productsList = [
            SELECT Id, ProductHierarchy__c 
            FROM Product2 
            WHERE Id IN :productId
            ];
        for(Product2 iProduct: productsList){
            productHierarchyId.add(iProduct.ProductHierarchy__c);
        }
        for(OrderItem iOrderItem: orderItemMap.values()){
            orderId.add(iOrderItem.OrderId);
        }
        List<Order> ordersList = [
            SELECT Id, AccountId, AccountAddress__r.City__c 
            FROM Order
            WHERE Id IN :orderId
            ];
        for(Order iOrder: ordersList){
            accountId.add(iOrder.AccountId);
        List<Account> accountsList = [
            SELECT Id, AccountGroup__c
            FROM Account
            WHERE Id IN :accountId
            ];
        for(Account iAccount: accountsList){
            accountGroupId.add(iAccount.AccountGroup__c);
        }
        List<AccountAddress__c> accountAddressList = [
            SELECT Id, City__c 
            FROM AccountAddress__c 
            WHERE Account__c IN :accountId
            ];
        for(AccountAddress__c iAccountAddress: accountAddressList){
            cityId.add(iAccountAddress.City__c);
        }
        List<City> citiesList = [
            SELECT Id, State__c 
            FROM City 
            WHERE Id IN :cityId
            ];
        List<Margin__c> listMargin = [
            SELECT Id, ProductHierarchy__c, Product__c 
            FROM Margin__c 
            WHERE Product__c IN :productsId
            OR ProductHierarchy__c IN :productHierarchyId
            ];*/
    }
    public static void handleUpdateOrderItem(List<OrderItem> newRecordList){
        
    }
    public static void searchForTheMostSpecificFreight(List<OrderItem> newRecordList){
        Map<Id, List<OrderItem>> newOrderItemMap = new Map<Id, List<OrderItem>>();
        for(OrderItem iOrderItem: newRecordList){
            if(newOrderItemMap.containsKey(iOrderItem.OrderId)){
                newOrderItemMap.get(iOrderItem.OrderId).add(iOrderItem);
            }else{
                newOrderItemMap.put(iOrderItem.OrderId, new List<OrderItem>{iOrderItem});
            }
        }
        Set<id> productsIds = new Set<id>();
        Set<id> productHierarchyId = new Set<id>();
        Set<id> ordersIds = new Set<id>();
        Set<Id> accountAddressIds = new Set<id>();
        Set<Id> citiesIds = new Set<id>();
        Set<Id> statesIds = new Set<id>();
        Set<Id> countriesIds = new Set<id>();
        for(OrderItem iOrderItem: newRecordList){
            productsIds.add(iOrderItem.Product2Id);
            ordersIds.add(iOrderItem.OrderId);
        }
        List<Product2> productsList = [
            SELECT Id, ProductHierarchy__c
            FROM Product2 
            WHERE Id IN :productsIds
            ];
        Map<Id, Product2> productsMap = new Map<id, Product2>();
        for(Product2 iProduct: productsList){
            productsMap.put(iProduct.Id, iProduct);
            productHierarchyId.add(iProduct.ProductHierarchy__c);
        }
        List<Order> ordersList = [
            SELECT Id, AccountAddress__c
            FROM Order
            WHERE Id IN :ordersIds
        ];
        for(Order iOrder: ordersList){
            accountAddressIds.add(iOrder.AccountAddress__c);
        }
        List<AccountAddress__c> accountAddressList = [
            SELECT City__c 
            FROM AccountAddress__c 
            WHERE Id IN :accountAddressIds
            ];
        Map<Id, AccountAddress__c> accountAddressMap = new Map<Id, AccountAddress__c>();
        for(AccountAddress__c iAccountAddress: accountAddressList){
            accountAddressMap.put(iAccountAddress.Id, iAccountAddress);
        }
        List<City__c> citiesList = [
            SELECT Id, State__c
            FROM City__c
            WHERE Id IN (SELECT City__c FROM AccountAddress__c WHERE Id IN :accountAddressIds)
            ];
        Map<Id, City__c> citiesMap = new Map<Id, City__c>();
        for(City__c iCity: citiesList){
            citiesIds.add(iCity.Id);
            statesIds.add(iCity.State__c);
            citiesMap.put(iCity.Id, iCity);
        }
        List<State__c> statesList = [
            SELECT Id, Country__c
            FROM State__c
            WHERE Id IN :statesIds
            ];
        Map<Id, State__c> statesMap = new Map<Id, State__c>();
        for(State__c iState: statesList){
            countriesIds.add(iState.Country__c);
            statesMap.put(iState.Id, iState);
        }
        List<Freight__c> freightsInDatabase = [ 
            SELECT Id, Product__c, ProductHierarchy__c, City__c, State__c, Country__c, Status__c
            FROM Freight__c 
            WHERE (Product__c IN :productsIds
            OR ProductHierarchy__c IN :productHierarchyId
            OR City__c IN :citiesIds
            OR State__c IN :statesIds
            OR Country__c IN :countriesIds)
            AND Status__c = 'Aprovado'
            ];
        Map<String, Freight__c> freightsMap = new Map<String, Freight__c>();
        for(Freight__c iFreight: freightsInDatabase){
            String freightKey = iFreight.Product__c+'-'+iFreight.ProductHierarchy__c+'-'+iFreight.City__c+'-'+iFreight.State__c+'-'+iFreight.Country__c;
            freightsMap.put(freightKey, iFreight);
        }
        Map<OrderItem, String> orderItemMapToSearchFreight = new Map<OrderItem, String>();
        for(Order iOrder: ordersList){
            String city = accountAddressMap.get(iOrder.AccountAddress__c).City__c;
            String state = citiesMap.get(accountAddressMap.get(iOrder.AccountAddress__c).City__c).State__c;
            String country = statesMap.get(citiesMap.get(accountAddressMap.get(iOrder.AccountAddress__c).City__c).State__c).Country__c;
            String address = city+'-'+state+'-'+country;
            for(OrderItem iOrderItem: newOrderItemMap.get(iOrder.Id)){
                String productHierarchy = productsMap.get(iOrderItem.Product2Id).ProductHierarchy__c;
                String orderItemKey = iOrderItem.Product2Id+'-'+productHierarchy+'-'+address;
                orderItemMapToSearchFreight.put(iOrderItem, orderItemKey);
            }
        }
        for(OrderItem iOrderItem: orderItemMapToSearchFreight.keySet()){
            String[] IdsInOrderItemString = orderItemMapToSearchFreight.get(iOrderItem).split('-');
            String searchProductAndCity = IdsInOrderItemString[0]+'-'+IdsInOrderItemString[2];
            String searchProductAndState = IdsInOrderItemString[0]+'-'+IdsInOrderItemString[3];
            String searchProductAndCountry = IdsInOrderItemString[0]+'-'+IdsInOrderItemString[4];
            String searchProductHierachyAndCity = IdsInOrderItemString[1]+'-'+IdsInOrderItemString[2];
            String searchProductHierachyAndState = IdsInOrderItemString[1]+'-'+IdsInOrderItemString[3];
            String searchProductHierachyAndCountry = IdsInOrderItemString[1]+'-'+IdsInOrderItemString[4];
            
            if(freightsMap.containsKey(searchProductAndCity)){
                iOrderItem.FreightValue__c = freightsMap.get(searchProductAndCity).Value__c;
            }
            else if(freightsMap.containsKey(searchProductAndState)){
                iOrderItem.FreightValue__c = freightsMap.get(searchProductAndState).Value__c;
            }
            else if(freightsMap.containsKey(searchProductAndCountry)){
                iOrderItem.FreightValue__c = freightsMap.get(searchProductAndCountry).Value__c;
            }
            else if(freightsMap.containsKey(searchProductHierachyAndCity)){
                iOrderItem.FreightValue__c = freightsMap.get(searchProductHierachyAndCity).Value__c;
            }
            else if(freightsMap.containsKey(searchProductHierachyAndState)){
                iOrderItem.FreightValue__c = freightsMap.get(searchProductHierachyAndState).Value__c;
            }
            else if(freightsMap.containsKey(searchProductHierachyAndCountry)){
                iOrderItem.FreightValue__c = freightsMap.get(searchProductHierachyAndCountry).Value__c;
            }
        }
    }

    public static void searchForTheTax(List<OrderItem> newRecordList){
        Map<Id, List<OrderItem>> newOrderItemMap = new Map<Id, List<OrderItem>>();
        for(OrderItem iOrderItem: newRecordList){
            if(newOrderItemMap.containsKey(iOrderItem.OrderId)){
                newOrderItemMap.get(iOrderItem.OrderId).add(iOrderItem);
            }else{
                newOrderItemMap.put(iOrderItem.OrderId, new List<OrderItem>{iOrderItem});
            }
        }
        Set<id> productsIds = new Set<id>();
        Set<id> ordersIds = new Set<id>();
        Set<Id> distributionCentersIds = new Set<id>();
        Set<Id> accountAddressIds = new Set<id>();
        Set<Id> statesIds = new Set<id>();
        for(OrderItem iOrderItem: newRecordList){
            productsIds.add(iOrderItem.Product2Id);
            ordersIds.add(iOrderItem.OrderId);
        }
        List<Order> ordersList = [
            SELECT Id, AccountAddress__c, DistributionCenter__c
            FROM Order
            WHERE Id IN :ordersIds
        ];
        for(Order iOrder: ordersList){
            distributionCentersIds.add(iOrder.DistributionCenter__c);
            accountAddressIds.add(iOrder.AccountAddress__c);
        }
        List<AccountAddress__c> accountAddressList = [
            SELECT City__c 
            FROM AccountAddress__c 
            WHERE Id IN :accountAddressIds
            ];
        Map<Id, AccountAddress__c> accountAddressMap = new Map<Id, AccountAddress__c>();
        for(AccountAddress__c iAccountAddress: accountAddressList){
            accountAddressMap.put(iAccountAddress.Id, iAccountAddress);
        }
        List<City__c> citiesList = [
            SELECT Id, State__c
            FROM City__c
            WHERE Id IN (SELECT City__c FROM AccountAddress__c WHERE Id IN :accountAddressIds)
            ];
        Map<Id, City__c> citiesMap = new Map<Id, City__c>();
        for(City__c iCity: citiesList){
            citiesMap.put(iCity.Id, iCity);
            statesIds.add(iCity.State__c);
        }
        List<Tax__c> taxesInDatabase = [
            SELECT Id, Name, Product__c, State__c, Status__c, DistributionCenter__c, TaxOnCost__c
            FROM Tax__c
            WHERE Product__c IN :productsIds
            AND State__c IN :statesIds
            AND Status__c = 'Aprovado'
            AND DistributionCenter__c IN :distributionCentersIds
            ];
        Map<String, List<OrderItem>> orderItemMapToSearchTax = new Map<String, List<OrderItem>>();
        for(Order iOrder: ordersList){
            Id state = citiesMap.get(accountAddressMap.get(iOrder.AccountAddress__c).City__c).State__c;
            for(OrderItem iOrderItem: newOrderItemMap.get(iOrder.Id)){
                String orderItemKey = iOrderItem.Product2Id+'-'+state+'-'+iOrder.DistributionCenter__c;
                if(orderItemMapToSearchTax.containsKey(orderItemKey)){
                    orderItemMapToSearchTax.get(orderItemKey).add(iOrderItem);
                }else{
                    orderItemMapToSearchTax.put(orderItemKey, new List<OrderItem>{iOrderItem});
                }
            }
        }
        for(Tax__c iTax: taxesInDatabase){
            String taxKey = iTax.Product__c+'-'+iTax.State__c+'-'+iTax.DistributionCenter__c;
            if(orderItemMapToSearchTax.containsKey(taxKey)){
                for(OrderItem iOrderItem: orderItemMapToSearchTax.get(taxKey)){
                    iOrderItem.TaxPercentage__c = iTax.TaxOnCost__c;
                }
            }
        }
    }
}


