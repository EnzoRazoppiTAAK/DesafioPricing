public with sharing class UiWrapperService {

    public Map<String, Type> objectTypeToWrapper = new Map<String, Type>{
        'ContactMapMarker' => MapMarkerContact_Impl.class,
        'LeadMapMarker' => MapMarkerLead_Impl.class
    };

    public static List<sObject> getRecords(String objectType, String uiType){
        DisplayWrapper_interface displayWrapper = (DisplayWrapper_interface) objectTypeToWrapper.get(objectType+uiType).newInstance();
        return displayWrapper.getRecords(); 
    }
    public static List<Object> wrapRecordsForUI(List<sObject> sObjectRecords, String uiType){
        DisplayWrapper_interface displayWrapper = (DisplayWrapper_interface) objectTypeToWrapper.get(sObjectRecords[0].getSObjectType()+''+uiType).newInstance();
        return displayWrapper.wrapRecordsForUI(sObjectRecords); 
    }
    
}