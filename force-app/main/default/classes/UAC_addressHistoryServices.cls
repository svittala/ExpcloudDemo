/**
*___________________________________________________
* @Name: UAC_addressHistoryServices
* @Author: Ankur Aggarwal
* @Created Date: May 06, 2020
* @Used_By: UAC PATH
*___________________________________________________
* @Description: Validate Address History records when received and when appropriate.
*___________________________________________________
* @Changes:
*
**/
public with sharing class UAC_addressHistoryServices {
    Static set<id> setErroradded = new set<id>();
    static final String strCannotDeleteVerified = System.Label.UAC_cannotDeleteVerified;
    static final String strCurrentAddressExist = System.Label.UAC_currentAddressExist;
    static final String strDateCannotOverlap = System.Label.UAC_dateCannotOverlap;
    /*  @author       Ankur Aggarwal
        @description  Validates the Current address field for insert
        @param        List<UAC_addressHistory__c> lstNewItems
        @return       void
    */ 
    public static void validateCurrentAddress(List<UAC_addressHistory__c> lstNewItems) {
        list<id> lstAdultContactIds = new list<id>();
        for(UAC_addressHistory__c newItem : lstNewItems){
            if(newItem.UAC_Current__c)
                lstAdultContactIds.add(newItem.UAC_adultContact__c);
        }
        map<id,contact> mapAdultContact= new map<id,contact>(
                            [select 
                                id, 
                                (select 
                                    id,
                                    UAC_Current__c
                                from 
                                    AddressHistories__r
                                where 
                                    UAC_Current__c = true)
                            from 
                                contact 
                            where
                                id in : lstAdultContactIds]
                        );
        for(UAC_addressHistory__c newItem : lstNewItems){
            contact objContactAdult  = mapAdultContact.get(newItem.UAC_adultContact__c);
            if(objContactAdult != null && objContactAdult.AddressHistories__r != null && objContactAdult.AddressHistories__r.size() > 0){
                setErroradded.add(newItem.id);
                newItem.addError(strCurrentAddressExist);
            }
        }
    }
    /*  @author       Ankur Aggarwal
        @description  Validates for overlapping dates for the given contact
        @param        List<UAC_addressHistory__c> lstNewItems
        @return       void
    */ 
    public static void validateOverlappingDates(List<UAC_addressHistory__c> lstNewItems) {
        list<id> lstAdultContactIds = new list<id>();
        for(UAC_addressHistory__c newItem : lstNewItems){
            lstAdultContactIds.add(newItem.UAC_adultContact__c);
        }
        map<id,contact> mapAdultContact= new map<id,contact>(
                            [select 
                                id, 
                                (select 
                                    id,
                                    UAC_dateFrom__c,
                                    UAC_dateTo__c,
                                    UAC_Current__c
                                from 
                                    AddressHistories__r Limit 10000)
                            from 
                                contact 
                            where
                                id in : lstAdultContactIds]
                        );
        for(UAC_addressHistory__c newItem : lstNewItems){
            contact objContactAdult  = mapAdultContact.get(newItem.UAC_adultContact__c);
            
			if( objContactAdult != null && !setErroradded.contains(newItem.id) && objContactAdult.AddressHistories__r != null){
				for(UAC_addressHistory__c oldItem : objContactAdult.AddressHistories__r){
					Date dateNewItemDateTo = newItem.UAC_Current__c ? Date.newInstance(10000,12,31) : newItem.UAC_dateTo__c;
					Date dateOldItemDateTo = oldItem.UAC_Current__c ? Date.newInstance(10000,12,31) : oldItem.UAC_dateTo__c;

					
					if(oldItem.id != newItem.id && ((newItem.UAC_dateFrom__c >= oldItem.UAC_dateFrom__c && newItem.UAC_dateFrom__c <= dateOldItemDateTo ) ||
					(dateNewItemDateTo >= oldItem.UAC_dateFrom__c && dateNewItemDateTo <= dateOldItemDateTo ) ||
					(newItem.UAC_dateFrom__c <= oldItem.UAC_dateFrom__c && dateNewItemDateTo >= dateOldItemDateTo))){

						newItem.addError(strDateCannotOverlap);
					}
					
				}
			}
            
        }                        
    }
    /*  @author       Ankur Aggarwal
        @description  Validates for only one Current address for the given contact (update)
        @param        Map<Id, UAC_addressHistory__c> mapNewItems, Map<Id, UAC_addressHistory__c> mapOldItems
        @return       void
    */ 
    public static void validateCurrentAddress(Map<Id, UAC_addressHistory__c> mapNewItems, Map<Id, UAC_addressHistory__c> mapOldItems) {

        List<UAC_addressHistory__c> lstNewItems = new List<UAC_addressHistory__c>();
        for(UAC_addressHistory__c newItem :mapNewItems.values()){
            UAC_addressHistory__c oldItem =  mapOldItems.get(newItem.id);
            if(newItem.UAC_Current__c != oldItem.UAC_Current__c  && newItem.UAC_Current__c){
                lstNewItems.add(newItem);
            }
        }
        validateCurrentAddress(lstNewItems);
    }
    /*  @author       Ankur Aggarwal
        @description  Validates for overlapping dates for the given contact (update)
        @param        Map<Id, UAC_addressHistory__c> mapNewItems, Map<Id, UAC_addressHistory__c> mapOldItems
        @return       void
    */ 
    public static void validateOverlappingDates(Map<Id, UAC_addressHistory__c> mapNewItems, Map<Id, UAC_addressHistory__c> mapOldItems) {
        List<UAC_addressHistory__c> lstNewItems = new List<UAC_addressHistory__c>();
        for(UAC_addressHistory__c newItem :mapNewItems.values()){
            UAC_addressHistory__c oldItem =  mapOldItems.get(newItem.id);
            if(newItem.UAC_dateTo__c != oldItem.UAC_dateTo__c || newItem.UAC_dateFrom__c != oldItem.UAC_dateFrom__c ){
                lstNewItems.add(newItem);
            }
        }
        validateOverlappingDates(lstNewItems);
    }
    /*  @author       Ankur Aggarwal
        @description  restrict deletion of Verified address
        @param        map<Id, UAC_addressHistory__c> mapOldItems
        @return       void
    */ 
    public static void handleVerifiedDelete(Map<Id, UAC_addressHistory__c> mapOldItems) {
        for(UAC_addressHistory__c oldItem :mapOldItems.values()){
            if(oldItem.UAC_googleEarthVerified__c || oldItem.UAC_googleMapsVerified__c ||  oldItem.UAC_smartyStreetsVerified__c ){
                oldItem.addError(strCannotDeleteVerified);
            }
        }
    }    
}