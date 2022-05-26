/***
* @description Lightning controller for the App Builder to provide the list of field sets
*              available on the current Object type, for use in a configuration
*              attribute data source (to display a picklist).
*              It is assumed to be called in the context of a record page  (as it expects
*              to fetch the entityName from the page context).
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

global with sharing class PEG_FieldSetList_CTL extends VisualEditor.DynamicPickList {

/***
* @description Context of the Lightning page calling the picklist controller.
***/
    VisualEditor.DesignTimePageContext pageContext;

/***
* @description Constructor enabling to fetch the Lightning page context (and especially
*              the entityName of the record being displayed in the page).
* @param       VisualEditor.DesignTimePageContext   Current page context
* @exception   none really specific.
***/    

    global PEG_FieldSetList_CTL(VisualEditor.DesignTimePageContext pageContext) {
        System.debug(LoggingLevel.FINEST,'Constructor START with page context ' + pageContext);
        System.debug(LoggingLevel.FINEST,'Constructor entityName ' + pageContext.entityName);
        this.pageContext = pageContext;
    }


/***
* @description Override of the method providing the default value.
* @return      VisualEditor.DataRow   Always returns the default ('---','N/A') value.
* @exception   none really specific.
***/
    global override VisualEditor.DataRow getDefaultValue() {
        System.debug(LoggingLevel.FINEST,'getDefaultValue START Number');
        return new VisualEditor.DataRow('---','N/A');
    }
    
/***
* @description Override of the method providing the set of picklist values.
*              Returns label / names couples for all field sets 
*              defined on entity. Includes a default ('---','N/A') value.
* @return      VisualEditor.DynamicPickListRows  List of field set names for datasource.
* @exception   none really specific.
***/
    global override VisualEditor.DynamicPickListRows getValues() {
        System.debug(LoggingLevel.FINEST,'getValues START Number');

        VisualEditor.DynamicPickListRows picklistValues = new VisualEditor.DynamicPickListRows();
        picklistValues.addRow(new VisualEditor.DataRow('---','N/A'));
        System.debug(LoggingLevel.FINEST,'getValues picklistValues init ' + picklistValues);

        System.debug(LoggingLevel.FINEST,'getValues entity name fetched ' + pageContext.entityName);
        Schema.SObjectType entityDesc = Schema.getGlobalDescribe().get(pageContext.entityName);
        System.debug(LoggingLevel.FINEST,'getValues entityDesc fetched ' + entityDesc);
        Map<String,Schema.FieldSet> fieldSets = entityDesc.getDescribe().fieldSets.getMap();
        System.debug(LoggingLevel.FINEST,'getValues fieldSets fetched ' + fieldSets);

        for (String fsIter : fieldSets.keySet()){
            System.debug(LoggingLevel.FINEST,'getValues: processing fieldSet ' + fsIter);
            Schema.FieldSet fieldSetDesc = fieldSets.get(fsIter);
            //System.debug(LoggingLevel.FINEST,'getValues: field desc ' + fieldDesc);
            System.debug(LoggingLevel.FINEST,'getValues: fieldSet Label '  + fieldSetDesc.getLabel());
            picklistValues.addRow(new VisualEditor.DataRow(
                    fieldSetDesc.getLabel(),
                    pageContext.entityName + '.' + fsIter));
        }
        System.debug(LoggingLevel.FINEST,'getValues picklistValues completed ' + picklistValues);
        System.debug(LoggingLevel.FINEST,'getValues END');
        return picklistValues;
    }
}