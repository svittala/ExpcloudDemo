({
	doInit : function(component, event, helper) {
        console.log('doInit: START');
        
        let title = component.get("v.title");
        if ((title) && (title.includes('$Label.'))) {
            console.log('doInit: fetching title value for',title);
            title = $A.getReference(title) || title;
            console.log('doInit: title value fetched',title);
            component.set("v.title",title);
        }
        
        var fieldStr = component.get("v.fieldStr");
        console.log('doInit fieldStr retrieved',fieldStr);
        
        if (fieldStr) {
          var fieldJson = JSON.parse(fieldStr);
          component.set("v.fieldJson",fieldJson);
          console.log('doInit fieldJson initialized',fieldJson);
        }
        
        let targetObjName = component.get("v.targetObjName");
        console.log('doInit targetObjName retrieved',targetObjName);
        if ((! targetObjName) || (targetObjName.length ==0)) {
            targetObjName = component.get("v.sObjectName");
            console.log('doInit targetObjName default init',targetObjName);
            component.set("v.targetObjName",targetObjName);
        }
        
        let objActionStr = component.get("v.objActionStr");
        console.log('doInit: objActionStr retrieved',objActionStr);
        if (objActionStr) {
           let objActionJson = JSON.parse(objActionStr);
           component.set("v.objActionJson",objActionJson);
           console.log('doInit: objActionJson initialized',objActionJson);
        } else {
           console.log('doInit: objActionJson not initialized');
        }
        
        let targetIdField = component.get("v.targetIdField");
        console.log('doInit: targetIdField fetched',targetIdField);
        component.find('mergeUtil').merge(
            targetIdField,
            null,
            function(mergeResult,mergeError) {
                console.log('doInit: result from merge');
                if (mergeResult) {
                   console.log('doInit: Id mergeResult received',mergeResult);
                   
                   component.set("v.targetId",mergeResult);
                } else {
                   console.error('doInit: triggering Id merge error notification',JSON.stringify(activityError));
                   component.find('notifUtil').showNotice({
                      "variant": "error",
                      "header" : "Error in ID field merging !",
                      "message": JSON.stringify(mergeError)
                   });
                }  
            }
        );          
        console.log('doInit: END');
    },
    handleObjAction: function(component, event, helper) {
        console.log('handleObjAction: START');
        
        let selectedAction = event.getParams();
        console.log('handleObjAction: selectedAction from event',
                    JSON.stringify(selectedAction));
        
        helper.triggerAction(component,selectedAction.message);
        
        console.log('handleObjAction: END');
    }
})