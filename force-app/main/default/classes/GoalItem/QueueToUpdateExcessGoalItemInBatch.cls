public with sharing class QueueToUpdateExcessGoalItemInBatch implements Queueable, Finalizer {
    
    List<GoalItem__c> goalItemsToUpdateList;

    public QueueToUpdateExcessGoalItemInBatch(List<GoalItem__c> goalItemsToUpdateList){
        this.goalItemsToUpdateList = goalItemsToUpdateList;
    }

    public void execute(QueueableContext context) {
    
        if(goalItemsToUpdateList.size() > 10000){

            List<GoalItem__c> goalItemsToUpdateNow = new List<GoalItem__c>();
            List<GoalItem__c> goalItemsToUpdateInQueue = new List<GoalItem__c>();

            for(Integer position = 0; position < goalItemsToUpdateList.size(); position++){
                if(position < 10000){
                    goalItemsToUpdateNow.add(goalItemsToUpdateList[position]);
                }else{
                    goalItemsToUpdateInQueue.add(goalItemsToUpdateList[position]);
                }
            }

            Database.update(goalItemsToUpdateNow);
            System.attachFinalizer(new QueueToUpdateExcessGoalItemInBatch(goalItemsToUpdateInQueue));
        }else{
            Database.update(goalItemsToUpdateList);
        }
    }   

    public void execute(FinalizerContext ctx){

        if(goalItemsToUpdateList.size() > 10000){

            List<GoalItem__c> goalItemsToUpdateNow = new List<GoalItem__c>();
            List<GoalItem__c> goalItemsToUpdateInQueue = new List<GoalItem__c>();

            for(Integer position = 0; position < goalItemsToUpdateList.size(); position++){
                if(position < 10000){
                    goalItemsToUpdateNow.add(goalItemsToUpdateList[position]);
                }else{
                    goalItemsToUpdateInQueue.add(goalItemsToUpdateList[position]);
                }
            }

            Database.update(goalItemsToUpdateNow);
            System.enqueueJob(new QueueToUpdateExcessGoalItemInBatch(goalItemsToUpdateInQueue));
        }else{
            Database.update(goalItemsToUpdateList);
        }
    }
}