public with sharing class OrderItemTriggerHelper {
    public static void handleInsertOrderItem(List<OrderItem> newRecordList){
        calculateParametersInOrderItem(newRecordList);
        calculateFinalPrice(newRecordList);
        calculateFinalTotalPrice(newRecordList);
        joinDuplicates(newRecordList);
    }
    public static void handleUpdateOrderItem(List<OrderItem> newRecordList){
        calculateParametersInOrderItem(newRecordList);
        calculateFinalPrice(newRecordList);
        calculateFinalTotalPrice(newRecordList);
        isERPItem(newRecordList);
        joinDuplicates(newRecordList);
    }
    public static void calculateParametersInOrderItem(List<OrderItem> newRecordList){
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
        searchForTheTax(newOrderItemMap, productsIds, statesIds, 
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
            marginsMap.put(MarginTriggerHelper.getMarginKey(iMargin), iMargin);
        }
        for(Order iOrder: ordersMap.values()){
            String accountIdString = accountsMap.get(iOrder.AccountId).Id;
            String accountGroupIdString = accountsMap.get(iOrder.AccountId).AccountGroup__c;
            String cityIdString = accountAddressMap.get(iOrder.AccountAddress__c).City__c;
            String stateIdString = citiesMap.get(accountAddressMap.get(iOrder.AccountAddress__c).City__c).State__c;
            String countryIdString = statesMap.get(citiesMap.get(accountAddressMap.get(iOrder.AccountAddress__c).City__c).State__c).Country__c;

            for(OrderItem iOrderItem: newOrderItemMap.get(iOrder.Id)){
                String productHierarchyIdString = productsMap.get(iOrderItem.Product2Id).ProductHierarchy__c;

                if(marginsMap.containsKey(iOrderItem.Product2Id+'-'+accountIdString+'-'+cityIdString)){
                    iOrderItem.MarginPercentage__c = marginsMap.get(iOrderItem.Product2Id+'-'+accountIdString+'-'+cityIdString).Value__c;
                }
                else if(marginsMap.containsKey(iOrderItem.Product2Id+'-'+accountIdString+'-'+stateIdString)){
                    iOrderItem.MarginPercentage__c = marginsMap.get(iOrderItem.Product2Id+'-'+accountIdString+'-'+stateIdString).Value__c;
                }
                else if(marginsMap.containsKey(iOrderItem.Product2Id+'-'+accountIdString+'-'+countryIdString)){
                    iOrderItem.MarginPercentage__c = marginsMap.get(iOrderItem.Product2Id+'-'+accountIdString+'-'+countryIdString).Value__c;
                }
                else if(marginsMap.containsKey(iOrderItem.Product2Id+'-'+accountGroupIdString+'-'+cityIdString)){
                    iOrderItem.MarginPercentage__c = marginsMap.get(iOrderItem.Product2Id+'-'+accountGroupIdString+'-'+cityIdString).Value__c;
                }
                else if(marginsMap.containsKey(iOrderItem.Product2Id+'-'+accountGroupIdString+'-'+stateIdString)){
                    iOrderItem.MarginPercentage__c = marginsMap.get(iOrderItem.Product2Id+'-'+accountGroupIdString+'-'+stateIdString).Value__c;
                }
                else if(marginsMap.containsKey(iOrderItem.Product2Id+'-'+accountGroupIdString+'-'+countryIdString)){
                    iOrderItem.MarginPercentage__c = marginsMap.get(iOrderItem.Product2Id+'-'+accountGroupIdString+'-'+countryIdString).Value__c;
                }
                else if(marginsMap.containsKey(productHierarchyIdString+'-'+accountIdString+'-'+cityIdString)){
                    iOrderItem.MarginPercentage__c = marginsMap.get(productHierarchyIdString+'-'+accountIdString+'-'+cityIdString).Value__c;
                }
                else if(marginsMap.containsKey(productHierarchyIdString+'-'+accountIdString+'-'+stateIdString)){
                    iOrderItem.MarginPercentage__c = marginsMap.get(productHierarchyIdString+'-'+accountIdString+'-'+stateIdString).Value__c;
                }
                else if(marginsMap.containsKey(productHierarchyIdString+'-'+accountIdString+'-'+countryIdString)){
                    iOrderItem.MarginPercentage__c = marginsMap.get(productHierarchyIdString+'-'+accountIdString+'-'+countryIdString).Value__c;
                }
                else if(marginsMap.containsKey(productHierarchyIdString+'-'+accountGroupIdString+'-'+cityIdString)){
                    iOrderItem.MarginPercentage__c = marginsMap.get(productHierarchyIdString+'-'+accountGroupIdString+'-'+cityIdString).Value__c;
                }
                else if(marginsMap.containsKey(productHierarchyIdString+'-'+accountGroupIdString+'-'+stateIdString)){
                    iOrderItem.MarginPercentage__c = marginsMap.get(productHierarchyIdString+'-'+accountGroupIdString+'-'+stateIdString).Value__c;
                }
                else if(marginsMap.containsKey(productHierarchyIdString+'-'+accountGroupIdString+'-'+countryIdString)){
                    iOrderItem.MarginPercentage__c = marginsMap.get(productHierarchyIdString+'-'+accountGroupIdString+'-'+countryIdString).Value__c;
                }
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
            freightsMap.put(FreightTriggerHelper.getFreightKey(iFreight), iFreight);
        }
        for(Order iOrder: ordersMap.values()){
            String cityIdString = accountAddressMap.get(iOrder.AccountAddress__c).City__c;
            String stateIdString = citiesMap.get(accountAddressMap.get(iOrder.AccountAddress__c).City__c).State__c;
            String countryIdString = statesMap.get(citiesMap.get(accountAddressMap.get(iOrder.AccountAddress__c).City__c).State__c).Country__c;
            for(OrderItem iOrderItem: newOrderItemMap.get(iOrder.Id)){
                String productHierarchyIdString = productsMap.get(iOrderItem.Product2Id).ProductHierarchy__c;
                if(freightsMap.containsKey(iOrderItem.Product2Id+'-'+cityIdString)){
                    iOrderItem.FreightValue__c = freightsMap.get(iOrderItem.Product2Id+'-'+cityIdString).Value__c;
                }
                else if(freightsMap.containsKey(iOrderItem.Product2Id+'-'+stateIdString)){
                    iOrderItem.FreightValue__c = freightsMap.get(iOrderItem.Product2Id+'-'+stateIdString).Value__c;
                }
                else if(freightsMap.containsKey(iOrderItem.Product2Id+'-'+countryIdString)){
                    iOrderItem.FreightValue__c = freightsMap.get(iOrderItem.Product2Id+'-'+countryIdString).Value__c;
                }
                else if(freightsMap.containsKey(productHierarchyIdString+'-'+cityIdString)){
                    iOrderItem.FreightValue__c = freightsMap.get(productHierarchyIdString+'-'+cityIdString).Value__c;
                }
                else if(freightsMap.containsKey(productHierarchyIdString+'-'+stateIdString)){
                    iOrderItem.FreightValue__c = freightsMap.get(productHierarchyIdString+'-'+stateIdString).Value__c;
                }
                else if(freightsMap.containsKey(productHierarchyIdString+'-'+countryIdString)){
                    iOrderItem.FreightValue__c = freightsMap.get(productHierarchyIdString+'-'+countryIdString).Value__c;
                }
            }
        }
    }

    public static void searchForTheTax(Map<Id, List<OrderItem>> newOrderItemMap, Set<Id> productsIds, Set<Id> statesIds, 
    Map<Id, Order> ordersMap, Map<Id, AccountAddress__c> accountAddressMap,Map<Id, City__c> citiesMap){
        
        List<Tax__c> taxesInDatabase = [
            SELECT Id, Name, Product__c, State__c, Status__c, TaxOnCost__c
            FROM Tax__c
            WHERE Product__c IN :productsIds
            AND State__c IN :statesIds
            AND Status__c = 'Aprovado'
        ];

        Map<String, List<OrderItem>> orderItemMapToSearchTax = new Map<String, List<OrderItem>>();
        for(Order iOrder: ordersMap.values()){
            Id state = citiesMap.get(accountAddressMap.get(iOrder.AccountAddress__c).City__c).State__c;
            for(OrderItem iOrderItem: newOrderItemMap.get(iOrder.Id)){
                String orderItemKey = iOrderItem.Product2Id+'-'+state;
                if(orderItemMapToSearchTax.containsKey(orderItemKey)){
                    orderItemMapToSearchTax.get(orderItemKey).add(iOrderItem);
                }else{
                    orderItemMapToSearchTax.put(orderItemKey, new List<OrderItem>{iOrderItem});
                }
            }
        }
        for(Tax__c iTax: taxesInDatabase){
            String taxKey = iTax.Product__c+'-'+iTax.State__c;
            if(orderItemMapToSearchTax.containsKey(taxKey)){
                for(OrderItem iOrderItem: orderItemMapToSearchTax.get(taxKey)){
                    iOrderItem.TaxPercentage__c = iTax.TaxOnCost__c;
                }
            }
        }
    }
    
    public static void verifyRequiredParametersInOrderItem(List<OrderItem> newRecordList){
        for(OrderItem iOrderItem: newRecordList){
            Decimal test = iOrderItem.Quantity;
            if(iOrderItem.Quantity <= 0){
                iOrderItem.addError('Adicione uma quantidade maior que 0');
            }
            if(iOrderItem.MarginPercentage__c == null){
                iOrderItem.addError('Não está autorizada a venda deste produto devido a falta de porcentagem de margem, entre em contato o time de pricing.');
            }
            if(iOrderItem.TaxPercentage__c == null){
                iOrderItem.addError('Não está autorizada a venda deste produto devido a falta de porcentagem de imposto, entre em contato o time de pricing.');
            }
            if(iOrderItem.FreightValue__c == null){
                iOrderItem.addError('Não está autorizada a venda deste produto devido a falta de valor de frete, entre em contato o time de pricing.');
            }
            if(iOrderItem.ListPrice == null){
                iOrderItem.addError('Não está autorizada a venda deste produto devido a falta de custo de produção (ListPrice), entre em contato o time de pricing.');
            }
        }
    }

    public static void joinDuplicates(List<OrderItem> newRecordList){

        Map<String, OrderItem> newOrderItemMap = new Map<String, OrderItem>();
        for(OrderItem iOrderItem: newRecordList){
            String orderItemKey = iOrderItem.OrderId+'-'+iOrderItem.Product2Id+'-'+iOrderItem.UnitPrice;
            if(newOrderItemMap.containsKey(orderItemKey)){
                iOrderItem.addError('Dois produtos iguais no mesmo pedido, adicione este novamente ou atualize a quantidade do produto no pedido!');
            }else{
                newOrderItemMap.put(orderItemKey, iOrderItem);
            }
        }

        Set<Id> ordersIds = new Set<Id>();
        Set<Id> productsIds = new Set<Id>();
        Set<Decimal> unitPrices = new Set<Decimal>();
        for(OrderItem iOrderItem: newRecordList){
            ordersIds.add(iOrderItem.OrderId);
            productsIds.add(iOrderItem.Product2Id);
            unitPrices.add(iOrderItem.UnitPrice);
        }

        Map<Id, OrderItem> orderItemsInDatabase = new  Map<Id, OrderItem>([
            SELECT Id, OrderId, Product2Id, UnitPrice, Quantity
            FROM OrderItem
            WHERE OrderId IN :ordersIds
            AND Product2Id IN :productsIds
            AND UnitPrice IN :unitPrices
        ]);
        
        List<OrderItem> listToDelete = new List<OrderItem>();
        for(OrderItem iOrderItem: orderItemsInDatabase.values()){
            String orderItemKey = iOrderItem.OrderId+'-'+iOrderItem.Product2Id+'-'+iOrderItem.UnitPrice;
            if(newOrderItemMap.containsKey(orderItemKey)){
                if(newOrderItemMap.get(orderItemKey).Id != iOrderItem.Id){
                    if(!newOrderItemMap.get(orderItemKey).hasErrors()){
                        listToDelete.add(iOrderItem);
                        newOrderItemMap.get(orderItemKey).Quantity += iOrderItem.Quantity;
                    }
                }
            }
        }

        delete listToDelete;
    }

    public static void calculateFinalPrice(List<OrderItem> newRecordList){
        for(OrderItem iOrderItem: newRecordList){
            iOrderItem.FinalPrice__c =(iOrderItem.UnitPrice + iOrderItem.FreightValue__c) * (1+  (iOrderItem.MarginPercentage__c/100)) * (1+ (iOrderItem.TaxPercentage__c/100));
        }
    }

    public static void calculateFinalTotalPrice(List<OrderItem> newRecordList){
        for(OrderItem iOrderItem: newRecordList){
            iOrderItem.FinalTotalPrice__c = iOrderItem.FinalPrice__c * iOrderItem.Quantity;
        }
    }

    public static void isERPItem(List<OrderItem> newRecordList){
        for(OrderItem iOrderItem: newRecordList){
            if(iOrderItem.TotvsItem__c == true){
                if(UserInfo.getUserName() != 'razoppienzo@brave-shark-nskhtp.com'){
                    iOrderItem.addError('Objeto criado em ERP só pode ser modificado pelo ERP!');
                }
            }
        }
    }
}


