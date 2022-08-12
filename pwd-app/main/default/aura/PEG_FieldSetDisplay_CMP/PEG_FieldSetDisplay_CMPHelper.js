({
/***
* @author P-E GROS
* @date   Feb. 2020
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
        
        let fieldSetName = component.get("v.fieldSetName");
        console.log('performInit: fieldSetName fetched', fieldSetName);
        
        if ((!fieldSetName) || (fieldSetName === 'N/A'))  {
            console.warn('performInit: no fieldSetName provided');
            component.set("v.isReady",true);
        }
        else {
	        let getAction = component.get("c.getFieldSetDesc");
    	    getAction.setParams({
        	    "name":  fieldSetName });
	        console.log('performInit: getAction params set ',JSON.stringify(getAction.getParams()));
        
    	    getAction.setCallback(this, function(response){
        	    console.log('performInit: getAction response received',response);
            
            	if (response.getState() == "SUCCESS"){
                    let data = response.getReturnValue();
                	console.log('performInit: getAction OK response received',JSON.stringify(data));
                    
                    component.set("v.title",data.label);
                	console.log('performInit: title set',data.label);
                    
                    let mode = component.get("v.mode");
                	console.log('performInit: mode fetched',mode);
                    
                    if (mode === 'dList') {
                		console.log('performInit: initializing dList');
                        let fieldList = [];
                        data.fields.forEach(function(item,itemNbr){
            				console.log("performInit: processing field",item);
            				console.log("performInit: processing nbr",itemNbr);

            				let tmpLabel = data.labels[itemNbr];
            				console.log("performInit: related label fetched",tmpLabel);
            
            				fieldList.push({
                				'label' : tmpLabel,
                				'name'  : item
            				});
        				});
                        console.log("performInit: fieldList init",JSON.stringify(fieldList));
                        component.set("v.fieldList",fieldList);
                    }
                    else {
                        console.log('performInit: initializing hList or vList');
                        component.set("v.fieldList",data.fields);
                    }     
                    component.set("v.isReady",true);
                } else {
            	    console.log('performInit: END --> KO getAction response received',response.getError());
				}
        	});
        	console.log('performInit: getAction ready',getAction);
               
        	$A.enqueueAction(getAction);
        	console.log('performInit: getAction sent'); 
        }
        
        console.log('performInit: END');
	}
})