public with sharing class OppCalculator_Controller {
    
    @AuraEnabled
    public static void calculateOpps(String userType){
        OppCalculator_Service.calculateOpps(userType);
    }
}