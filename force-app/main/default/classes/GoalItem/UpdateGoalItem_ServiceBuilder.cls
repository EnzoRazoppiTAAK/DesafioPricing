global with sharing class UpdateGoalItem_ServiceBuilder {

    private List<GoalItem__c> goalItemsToUpdateList = new List<GoalItem__c>();
    private String otherObjectToHelpUpdate;
    private Map<Id, List<SObject>> goalItemsToObjectsListMap = new Map<Id, List<SObject>>();
    private Map<Id, Id> productToHierarchyMap = new Map<Id, Id>();


    global static UpdateGoalItem_ServiceBuilder builder(){
        return new UpdateGoalItem_ServiceBuilder();
    }

    global UpdateGoalItem_ServiceBuilder setOtherObjectToHelpUpdate(String otherObjectToHelpUpdate){
        this.otherObjectToHelpUpdate = otherObjectToHelpUpdate;
        return this;
    }

    global UpdateGoalItem_ServiceBuilder setGoalItemsToUpdate(List<GoalItem__c> goalItemsToUpdateList){
        this.goalItemsToUpdateList = goalItemsToUpdateList;
        return this;
    }

    global UpdateGoalItem_ServiceBuilder setMapOfGoalItemsToObjectsList(Map<Id, List<SObject>> goalItemsToObjectsListMap){
        this.goalItemsToObjectsListMap = goalItemsToObjectsListMap;
        return this;
    }

    global UpdateGoalItem_ServiceBuilder setProductToHierarchyMap(List<sObject> objectThatHaveProductsList){

        Map<Id, Id> productToHierarchyMap = new Map<Id, Id>();
        Set<Id> productIds = new Set<Id>();

        for(sObject iObject: objectThatHaveProductsList){
            productIds.add(
                (Id) iObject.get('Product2Id')
            );
        }

        List<Product2> products = [
            SELECT Id, ProductHierarchy__c
            FROM Product2
            WHERE Id IN :productIds
        ];

        for(Product2 iProduct: products){
            productToHierarchyMap.put(iProduct.Id, iProduct.ProductHierarchy__c);
        }

        this.productToHierarchyMap = productToHierarchyMap;
        return this;
    }

    global UpdateGoalItem_Service build(){
        return new UpdateGoalItem_Service(goalItemsToUpdateList, otherObjectToHelpUpdate, goalItemsToObjectsListMap, productToHierarchyMap);
    }
    
}