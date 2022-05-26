({
/***
* @author P-E GROS
* @date   Nov. 2019
*
* Legal Notice
* This code is the property of Salesforce.com and is protected by U.S. and International
* copyright laws. Reproduction, distribution without written permission of Salesforce is
* strictly prohibited. In particular this code has been delivered by Salesforce.com for
* its Client’s internal purposes pursuant to specific terms and conditions, and cannot be
* re-used, reproduced or distributed for any other purposes.
***/
	performInit : function(component, event, helper) {
        console.log('performInit: START');
        
        // Initialising the field List for background and avatar
        let fieldList = [];
        
        let backgroundField = component.get("v.backgroundField");
        console.log('performInit: backgroundField fetched',backgroundField);
        if ((backgroundField) && (backgroundField !== 'N/A'))  {
            //let fieldName = (backgroundField.split('.',1))[1];
            console.log('performInit: fieldName added',backgroundField);
            fieldList.push(backgroundField);
        }
        
        let avatarField = component.get("v.avatarField");
        console.log('performInit: avatarField fetched',avatarField);
        if ((avatarField) && (avatarField !== 'N/A'))  {
            //let fieldName = (avatarField.split('.',1))[1];
            console.log('performInit: fieldName added',avatarField);
            fieldList.push(avatarField);
        }
        
        component.set ("v.fieldList",fieldList);
        console.log('performInit: fieldList initialized',fieldList);
        
        //let sObjectName = component.get("v.sObjectName");
        //console.log('performInit: sObjectName fetched',sObjectName);

        // Processing Header
        let headerFieldsSet = component.get("v.headerFieldsSet");
        console.log('performInit: headerFieldsSet fetched',headerFieldsSet);
        
        if ((!headerFieldsSet) || (headerFieldsSet === 'N/A'))  {
            console.warn('performInit: no headerFieldsSet provided');
            //component.set("v.headerOK",true);
        }
        else {
	        let headerAction = component.get("c.getFieldSetDesc");
    	    headerAction.setParams({
        	    "name":  headerFieldsSet });
	        console.log('performInit: headerAction params set ',JSON.stringify(headerAction.getParams()));
        
    	    headerAction.setCallback(this, function(response){
        	    console.log('performInit: headerAction response received',response);
            
            	if (response.getState() == "SUCCESS"){
                	console.log('performInit: headerAction OK response received',response.getReturnValue());
	                helper.finaliseInit((response.getReturnValue())["fields"],component,helper);
    	            component.set("v.headerOK",true);
                    component.set("v.headerFields",(response.getReturnValue())["fields"]);
        	    } else {
            	    console.log('performInit: END --> KO headerAction response received',response.getError());
				}
        	});
        	console.log('performInit: headerAction set',headerAction);
               
        	$A.enqueueAction(headerAction);
        	console.log('performInit: headerAction sent'); 
        }
        
        console.log('performInit: END');
	},
    finaliseInit : function(fieldSet, component, helper) {
        console.log('finaliseInit: START'); 

        let fieldList = component.get("v.fieldList");
        console.log('finaliseInit: fieldList fetched',fieldList);
        
        fieldList = fieldList.concat(fieldSet);
        console.log('finaliseInit: fieldList appended',fieldList);
        
        component.set("v.fieldList",fieldList);
        
        console.log('finaliseInit: END'); 
    },
    performUpdate : function(component, event, helper) {
		console.log('performUpdate: START');
        
        //let recordFields = component.get("v.recordFields");
        //console.log('performUpdate: recordFields fetched',JSON.stringify(recordFields)); 

        let recordObject = component.get("v.recordObject");
        console.log('performUpdate: recordObject fetched',JSON.stringify(recordObject)); 
		let displayObject = {};
        
        // Initialising the field values for Background and Avatar
        let backgroundField = component.get("v.backgroundField");
        displayObject.background = helper.getValue(recordObject.fields,backgroundField)
        						|| component.get("v.background");
        console.log('performUpdate: background set',JSON.stringify(displayObject.background)); 

        let avatarField = component.get("v.avatarField");
        displayObject.avatar = helper.getValue(recordObject.fields,avatarField)
        						|| component.get("v.avatar");
        console.log('performUpdate: background set',JSON.stringify(displayObject)); 

        // Initialising the field values for Header
        let headerFields = component.get("v.headerFields");
        if (headerFields) {
        	//let tmpField = headerFields.shift();
        	displayObject.title = helper.getValue(recordObject.fields,headerFields[0]);
        	//tmpField = headerFields.shift();
        	displayObject.badge = helper.getValue(recordObject.fields,headerFields[1]);
        	console.log('performUpdate: title and badge set',JSON.stringify(displayObject)); 

        	displayObject.header = [];
        	for (let iter = 2; iter < headerFields.length; iter++ ) {
        	    let itemVal = helper.getValue(recordObject.fields,headerFields[iter]);
       			if (itemVal) displayObject.header.push(itemVal);
        	}
        
        	console.log('performUpdate: header set',JSON.stringify(displayObject)); 
    	}
        else {
        	console.log('performUpdate: no header to set');
        }
        
        component.set("v.displayObject",displayObject);
        component.set("v.isReady",true);
        console.log('performUpdate: END');
	},
    getValue : function(recordFields,field) {
        console.log('getValue: START for field ',field);
        
    	if (recordFields[field]) {
        	console.log('getValue: END field found',recordFields[field]);
    		return recordFields[field].displayValue
                   || recordFields[field].value;
		}
 		else {
        	console.warn('getValue: END field not found',field);
			return null;
 		}
    }
})