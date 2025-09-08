public with sharing class MarginTriggerHelper {
    public static void handleInsertMargin(List<Margin__c> newRecordList){
        verifyDuplicates(newRecordList);
    }

    public static void handleUpdateMargin(List<Margin__c> newRecordList){
        verifyDuplicates(newRecordList);
    }

    public static void verifyDuplicates(List<Margin__c> newRecordList){
        Map<String, Margin__c> mapMargin = new Map<String, Margin__c>();
        for(Margin__c iMargin: newRecordList){
            String marginKey = getMarginKey(iMargin);
            if(mapMargin.containsKey(marginKey)){
                iMargin.addError('Já existe uma margem com esses dados');
            }else{
                mapMargin.put(marginKey, iMargin);
            }
        }

        Set<Id> productsIds = new Set<Id>();
        Set<Id> productsHierarchyIds = new Set<Id>();
        Set<Id> accountsIds = new Set<Id>();
        Set<Id> accountsGrupsIds = new Set<Id>();
        Set<Id> citiesIds = new Set<Id>();
        Set<Id> statesIds = new Set<Id>();
        Set<Id> countriesIds = new Set<Id>();
        for(Margin__c iMargin: newRecordList){
            productsIds.add(iMargin.Product__c);
            productsHierarchyIds.add(iMargin.ProductHierarchy__c);
            accountsIds.add(iMargin.Account__c);
            accountsGrupsIds.add(iMargin.AccountGroup__c);
            citiesIds.add(iMargin.City__c);
            statesIds.add(iMargin.State__c);
            countriesIds.add(iMargin.Country__c);
        }

        List<Margin__c> marginsInDatabase = [
            SELECT Id, Product__c, ProductHierarchy__c, Account__c, AccountGroup__c, City__c, State__c, Country__c
            FROM Margin__c 
            WHERE Product__c IN :productsIds
            OR ProductHierarchy__c IN :productsHierarchyIds
            OR Account__c IN :accountsIds
            OR AccountGroup__c IN :accountsGrupsIds
            OR City__c IN :citiesIds
            OR State__c IN :statesIds
            OR Country__c IN :countriesIds
        ];

        for(Margin__c iMargin: marginsInDatabase){
            String marginKey = getMarginKey(iMargin);
            if(mapMargin.containsKey(marginKey)){
                if(iMargin.Id != mapMargin.get(marginKey).Id){
                    mapMargin.get(marginKey).addError('Já existe uma margem com esses dados');
                }
            }
        }
    }
    public static void MarginRequiredFields(List<Margin__c> newRecordList){
        for(Margin__c iMargin: newRecordList){
            if(iMargin.AccountGroup__c == null && iMargin.Account__c == null){
                iMargin.addError('Adicione um Grupo de Conta ou uma Conta!');
            }
            if(iMargin.AccountGroup__c != null && iMargin.Account__c != null){
                iMargin.addError('Os campos Grupo de Conta e Conta não podem ser especificados ao mesmo tempo. Por favor, remova um deles.');
            }
            if(iMargin.Product__c == null && iMargin.ProductHierarchy__c == null){
                iMargin.addError('Adicione um Produto ou uma Hierarquia de Produto!');
            }
            if(iMargin.Product__c != null && iMargin.ProductHierarchy__c != null){
                iMargin.addError('Os campos Produto e Hierarquia de Produto não podem ser especificados ao mesmo tempo. Por favor, remova um deles.');
            }
            if(iMargin.City__c == null && iMargin.State__c == null && iMargin.Country__c == null){
                iMargin.addError('Os campos Cidade, Estado e País não podem ser nulos ao mesmo tempo!');
            }
            if(iMargin.City__c != null && iMargin.State__c != null && iMargin.Country__c != null){
                iMargin.addError('Os campos Cidade, Estado e País não podem ser todos especificados ao mesmo tempo. Por favor, remova dois deles.');
            }
            if(iMargin.City__c != null && iMargin.State__c != null && iMargin.Country__c == null){
                iMargin.addError('Somente um campo entre Cidade, Estado e País pode ser especificado. Por favor, remova pelo menos um deles.');
            }
            if(iMargin.City__c != null && iMargin.State__c == null && iMargin.Country__c != null){
                iMargin.addError('Somente um campo entre Cidade, Estado e País pode ser especificado. Por favor, remova pelo menos um deles.');
            }
            if(iMargin.City__c == null && iMargin.State__c != null && iMargin.Country__c != null){
                iMargin.addError('Somente um campo entre Cidade, Estado e País pode ser especificado. Por favor, remova pelo menos um deles.');
            }
        }
    }
    public static String getMarginKey(Margin__c margin){
        if(margin.Product__c != null){
            if(margin.Account__c != null){
                if(margin.City__c != null){
                    return margin.Product__c+'-'+margin.Account__c+'-'+margin.City__c;
                }
                if(margin.State__c != null){
                    return margin.Product__c+'-'+margin.Account__c+'-'+margin.State__c;
                }
                if(margin.Country__c != null){
                    return margin.Product__c+'-'+margin.Account__c+'-'+margin.Country__c;
                }
            }
            if(margin.AccountGroup__c != null){
                if(margin.City__c != null){
                    return margin.Product__c+'-'+margin.AccountGroup__c+'-'+margin.City__c;
                }
                if(margin.State__c != null){
                    return margin.Product__c+'-'+margin.AccountGroup__c+'-'+margin.State__c;
                }
                if(margin.Country__c != null){
                    return margin.Product__c+'-'+margin.AccountGroup__c+'-'+margin.Country__c;
                }
            }
        }
        if(margin.ProductHierarchy__c != null){
            if(margin.Account__c != null){
                if(margin.City__c != null){
                    return margin.ProductHierarchy__c+'-'+margin.Account__c+'-'+margin.City__c;
                }
                if(margin.State__c != null){
                    return margin.ProductHierarchy__c+'-'+margin.Account__c+'-'+margin.State__c;
                }
                if(margin.Country__c != null){
                    return margin.ProductHierarchy__c+'-'+margin.Account__c+'-'+margin.Country__c;
                }
            }
            if(margin.AccountGroup__c != null){
                if(margin.City__c != null){
                    return margin.ProductHierarchy__c+'-'+margin.AccountGroup__c+'-'+margin.City__c;
                }
                if(margin.State__c != null){
                    return margin.ProductHierarchy__c+'-'+margin.AccountGroup__c+'-'+margin.State__c;
                }
                if(margin.Country__c != null){
                    return margin.ProductHierarchy__c+'-'+margin.AccountGroup__c+'-'+margin.Country__c;
                }
            }
        }
        return null;
    }
}