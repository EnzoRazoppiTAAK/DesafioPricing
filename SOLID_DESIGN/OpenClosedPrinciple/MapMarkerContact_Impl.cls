public with sharing class MapMarkerContact_Impl implements DisplayWrapper_interface {
    
    public List<sObject> getRecords(){
        List<Contact> contacts= [SELECT Id, Name, Phone, Email, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry FROM Contact];
        return contacts;
    }

    public List<sObject> wrapRecordsForUI(List<sObject> sObjectsRecords){
        List<MapMarker> mapMakers = new List<MapMarker>();

        for(contact cont: (List<Contact>)sObjectsRecords){
            mapMakers.add(new MapMarker(cont));
        }

        return mapMakers;
        
    }
}