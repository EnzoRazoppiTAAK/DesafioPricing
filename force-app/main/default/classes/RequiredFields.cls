public with sharing class RequiredFields {
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
    public static void FreightsRequiredFields(List<Freight__c> newRecordList){
        for(Freight__c iFreight: newRecordList){
            if(iFreight.Product__c == null && iFreight.ProductHierarchy__c == null){
                iFreight.addError('Adicione um Produto ou uma Hierarquia de Produto!');
            }
            if(iFreight.Product__c != null && iFreight.ProductHierarchy__c != null){
                iFreight.addError('Os campos Produto e Hierarquia de Produto não podem ser especificados ao mesmo tempo. Por favor, remova um deles.');
            }
            if(iFreight.City__c == null && iFreight.State__c == null && iFreight.Country__c == null){
                iFreight.addError('Os campos Cidade, Estado e País não podem ser nulos ao mesmo tempo!');
            }
            if(iFreight.City__c != null && iFreight.State__c != null && iFreight.Country__c != null){
                iFreight.addError('Os campos Cidade, Estado e País não podem ser todos especificados ao mesmo tempo. Por favor, remova dois deles.');
            }
            if(iFreight.City__c != null && iFreight.State__c != null && iFreight.Country__c == null){
                iFreight.addError('Somente um campo entre Cidade, Estado e País pode ser especificado. Por favor, remova pelo menos um deles.');
            }
            if(iFreight.City__c != null && iFreight.State__c == null && iFreight.Country__c != null){
                iFreight.addError('Somente um campo entre Cidade, Estado e País pode ser especificado. Por favor, remova pelo menos um deles.');
            }
            if(iFreight.City__c == null && iFreight.State__c != null && iFreight.Country__c != null){
                iFreight.addError('Somente um campo entre Cidade, Estado e País pode ser especificado. Por favor, remova pelo menos um deles.');
            }
        }
    }
    public static void verifyRequiredParametersInOrderItem(List<OrderItem> newRecordList){
        for(OrderItem iOrderItem: newRecordList){
            if(iOrderItem.quantity <= 0){
                iOrderItem.addError('Adicione uma quantidade maior que 0');
            }
            if(iOrderItem.MarginPercentage__c == null || iOrderItem.TaxPercentage__c == null || iOrderItem.FreightValue__c == null || iOrderItem.ListPrice == null){
                iOrderItem.addError('Não está autorizada a venda deste produto devido a falta de parâmetros, entre em contato o time de pricing.');
            }
        }
    }
}