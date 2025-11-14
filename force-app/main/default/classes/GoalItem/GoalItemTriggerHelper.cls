public with sharing class GoalItemTriggerHelper {

    public static void handleBeforeInsertGoalItem(List<GoalItem__c> newRecordList){
        valuesNeverCanBeNull(newRecordList);
        initialValuesShouldBeZero(newRecordList);
        initialValuesShouldNotBeZero(newRecordList);
        cannotInsertCompletedGoalItem(newRecordList);
    }
    public static void handleBeforeUpdateGoalItem(List<GoalItem__c> newRecordList){
        valuesNeverCanBeNull(newRecordList);
    }

    public static void valuesNeverCanBeNull(List<GoalItem__c> newRecordList){

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

    public static void initialValuesShouldBeZero(List<GoalItem__c> newRecordList){

        for(GoalItem__c iGoalItem: newRecordList){

            if(iGoalItem.ProjectedValue__c != 0.0){
                iGoalItem.addError('O valor projetado inicial deve ser zero.');
            }
            if(iGoalItem.NegotiatedValue__c != 0.0){
                iGoalItem.addError('O valor negociado inicial deve ser zero.');
            }
            if(iGoalItem.RealizedValue__c != 0.0){
                iGoalItem.addError('O valor realizado inicial deve ser zero.');
            }
        }
    }

    public static void initialValuesShouldNotBeZero(List<GoalItem__c> newRecordList){

        for(GoalItem__c iGoalItem: newRecordList){

            if(iGoalItem.GoalValue__c == 0.0){
                iGoalItem.addError('O valor de meta inicial não pode ser zero.');
            }
            if(iGoalItem.CommissionPercentage__c == 0.0){
                iGoalItem.addError('A Porcentagem de comissão inicial não pode ser zero.');
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