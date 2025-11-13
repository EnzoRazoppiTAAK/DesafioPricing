public with sharing class GoalItemTriggerHelper {

    public static void handleBeforeInsertGoalItem(List<GoalItem__c> newRecordList){
        thatValuesNeverCanBeNull(newRecordList);
        cannotInsertCompletedGoalItem(newRecordList);
    }
    public static void handleBeforeUpdateGoalItem(List<GoalItem__c> newRecordList){
        thatValuesNeverCanBeNull(newRecordList);
    }

    public static void thatValuesNeverCanBeNull(List<GoalItem__c> newRecordList){

        for(GoalItem__c iGoalItem: newRecordList){

            if(iGoalItem.ProjectedValue__c == null){
                iGoalItem.addError('O valor projetado não pode ser nulo.');
            }
            if(iGoalItem.NegotiatedValue__c == null){
                iGoalItem.addError('O valor negociado não pode ser nulo.');
            }
            if(iGoalItem.RealizedValue__c == null){
                iGoalItem.addError('O valor realizado não pode ser nulo.');
            }
            if(iGoalItem.GoalValue__c == null){
                iGoalItem.addError('O valor de meta não pode ser nulo.');
            }
            if(iGoalItem.CommissionPercentage__c == null){
                iGoalItem.addError('A Porcentagem de comissão não pode ser nulo.');
            }
        }
    }

    public static void cannotInsertCompletedGoalItem(List<GoalItem__c> newRecordList){

        for(GoalItem__c iGoalItem: newRecordList){

            if(iGoalItem.Completed__c == true){
                iGoalItem.addError('Proíbido criar um item de meta já concluído!');
            }
        }
    }
}