({
	doInit : function(component, event, helper) {
        console.log('doInit: START');
		helper.performInit(component, helper);        
        console.log('doInit: END');
	},
    handleUpdates : function(component, event, helper) {
        console.log('handleUpdates: START');
        
        let eventParams = event.getParams();
        console.log("handleUpdates: event",JSON.stringify(eventParams));
        let changeType = eventParams.changeType;
        console.log("handleUpdates: changeType",changeType);
        let recordChanges = eventParams.changedFields;
        console.log("handleUpdates: recordChanges",JSON.stringify(recordChanges));     
        
        if (changeType == 'LOADED'){
            console.log("handleUpdates: fields loaded");
            helper.updateData(component,helper,null);         
        }
        else if (changeType == 'CHANGED' ) {
            console.log("handleUpdates: fields updated");
            
            let recordChanges = event.getParam("changedFields");
        	console.log("handleUpdates: recordChanges fetched",JSON.stringify(recordChanges));
        
            helper.updateData(component,helper,recordChanges); 
        }
        else {
           console.log("handleUpdates: message ignored");     
        }
        
        console.log('handleUpdates: END');
	}
})