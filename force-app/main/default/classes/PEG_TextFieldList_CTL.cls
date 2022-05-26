/***
* @description Lightning controller for the App Builder to provide the list of Text
*              fields available on the current Object type, for use in a configuration
*              attribute data source (to display a picklist).
*              It is assumed to be called in the context of a record page  (as it expects
*              to fetch the entityName from the page context).
* @author      P-E GROS
* @date        Oct. 2019
*
*
* Legal Notice
* This code is the property of Salesforce.com and is protected by U.S. and International
* copyright laws. Reproduction, distribution without written permission of Salesforce is
* strictly prohibited. In particular this code has been delivered by Salesforce.com for
* its Client’s internal purposes pursuant to specific terms and conditions, and cannot be
* re-used, reproduced or distributed for any other purposes.
***/

global with sharing class PEG_TextFieldList_CTL extends VisualEditor.DynamicPickList {
    

/***
* @description Context of the Lightningh page calling the picklist controller.
***/
    VisualEditor.DesignTimePageContext pageContext;

/***
* @description Constructor enabling to fetch the Lightning page context (and especially
*              the entityName of the record being displayed in the page).
* @param       VisualEditor.DesignTimePageContext   Current page context
* @exception   none really specific.
***/    

    global PEG_TextFieldList_CTL(VisualEditor.DesignTimePageContext pageContext) {
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
        System.debug(LoggingLevel.FINEST,'getDefaultValue START Text');
        return new VisualEditor.DataRow('----','N/A');
    }
    
/***
* @description Override of the method providing the set of picklist values.
*              Returns label / api names couples for all String fields
*              defined on entity. Includes a default ('---','N/A') value.
* @return      VisualEditor.DynamicPickListRows  List of picklist values for datasource.
* @exception   none really specific.
***/
    global override VisualEditor.DynamicPickListRows getValues() {
        System.debug(LoggingLevel.FINEST,'getValues START Text');

        VisualEditor.DynamicPickListRows picklistValues = new VisualEditor.DynamicPickListRows();
        picklistValues.addRow(new VisualEditor.DataRow('----','N/A'));
        System.debug(LoggingLevel.FINEST,'getValues picklistValues init ' + picklistValues);

        System.debug(LoggingLevel.FINEST,'getValues entity name fetched ' + pageContext.entityName);
        Schema.SObjectType entityDesc = Schema.getGlobalDescribe().get(pageContext.entityName);
        System.debug(LoggingLevel.FINEST,'getValues entityDesc fetched ' + entityDesc);
        Map<String,Schema.SObjectField> entityFields = entityDesc.getDescribe().fields.getMap();
        System.debug(LoggingLevel.FINEST,'getValues entityFields fetched ' + entityFields);

        for (String fieldName : entityFields.keySet()){
            System.debug(LoggingLevel.FINEST,'getValues: processing fieldName ' + fieldName);
            DescribeFieldResult fieldDesc = entityFields.get(fieldName).getDescribe();
            System.debug(LoggingLevel.FINEST,'getValues: field type '  + fieldDesc.getType());
            switch on (fieldDesc.getType()) {
                when String {
                    System.debug(LoggingLevel.FINE,'getValues: field is string ' + fieldName);
                    System.debug(LoggingLevel.FINEST,'getValues: field label ' + fieldDesc.getLabel());
                    System.debug(LoggingLevel.FINEST,'getValues: field local name ' + fieldDesc.getLocalName());
                    System.debug(LoggingLevel.FINEST,'getValues: field name ' + fieldDesc.getName());
                    picklistValues.addRow(new VisualEditor.DataRow(fieldDesc.getLabel(),fieldDesc.getName()));
                }
                when else {
                    System.debug(LoggingLevel.FINE,'getValues: field is not string ' + fieldName);
                }
            }
        }
        System.debug(LoggingLevel.FINEST,'getValues picklistValues completed ' + picklistValues);
        System.debug(LoggingLevel.FINEST,'getValues END');
        return picklistValues;
    }
}