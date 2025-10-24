public interface DisplayWrapper_interface {
    
    List<sObject> getRecords();
    List<Object> wrapRecordsForUI(List<sObject> dObjectRecords);
}