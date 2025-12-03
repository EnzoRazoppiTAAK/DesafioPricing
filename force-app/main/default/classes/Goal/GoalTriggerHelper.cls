public with sharing class GoalTriggerHelper {
  
    public static void handleBeforeInsertGoal(List<Goal__c> newRecordList){
        yearShouldBeCurrent(newRecordList);
        cannotHaveDuplicates(newRecordList);
        initialSalesValueShouldBeZero(newRecordList);
    }

    public static void handleBeforeUpdateGoal(List<Goal__c> newRecordList, Map<Id, Goal__c> oldRecordMap){
        cannotChangeTheSeller(newRecordList, oldRecordMap);
        salesValueNeverCanBeNull(newRecordList);
    }

    public static void cannotHaveDuplicates(List<Goal__c> newRecordList){

        Set<Id> sellerIds = new Set<Id>();
        Set<String> years = new Set<String>(); 
        Map<String , Goal__c> newGoalMap = new Map<String , Goal__c>();
        for(Goal__c iGoal: newRecordList){
            String goalKey = iGoal.Seller__c+'-'+iGoal.Year__c;
            if(newGoalMap.containsKey(goalKey)){
                iGoal.addError('Não pode ter duas metas com o mesmo vendedor e ano!');
            }else{
                newGoalMap.put(goalKey, iGoal);
            }
        }

        for(Goal__c iGoal: newGoalMap.values()){
            sellerIds.add(iGoal.Seller__c);
            years.add(iGoal.Year__c);
        }

        List<Goal__c> goalsInDatabse = [
            SELECT Id, Seller__c, Year__c 
            FROM Goal__c 
            WHERE Seller__c IN :sellerIds AND Year__c IN :years
        ];

        for(Goal__c iGoal: goalsInDatabse){
            String goalKey = iGoal.Seller__c+'-'+iGoal.Year__c;
            if(newGoalMap.containsKey(goalKey)){
                newGoalMap.get(goalKey).addError('Não pode ter duas metas com o mesmo vendedor e ano!');
            }
        }
    }

    public static void yearShouldBeCurrent(List<Goal__c> newRecordList){

        String year = String.ValueOf(Date.today().year());

        for(Goal__c iGoal: newRecordList){
            if(iGoal.Year__c != year){
                iGoal.addError('Apenas metas do ano atual podem ser criadas!');
            }
        }
    }

    public static void cannotChangeTheSeller(List<Goal__c> newRecordList, Map<Id, Goal__c> oldRecordMap){

        for(Goal__c iGoal: newRecordList){
            if(iGoal.Seller__c != oldRecordMap.get(iGoal.Id).Seller__c){
                iGoal.addError('O vendedor não pode ser trocado!');
            }
        }
    }

    public static void initialSalesValueShouldBeZero(List<Goal__c> newRecordList){
        for(Goal__c iGoal: newRecordList){
            if(iGoal.SalesValue__c != 0.0){
                iGoal.addError('O valor inicial de vendas deve ser zero!');
            }
        }
    }

    public static void salesValueNeverCanBeNull(List<Goal__c> newRecordList){
        for(Goal__c iGoal: newRecordList){
            if(iGoal.SalesValue__c == null){
                iGoal.addError('O valor de vendas nunca pode ser nulo!');
            }
        }
    }
}