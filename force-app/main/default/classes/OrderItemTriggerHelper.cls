public with sharing class OrderItemTriggerHelper {
    public static void handleInsertOrderItem(List<OrderItem> newRecordList){
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
        Set<Id> accountsAddressesIds = new Set<id>();
        Set<Id> AccountsGroupsIds = new Set<id>();
        Set<Id> statesIds = new Set<id>();
        Set<Id> countriesIds = new Set<id>();
        Set<Id> distributionCentersIds = new Set<id>();
        for(OrderItem iOrderItem: newRecordList){
            productsIds.add(iOrderItem.Product2Id);
            ordersIds.add(iOrderItem.OrderId);
        }
        Map<Id, Product2> productsMap = new Map<id, Product2>([
            SELECT Id, ProductHierarchy__c, ProductionCost__c
            FROM Product2 
            WHERE Id IN :productsIds
            ]);
        for(Product2 iProduct: productsMap.values()){
            productHierarchyId.add(iProduct.ProductHierarchy__c);
        }
        Map<Id, Order> ordersMap = new Map<id, Order>([
            SELECT Id, AccountId, AccountAddress__c, DistributionCenter__c
            FROM Order
            WHERE Id IN :ordersIds
            ]);
        for(Order iOrder: ordersMap.values()){
            accountsAddressesIds.add(iOrder.AccountAddress__c);
            distributionCentersIds.add(iOrder.DistributionCenter__c);
        }
        Map<Id, Account> accountsMap = new Map<id, Account>([
            SELECT Id, AccountGroup__c
            FROM Account
            WHERE Id IN (SELECT AccountId FROM Order WHERE Id IN :ordersIds)
            ]);
        for(Account iAccount: accountsMap.values()){
            AccountsGroupsIds.add(iAccount.AccountGroup__c);
        }
        Map<Id, AccountAddress__c> accountAddressMap = new Map<id, AccountAddress__c>([
            SELECT Id, City__c 
            FROM AccountAddress__c 
            WHERE Id IN :accountsAddressesIds
            ]);
        Map<Id, City__c> citiesMap = new Map<id, City__c>([
            SELECT Id, State__c
            FROM City__c
            WHERE Id IN (SELECT City__c FROM AccountAddress__c WHERE Id IN :accountsAddressesIds)
            ]);
        for(City__c iCity: citiesMap.values()){
            statesIds.add(iCity.State__c);
        }
        Map<Id, State__c> statesMap = new Map<id, State__c>([
            SELECT Id, Country__c
            FROM State__c
            WHERE Id IN :statesIds
            ]);
        for(State__c iState: statesMap.values()){
            countriesIds.add(iState.Country__c);
        }
        searchForTheTax(newOrderItemMap, productsIds, statesIds, distributionCentersIds, 
        ordersMap, accountAddressMap, citiesMap);
        searchForTheMostSpecificFreight(newOrderItemMap, productsIds, productHierarchyId, statesIds, countriesIds, 
        productsMap, ordersMap, accountAddressMap, citiesMap, statesMap);
        searchForTheMostSpecificMargin(newOrderItemMap, productsIds, productHierarchyId, AccountsGroupsIds, statesIds, countriesIds, 
        productsMap, ordersMap, accountAddressMap, accountsMap, citiesMap, statesMap);
    }
    public static void handleUpdateOrderItem(List<OrderItem> newRecordList){
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
        Set<Id> accountsAddressesIds = new Set<id>();
        Set<Id> AccountsGroupsIds = new Set<id>();
        Set<Id> statesIds = new Set<id>();
        Set<Id> countriesIds = new Set<id>();
        Set<Id> distributionCentersIds = new Set<id>();
        for(OrderItem iOrderItem: newRecordList){
            productsIds.add(iOrderItem.Product2Id);
            ordersIds.add(iOrderItem.OrderId);
        }
        Map<Id, Product2> productsMap = new Map<id, Product2>([
            SELECT Id, ProductHierarchy__c
            FROM Product2 
            WHERE Id IN :productsIds
            ]);
        for(Product2 iProduct: productsMap.values()){
            productHierarchyId.add(iProduct.ProductHierarchy__c);
        }
        Map<Id, Order> ordersMap = new Map<id, Order>([
            SELECT Id, AccountId, AccountAddress__c, DistributionCenter__c
            FROM Order
            WHERE Id IN :ordersIds
            ]);
        for(Order iOrder: ordersMap.values()){
            accountsAddressesIds.add(iOrder.AccountAddress__c);
            distributionCentersIds.add(iOrder.DistributionCenter__c);
        }
        Map<Id, Account> accountsMap = new Map<id, Account>([
            SELECT Id, AccountGroup__c
            FROM Account
            WHERE Id IN (SELECT AccountId FROM Order WHERE Id IN :ordersIds)
            ]);
        for(Account iAccount: accountsMap.values()){
            AccountsGroupsIds.add(iAccount.AccountGroup__c);
        }
        Map<Id, AccountAddress__c> accountAddressMap = new Map<id, AccountAddress__c>([
            SELECT Id, City__c 
            FROM AccountAddress__c 
            WHERE Id IN :accountsAddressesIds
            ]);
        Map<Id, City__c> citiesMap = new Map<id, City__c>([
            SELECT Id, State__c
            FROM City__c
            WHERE Id IN (SELECT City__c FROM AccountAddress__c WHERE Id IN :accountsAddressesIds)
            ]);
        for(City__c iCity: citiesMap.values()){
            statesIds.add(iCity.State__c);
        }
        Map<Id, State__c> statesMap = new Map<id, State__c>([
            SELECT Id, Country__c
            FROM State__c
            WHERE Id IN :statesIds
            ]);
        for(State__c iState: statesMap.values()){
            countriesIds.add(iState.Country__c);
        }
        searchForTheTax(newOrderItemMap, productsIds, statesIds, distributionCentersIds, 
        ordersMap, accountAddressMap, citiesMap);
        searchForTheMostSpecificFreight(newOrderItemMap, productsIds, productHierarchyId, statesIds, countriesIds, 
        productsMap, ordersMap, accountAddressMap, citiesMap, statesMap);
        searchForTheMostSpecificMargin(newOrderItemMap, productsIds, productHierarchyId, AccountsGroupsIds, statesIds, countriesIds, 
        productsMap, ordersMap, accountAddressMap, accountsMap, citiesMap, statesMap);
    }
    public static void searchForTheMostSpecificMargin(Map<Id, List<OrderItem>> newOrderItemMap, Set<Id> productsIds, 
    Set<Id> productHierarchyId, Set<Id> AccountsGroupsIds, Set<Id> statesIds, Set<Id> countriesIds,
    Map<Id, Product2> productsMap, Map<Id, Order> ordersMap, Map<Id, AccountAddress__c> accountAddressMap, Map<Id, Account> accountsMap, 
    Map<Id, City__c> citiesMap, Map<Id, State__c> statesMap ){
    
        List<Margin__c> marginsInDatabase = [ 
            SELECT Id, Product__c, ProductHierarchy__c, Account__c, AccountGroup__c, City__c, State__c, Country__c, Status__c, Value__c
            FROM Margin__c 
            WHERE (Product__c IN :productsIds
            OR ProductHierarchy__c IN :productHierarchyId)
            AND (Account__c IN :accountsMap.keySet()
            OR AccountGroup__c IN :AccountsGroupsIds)
            AND(City__c IN :citiesMap.keySet()
            OR State__c IN :statesIds
            OR Country__c IN :countriesIds)
            AND Status__c = 'Aprovado'
            ];
        Map<String, Margin__c> marginsMap = new Map<String, Margin__c>();
        for(Margin__c iMargin: marginsInDatabase){
            String marginKey = iMargin.Product__c+''+iMargin.ProductHierarchy__c+''+iMargin.Account__c+''+iMargin.AccountGroup__c+''+iMargin.City__c+''+iMargin.State__c+''+iMargin.Country__c;
            marginKey = marginKey.replace('null', '');
            marginsMap.put(marginKey, iMargin);
        }
        Map<OrderItem, String> orderItemMapToSearchMargin = new Map<OrderItem, String>();
        for(Order iOrder: ordersMap.values()){
            String accountIdString = accountsMap.get(iOrder.AccountId).Id;
            String accountGroupIdString = accountsMap.get(iOrder.AccountId).AccountGroup__c;
            String cityIdString = accountAddressMap.get(iOrder.AccountAddress__c).City__c;
            String stateIdString = citiesMap.get(accountAddressMap.get(iOrder.AccountAddress__c).City__c).State__c;
            String countryIdString = statesMap.get(citiesMap.get(accountAddressMap.get(iOrder.AccountAddress__c).City__c).State__c).Country__c;
            for(OrderItem iOrderItem: newOrderItemMap.get(iOrder.Id)){
                String productHierarchyIdString = productsMap.get(iOrderItem.Product2Id).ProductHierarchy__c;
                String orderItemKey = iOrderItem.Product2Id+'-'+productHierarchyIdString+'-'+accountIdString+'-'+accountGroupIdString+'-'+cityIdString+'-'+stateIdString+'-'+countryIdString;
                orderItemMapToSearchMargin.put(iOrderItem, orderItemKey);
            }
        }
        for(OrderItem iOrderItem: orderItemMapToSearchMargin.keySet()){
            List<String> IdsInOrderItemString = orderItemMapToSearchMargin.get(iOrderItem).split('-');
            String searchProductAccountCity = IdsInOrderItemString.get(0)+''+IdsInOrderItemString.get(2)+''+IdsInOrderItemString.get(4);
            String searchProductAccountState= IdsInOrderItemString.get(0)+''+IdsInOrderItemString.get(2)+''+IdsInOrderItemString.get(5);
            String searchProductAccountCountry = IdsInOrderItemString.get(0)+''+IdsInOrderItemString.get(4)+''+IdsInOrderItemString.get(6);
            String searchProductAccountGroupCity = IdsInOrderItemString.get(0)+''+IdsInOrderItemString.get(3)+''+IdsInOrderItemString.get(4);
            String searchProductAccountGroupState = IdsInOrderItemString.get(0)+''+IdsInOrderItemString.get(3)+''+IdsInOrderItemString.get(5);
            String searchProductAccountGroupCountry = IdsInOrderItemString.get(0)+''+IdsInOrderItemString.get(3)+''+IdsInOrderItemString.get(6);
            String searchProductHierachyAccountCity = IdsInOrderItemString.get(1)+''+IdsInOrderItemString.get(2)+''+IdsInOrderItemString.get(4);
            String searchProductHierachyAccountState = IdsInOrderItemString.get(1)+''+IdsInOrderItemString.get(2)+''+IdsInOrderItemString.get(5);
            String searchProductHierachyAccountCountry = IdsInOrderItemString.get(1)+''+IdsInOrderItemString.get(2)+''+IdsInOrderItemString.get(6);
            String searchProductHierachyAccountGroupCity = IdsInOrderItemString.get(1)+''+IdsInOrderItemString.get(3)+''+IdsInOrderItemString.get(4);
            String searchProductHierachyAccountGroupState = IdsInOrderItemString.get(1)+''+IdsInOrderItemString.get(3)+''+IdsInOrderItemString.get(5);
            String searchProductHierachyAccountGroupCountry = IdsInOrderItemString.get(1)+''+IdsInOrderItemString.get(3)+''+IdsInOrderItemString.get(6);

            if(marginsMap.containsKey(searchProductAccountCity)){
                iOrderItem.MarginPercentage__c = marginsMap.get(searchProductAccountCity).Value__c;
            }
            else if(marginsMap.containsKey(searchProductAccountState)){
                iOrderItem.MarginPercentage__c = marginsMap.get(searchProductAccountState).Value__c;
            }
            else if(marginsMap.containsKey(searchProductAccountCountry)){
                iOrderItem.MarginPercentage__c = marginsMap.get(searchProductAccountCountry).Value__c;
            }
            else if(marginsMap.containsKey(searchProductAccountGroupCity)){
                iOrderItem.MarginPercentage__c = marginsMap.get(searchProductAccountGroupCity).Value__c;
            }
            else if(marginsMap.containsKey(searchProductAccountGroupState)){
                iOrderItem.MarginPercentage__c = marginsMap.get(searchProductAccountGroupState).Value__c;
            }
            else if(marginsMap.containsKey(searchProductAccountGroupCountry)){
                iOrderItem.MarginPercentage__c = marginsMap.get(searchProductAccountGroupCountry).Value__c;
            }
            else if(marginsMap.containsKey(searchProductHierachyAccountCity)){
                iOrderItem.MarginPercentage__c = marginsMap.get(searchProductHierachyAccountCity).Value__c;
            }
            else if(marginsMap.containsKey(searchProductHierachyAccountState)){
                iOrderItem.MarginPercentage__c = marginsMap.get(searchProductHierachyAccountState).Value__c;
            }
            else if(marginsMap.containsKey(searchProductHierachyAccountCountry)){
                iOrderItem.MarginPercentage__c = marginsMap.get(searchProductHierachyAccountCountry).Value__c;
            }
            else if(marginsMap.containsKey(searchProductHierachyAccountGroupCity)){
                iOrderItem.MarginPercentage__c = marginsMap.get(searchProductHierachyAccountGroupCity).Value__c;
            }
            else if(marginsMap.containsKey(searchProductHierachyAccountGroupState)){
                iOrderItem.MarginPercentage__c = marginsMap.get(searchProductHierachyAccountGroupState).Value__c;
            }
            else if(marginsMap.containsKey(searchProductHierachyAccountGroupCountry)){
                iOrderItem.MarginPercentage__c = marginsMap.get(searchProductHierachyAccountGroupCountry).Value__c;
            }
            else{
                iOrderItem.MarginPercentage__c = null;
            }
        }
    }
    public static void searchForTheMostSpecificFreight(Map<Id, List<OrderItem>> newOrderItemMap, Set<Id> productsIds, 
    Set<Id> productHierarchyId, Set<Id> statesIds, Set<Id> countriesIds,
    Map<Id, Product2> productsMap, Map<Id, Order> ordersMap, Map<Id, AccountAddress__c> accountAddressMap,
    Map<Id, City__c> citiesMap, Map<Id, State__c> statesMap){
        
        List<Freight__c> freightsInDatabase = [ 
            SELECT Id, Product__c, ProductHierarchy__c, City__c, State__c, Country__c, Status__c, Value__c
            FROM Freight__c 
            WHERE (Product__c IN :productsIds
            OR ProductHierarchy__c IN :productHierarchyId)
            AND(City__c IN :citiesMap.keySet()
            OR State__c IN :statesIds
            OR Country__c IN :countriesIds)
            AND Status__c = 'Aprovado'
            ];
        Map<String, Freight__c> freightsMap = new Map<String, Freight__c>();
        for(Freight__c iFreight: freightsInDatabase){
            String freightKey = iFreight.Product__c+''+iFreight.ProductHierarchy__c+''+iFreight.City__c+''+iFreight.State__c+''+iFreight.Country__c;
            freightkey = freightkey.replace('null', '');
            freightsMap.put(freightKey, iFreight);
        }
        Map<OrderItem, String> orderItemMapToSearchFreight = new Map<OrderItem, String>();
        for(Order iOrder: ordersMap.values()){
            String cityIdString = accountAddressMap.get(iOrder.AccountAddress__c).City__c;
            String stateIdString = citiesMap.get(accountAddressMap.get(iOrder.AccountAddress__c).City__c).State__c;
            String countryIdString = statesMap.get(citiesMap.get(accountAddressMap.get(iOrder.AccountAddress__c).City__c).State__c).Country__c;
            for(OrderItem iOrderItem: newOrderItemMap.get(iOrder.Id)){
                String productHierarchyIdString = productsMap.get(iOrderItem.Product2Id).ProductHierarchy__c;
                String orderItemKey = iOrderItem.Product2Id+'-'+productHierarchyIdString+'-'+cityIdString+'-'+stateIdString+'-'+countryIdString;
                orderItemMapToSearchFreight.put(iOrderItem, orderItemKey);
            }
        }
        for(OrderItem iOrderItem: orderItemMapToSearchFreight.keySet()){
            List<String> IdsInOrderItemString = orderItemMapToSearchFreight.get(iOrderItem).split('-');
            String searchProductAndCity = IdsInOrderItemString.get(0)+''+IdsInOrderItemString.get(2);
            String searchProductAndState = IdsInOrderItemString.get(0)+''+IdsInOrderItemString.get(3);
            String searchProductAndCountry = IdsInOrderItemString.get(0)+''+IdsInOrderItemString.get(4);
            String searchProductHierachyAndCity = IdsInOrderItemString.get(1)+''+IdsInOrderItemString.get(2);
            String searchProductHierachyAndState = IdsInOrderItemString.get(1)+''+IdsInOrderItemString.get(3);
            String searchProductHierachyAndCountry = IdsInOrderItemString.get(1)+''+IdsInOrderItemString.get(4);
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
            }else{
                iOrderItem.FreightValue__c = null;
            }
        }
    }

    public static void searchForTheTax(Map<Id, List<OrderItem>> newOrderItemMap, Set<Id> productsIds, Set<Id> statesIds,Set<Id> distributionCentersIds, 
    Map<Id, Order> ordersMap, Map<Id, AccountAddress__c> accountAddressMap,Map<Id, City__c> citiesMap){
        
        List<Tax__c> taxesInDatabase = [
            SELECT Id, Name, Product__c, State__c, Status__c, DistributionCenter__c, TaxOnCost__c
            FROM Tax__c
            WHERE Product__c IN :productsIds
            AND State__c IN :statesIds
            AND Status__c = 'Aprovado'
            AND DistributionCenter__c IN :distributionCentersIds
            ];
        Map<String, List<OrderItem>> orderItemMapToSearchTax = new Map<String, List<OrderItem>>();
        for(Order iOrder: ordersMap.values()){
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


