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
    
    performInit: function(component, event, helper) {
        console.log('performInit: START');
        
        let actionResult = {
            display: true,
            title: "Component Initialisation",
            message: "Fetching configuration...",
            variant: "info"
        };
        component.set("v.actionResult",actionResult);
        console.log('performInit: actionResult init',actionResult);
        
        let trackedFieldset = component.get("v.trackedFieldset");
        console.log('performInit: trackedFieldset fetched',trackedFieldset);

        let initAction = component.get("c.getFieldSetDesc");
    	initAction.setParams({"name":  trackedFieldset });
	    console.log('performInit: initAction params set ',JSON.stringify(initAction.getParams()));
        
    	initAction.setCallback(this, function(response){
            console.log('performInit: initAction response received',response);
            
            if (response.getState() == "SUCCESS"){
                console.log('performInit: initAction OK response received',response.getReturnValue());
                component.set("v.title",((response.getReturnValue())["label"]));
	            component.set("v.trackedFields",((response.getReturnValue())["fields"]));
        	} else {
            	console.log('performInit: END --> KO initAction response received',response.getError());
                let actionResult = {
                    display: true,
                    title: "Fieldset fetch issue!",
                    error: response.getError(),
                    variant: "error"
                };
        		component.set("v.actionResult",actionResult);
            }
        });
        console.log('performInit: initAction set',initAction);
               
       	$A.enqueueAction(initAction);
        console.log('performInit: initAction sent'); 
	},
    processChanges : function(component, event, helper) {
        console.log('processChanges: START');
        
        let eventParams = event.getParams();
        console.log("processChanges: event received",JSON.stringify(eventParams));
        let changeType = eventParams.changeType;
        console.log("processChanges: changeType extracted",changeType);
        let recordChanges = eventParams.changedFields;
        console.log("processChanges: recordChanges extracted",JSON.stringify(recordChanges));     
        let trackedFields = component.get("v.trackedFields");
        console.log("processChanges: trackedFields fetched",JSON.stringify(trackedFields));     
        let recordFields = component.get("v.recordFields");
        console.log("processChanges: recordFields fetched",JSON.stringify(recordFields));
        
        if (changeType == 'LOADED'){
            console.log("processChanges: fields loaded");
            let actionResult = {
                display: true,
                title: "Fields loaded!",
                message: "Triggering action...",
                variant: "info"
            };
        	component.set("v.actionResult",actionResult);
            
            helper.callAction(component, recordFields, null);
            //helper.updateScore(component,recordChanges);         
        }
        else if (changeType == 'CHANGED' ) {
            console.log("processChanges: fields updated");
            
            let isTracked = false;
            for (let change in recordChanges){
                recordFields[change] = recordChanges[change].value;
            	if (trackedFields.includes(change)) {
                    isTracked = true;
	                console.log("processChanges: tracked field change for ",change);
                }
                else {
                	console.log("processChanges: ignoring field change",change);
            	}
        	}
            console.log("processChanges: recordFields updated with changes ",JSON.stringify(recordFields));

            if (isTracked) {
                console.log("processChanges: tracked change logic triggered");
                
                helper.callAction(component, recordFields, recordChanges);
                console.log("processChanges: END tracked change");
            }
            else {
                console.log("processChanges: END change ignored");
                /*
                let actionResult = {
    	            display: true,
                    title: "Change detected!",
        	        message: "Ignoring this change.",
            	    variant: "info"
            	};
        		component.set("v.actionResult",actionResult);
                */
            }
            //helper.updateScore(component,recordChanges); 
        }
        else {
            console.log("processChanges: END message ignored"); 
        }
    },
    callAction : function(component, recordFields, recordChanges) {
        console.log('callAction: START');
        
        let actionResult = {
            display: true,
        	title: "Change detected!",
        	message: "Calling Handling Action!",
            variant: "info"
        };
        component.set("v.actionResult",actionResult);
        console.log("callAction: actionResult updated at start");
                 
        let selectedAction = component.get("v.actionName");
        console.log('callAction: selected Action ',selectedAction);
                
        let target = {
            record: recordFields,
            changes: recordChanges
        }
        console.log('callAction: target init ',JSON.stringify(target));
        
        // action trigger
        component.find('actionUtil').runAction(
            selectedAction,
            target,
            function(result) {
                // process OK (in result object)
              	console.log('callAction: action success received',result);
                                    
                //let resultJson = JSON.parse(result);
                let resultJson = result;
              	console.log('callAction: resultJson parsed',JSON.stringify(resultJson));

                console.log('callAction: recordFields fetched',JSON.stringify(recordFields));
                for (let field in resultJson) {
                    recordFields[field] = resultJson[field];
                }
                console.log('callAction: recordFields updated',JSON.stringify(recordFields));
                component.set("v.recordFields",recordFields);
                
                component.find('ldsUtil').saveRecord($A.getCallback(function(saveStatus) {
                    console.log("callAction: change save status received ",JSON.stringify(saveStatus));
                    
                    if (saveStatus.state === "ERROR") {
                    	console.log("callAction: Save error ",JSON.stringify(saveStatus.error));
                        let actionResult2 = {
            				"display": true,
        	        		"title": "Field change handling KO!",
                    		"message" : "HELP",
                    		"error": {message : JSON.stringify(saveStatus.error)},
            	    		"variant": "error"
              			};
        	 			component.set("v.actionResult",actionResult2);
                		console.log('callAction: END KO', JSON.stringify(actionResult2));
                    }
                    else {
                        console.log("callAction: Save success");
                    	let actionResult2 = {
            				display: true,
        	        		title: "Change detected!",
        					message: "Saving changes.",
            	    		variant: "success"
              			};
        	 			component.set("v.actionResult",actionResult2);
                		console.log('callAction: END OK', JSON.stringify(actionResult2));
                    }
                }));
                console.log('callAction: saveRecord triggered');
            },
            function(error) {
                // process KO (in error object)
              	console.error('performAction: action error received', JSON.stringify(error));
    
                if (error[0].exceptionType == "PEG_ActionHandler_SVC.PEG_ActionOptionException"){
                    // Handle Error with options                 
                  	console.warn('performAction: PEG_ActionOptionException error received');
                  	error = JSON.parse(error[0].message);
                  	console.warn('performAction: action error updated', JSON.stringify(error));
                    
                    let actionResult = {
            			"display": true,
        	        	"title": "Field change handling KO!",
                    	"error": error,
                    	"optionsList":error.options,
                    	"message": "",
            	    	"variant": "warning"
              	  	};
        	 		component.set("v.actionResult",actionResult);
                    console.warn('performAction: END KO with options',JSON.stringify(actionResult));
              }
              	else {
                	// Handle other Error cases                 
                	console.warn('performAction: error.exceptionType error received',error[0].exceptionType);

                	let actionResult = {
            			"display": true,
        	        	"title": "Field change handling KO!",
                    	"error": error,
                    	"optionsList":null,
                    	"message": "",
            	    	"variant": "error"
              	  	};
        	 		component.set("v.actionResult",actionResult);
              		console.error('callAction: END KO',JSON.stringify(actionResult));
                }
            },
            'String'
        );
        console.log('callAction: action called');
    },
    processOption : function(component, helper) {
    	console.log('processOption: START');
        
        let selection = component.find('OptionsSelector').get('v.value');
        console.log('processOption: selection fetched', selection);
        let actionResult = component.get("v.actionResult");
        console.log('processOption: actionResult fetched', JSON.stringify(actionResult));
        
        if ((selection) && (actionResult)) {
            let optionsList = actionResult.optionsList;
            console.log('processOption: optionsList extracted', JSON.stringify(optionsList));
            let selectedOption = optionsList[selection];
            console.log('processOption: selectedOption determined', JSON.stringify(selectedOption));
            
            let recordFields = component.get("v.recordFields");
            console.log('processOption: recordFields fetched',JSON.stringify(recordFields));
            for (let iter in selectedOption) {
                if (iter !== 'label') recordFields[iter] = selectedOption[iter]; 
            }
            console.log('callAction: recordFields updated',JSON.stringify(recordFields));
            component.set("v.recordFields",recordFields);
            
            component.find('ldsUtil').saveRecord(function(saveStatus) {
                    console.log("processOption: change save status received ",JSON.stringify(saveStatus));
                    console.log("processOption: component fetched ",component);
                    
                    if (saveStatus.state === "ERROR") {
                    	console.log("processOption: Save error ",JSON.stringify(saveStatus.error));
                        let actionResult2 = {
            				"display": true,
        	        		"title": "Field change handling KO!",
                    		"message" : "HELP",
                    		"error": {message : JSON.stringify(saveStatus.error)},
            	    		"variant": "error"
              			};
        	 			component.set("v.actionResult",actionResult2);
                		console.error('processOption: END KO', JSON.stringify(actionResult2));
                    }
                    else {
                        console.log("processOption: Save success");
                    	let actionResult2 = {
            				display: true,
        	        		title: "Change detected!",
        					message: "Saving changes.",
            	    		variant: "success"
              			};
        	 			component.set("v.actionResult",actionResult2);
                		console.log('processOption: END OK', JSON.stringify(actionResult2));
                    }
            });
            console.log('processOption: saveRecord triggered'); 
        }
        else {
            console.log('processOption: END no selection');       
        }
	}
})