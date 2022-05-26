/***
* @description Lightning controller to provide various configuration data to Lightning components.
* @author      P-E GROS
* @date        Nov. 2019
*
* Legal Notice
* This code is the property of Salesforce.com and is protected by U.S. and International
* copyright laws. Reproduction, distribution without written permission of Salesforce is
* strictly prohibited. In particular this code has been delivered by Salesforce.com for
* its Client’s internal purposes pursuant to specific terms and conditions, and cannot be
* re-used, reproduced or distributed for any other purposes.
***/

public with sharing class PEG_Configuration_CTL {

/***
* @description Simple method to fetch the list of fields allowed for the user included in
*              a configured field set.
* @param       fieldSet             Dev Name of the Field Set 
* @return      Map<String,Object>   Map containing 3 entries:
*                                   'label' with the label of the field set,
*                                   'fields' with the list of included field API names allowed for the user,
*                                   'labels' with the corresponding field labels
* @exception   none really specific.
***/
    @AuraEnabled(cacheable=true)
    public static Map<String,Object> getFieldSetDesc(final String name) {
        System.debug('getFieldSetDesc: START with field set name ' + name);

        if ((name == null) || (name.length() == 0)) {
            System.debug('getFieldSetDesc: END empty or null name');
            throw new AuraHandledException('Empty fieldset name');
        }  
                                           
        String[] fsParts = name.split('\\.');
        System.debug('getFieldSetDesc: fsParts extracted ' + fsParts);
        if (fsParts.size()<> 2) throw new AuraHandledException(
            'Bad field set name format for ' + name + '\n Should be "object.fsName".');

        String objName = fsParts[0];
        System.debug('getFieldSetDesc: objName extracted ' + objName);
        String fsName  = fsParts[1];
        System.debug('getFieldSetDesc: fsName extracted ' + fsName);

        Schema.SObjectType objDesc = Schema.getGlobalDescribe().get(objName);
        if (objDesc == null) throw new AuraHandledException(
            'Unknown Object Name for field set ' + name + ' !');
        System.debug('getFieldSetDesc: object descriptor found ');

        Schema.FieldSet fsDesc = objDesc.getDescribe().fieldSets.getMap().get(fsName);
        if (fsDesc == null) throw new AuraHandledException(
            'Unknown Field Set Name for field set ' + name + ' !');
        System.debug('getFieldSet: field set descriptor found ');

        Map<String,Object> descResult = new Map<String,Object>();
        descResult.put('label',fsDesc.getLabel());
        System.debug('getFieldSet: field set Label set ' + fsDesc.getLabel());

        List<String> fieldList = new List<String>();
        List<String> labelList = new List<String>();
        descResult.put('fields',fieldList);
        descResult.put('labels',labelList);
        for (Schema.FieldSetMember fieldIter : fsDesc.getFields()) {
            System.debug('getFieldSet: processing field ' + fieldIter);

            Schema.DescribeFieldResult fieldDesc = fieldIter.getSObjectField().getDescribe();
            System.debug('getFieldSet: fieldDesc fetched ' + fieldDesc);

            if (fieldDesc.isAccessible()) {
                System.debug('getFieldSet: adding field ' + fieldIter);
                fieldList.add(fieldIter.getFieldPath());
                labelList.add(fieldIter.getLabel());
            }
            else {
                System.debug('getFieldSet: field not acessible ' + fieldIter);
            }
        }
        System.debug('getFieldSet: fieldList prepared ' + fieldList);
        System.debug('getFieldSet: descResult finalised ' + descResult);

        System.debug('getFieldSet: END for fieldList with size ' + fieldList.size());
        return descResult;
    }

/***
* @description Simple method to fetch the list of fields allowed for the user included in
*              a list of configured field sets.
* @param       fieldSets            List of Field Set's Dev Names  
* @return      Map<String,Object>   Map of maps containing 3 entries for each fieldSet API name:
*                                   'label' with the label of the field set,
*                                   'fields' with the list of included field API names allowed for the user,
*                                   'labels' with the corresponding field labels
* @exception   none really specific.
***/
    
    @AuraEnabled(cacheable=true)
    public static Map<String,Object> getFieldSetDescs(final list<String> names) {
        if ((names == null) || (names.size() == 0)) {
            System.debug('getFieldSetDescs: START/END empty or null name list ' + names);
            throw new AuraHandledException('Empty fieldset name list');
        }  
        System.debug('getFieldSetDescs: START with name list size ' + names.size());
        
        Map<String,Object> nameDescs = new Map<String,Object>();
        for (String iterName : names) {
            System.debug('getFieldSetDescs: processing field set ' + iterName);
            nameDescs.put(iterName, PEG_Configuration_CTL.getFieldSetDesc(iterName));
        }

        System.debug('getFieldSetDescs: END with nameDescs ' + nameDescs);
        return nameDescs;
    }
    

/***
* @description Simple method to fetch the IDs of a list of Record Types
* @param       names            	List of record Type Names as "<object API name>.<Record Type Developer Name>" 
* @return      Map<String,Object>   Map of Object API names with a submap of record type IDs per Record Type name.
* @exception   none really specific.
***/
    
    @AuraEnabled(cacheable=true)
    public static Map<String,Object> getRecordTypeIDs(final list<String> names) {        
        if ((names == null) || (names.size() == 0)) {
            System.debug('getRecordTypeIDs: START/END empty or null name list ' + names);
            throw new AuraHandledException('Empty record type name list');
        }  
        System.debug('getRecordTypeIDs: START with name list size ' + names.size());
        
        Map<String,Object> rtIDmap = new Map<String,Object>();
        for (String iter : names) {
            System.debug(LoggingLevel.FINEST,'getRecordTypeIDs: processing ' + iter);
            String[] iterParts = iter.split('\\.');
            System.debug(LoggingLevel.FINEST,'getRecordTypeIDs: iterParts extracted ' + iterParts);
            if (iterParts.size() <> 2) throw new AuraHandledException('Record type ID fetch error: ' + iter + ' should be in objectApiName.rtDevName format');
            if (!rtIDmap.containsKey(iterParts[0])) {
                rtIDmap.put(iterParts[0],new Map<String,ID>());
            }
            try {
            	((Map<String,ID>)rtIDmap.get(iterParts[0]))
            		.put(iterParts[1],
                    	Schema.getGlobalDescribe().get(iterParts[0]).getDescribe()
                        	.getRecordTypeInfosByDeveloperName().get(iterParts[1]).getRecordTypeId()); // Modified by Abhisek Pati (Deloitte) to use developer name
            }
            catch (exception e) {
                System.debug('getRecordTypeIDs: exception thrown ' + e.getMessage());
                throw new AuraHandledException('Record type ID fetch error: ' + iter + ' should be in objectApiName.rtDevName format');
            }
        }
        System.debug(LoggingLevel.FINEST,'getRecordTypeIDs: rtIDmap init ' + rtIDmap);
        System.debug('getRecordTypeIDs: END with ID map size ' + rtIDmap.size());
        return rtIDmap;
    }
    
/***
* @description Simple method to fetch the IDs of a list of List Views
* @param       names            	List of list view Names as "<object API name>.<List View Name>" 
* @return      Map<String,ID>   	Map of Object API names with a submap of list view IDs per List View name.
* @exception   none really specific.
***/
    
    @AuraEnabled(cacheable=true)
    public static Map<String,Object> getListViewIDs(final list<String> names) {
        if ((names == null) || (names.size() == 0)) {
            System.debug('getListViewIDs: START/END empty or null name list ' + names);
            throw new AuraHandledException('Empty list view name list');
        }  
        System.debug('getListViewIDs: START with name list size ' + names.size());
        
        Map<String,List<String>> listViewMap = new Map<String,List<String>>();
        Set<String> listViewNames = new Set<String>();
        for (String iter : names) {
            System.debug(LoggingLevel.FINEST,'getListViewIDs: processing ' + iter);
            String[] iterParts = iter.split('\\.');
            System.debug(LoggingLevel.FINEST,'getListViewIDs: iterParts extracted ' + iterParts);
            if (iterParts.size() <> 2) throw new AuraHandledException('List View ID fetch error: ' + iter + ' should be in objectApiName.rtDevName format');
            if (listViewMap.containsKey(iterParts[0])) {
                listViewMap.get(iterParts[0]).add(iterParts[1]);
            }
            else {
                List<String> newList = new List<String>{iterParts[1]};
                listViewMap.put(iterParts[0],newList);
            } 
            listViewNames.add(iterParts[1]);
        }
        System.debug(LoggingLevel.FINEST,'getListViewIDs: listViewMap init' + listViewMap);
        System.debug(LoggingLevel.FINEST,'getListViewIDs: listViewNames init' + listViewNames);
        System.debug('getListViewIDs: listViewMap init with size ' + listViewMap.size());
        System.debug('getListViewIDs: listViewNames init with size ' + listViewNames.size());
                
        List<ListView> lvList = [SELECT SObjectType, DeveloperName FROM ListView
                                 WHERE SObjectType in :listViewMap.keySet()
                                 AND DeveloperName in :listViewNames ];
        System.debug(LoggingLevel.FINEST,'getListViewIDs: listViews fetched ' + lvList);
        System.debug('getListViewIDs: listViews fetched with size ' + lvList.size());
        
        if ((lvList == null) || (lvList.size() == 0)) throw new AuraHandledException(
            'No list views found for ' + names + '\nShould be "object.fsName".');
        Map<String,Object> lvIDMap = new Map<String,Object>();
        for (ListView iter : lvList) {
            if (listViewMap.get(iter.SObjectType).contains(iter.DeveloperName)) {
                if (!lvIDMap.containsKey(iter.SObjectType)) {
                	lvIDMap.put(iter.SObjectType,new Map<String,ID>());
            	}
            	((Map<String,ID>)lvIDMap.get(iter.SObjectType)).put(iter.DeveloperName,iter.Id);
            }
        }
        System.debug(LoggingLevel.FINEST,'getListViewIDs: lvMap prepared ' + lvIDMap);
        System.debug('getListViewIDs: END with ID Map size ' + lvIDMap.size());
        return lvIDMap;
    }
}