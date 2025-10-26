public with sharing class OppCalculator_Service {

    private static Map<String, Type> userTypeToCalculator = new Map<String, Type>{
        'CTO' => OppCalculatorService_CTO.class,
        'Manager' => OppCalculatorService_Managers.class,
        'Sales Associate' => OppCalculatorService_SalesAssoc.class
    };

    public static void calculateOpps(String userType){
        OppCalculator_Interface oppCalculator = (OppCalculator_Interface) userTypeToCalculator.get(userType).newInstance();
        oppCalculator.calculateOpps();
    }
}