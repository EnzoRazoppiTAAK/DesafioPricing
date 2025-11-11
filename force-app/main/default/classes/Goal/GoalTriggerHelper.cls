public with sharing class GoalTriggerHelper {
  
    public static void handleBeforeInsertGoal(List<Goal__c> newRecordList){
        onlySystemAdministratorCanMakeDml();
        cannotHaveGoalsWithSameSellerAndYear(newRecordList);
    }

    public static void handleBeforeUpdateGoal(){
        onlySystemAdministratorCanMakeDml();
    }

    public static void handleBeforeDeleteGoal(){
        onlySystemAdministratorCanMakeDml();
    }

    public static void cannotHaveGoalsWithSameSellerAndYear(List<Goal__c> newRecordList){

        Set<Id> sellerIds = new Set<Id>();
        Set<Decimal> years = new Set<Decimal>(); 
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

    public static void onlySystemAdministratorCanMakeDml(){

        String profileId = UserInfo.getProfileId();
        Profile systemAdministratorProfile = [SELECT Id, Name FROM Profile WHERE Name = ':System Administrator' LIMIT 1];

        if(profileId != systemAdministratorProfile.Id){
            throw new NoAccessException('Somente o Administrador do sistema pode alterar as metas');
        }
    }
    
}