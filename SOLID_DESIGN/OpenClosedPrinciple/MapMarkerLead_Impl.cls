public with sharing class MapMarkerLead_Impl implements DisplayWrapper_interface {
    
    public List<sObject> getRecords(){
        List<Lead> leads= [SELECT Id, Name, Phone, Email, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry FROM Lead];
        return leads;
    }

    public List<sObject> wrapRecordsForUI(List<sObject> sObjectsRecords){
        List<MapMarker> mapMakers = new List<MapMarker>();

        for(contact cont: (List<Lead>)sObjectsRecords){
            mapMakers.add(new MapMarker(cont));
        }

        return mapMakers;
    }
}