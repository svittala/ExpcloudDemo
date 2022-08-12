({
	actionInit : function(component, event, helper) {
        //console.log('actionInit START');
        
        let actionList = component.get("v.actionList");
        //console.log('actionInit: actionList fetched', actionList);
        let maxActionIndex = actionList.length - 1;
        console.log('actionInit: maxActionIndex determined', maxActionIndex)
        
        actionList.forEach(function(actionItem,actionIndex) {
            console.log('actionInit: processing action item',actionItem);
            console.log('actionInit: processing actionIndex',actionIndex);
            if (! actionItem.variant){
               actionItem.variant = 'neutral';
            }
            if (! actionItem.type){
               actionItem.type = 'button';
            }
            if (actionIndex == maxActionIndex) {
                if ((maxActionIndex == 0) ) {
                   actionItem.isLast = false;   
                    //&& (actionItem.type === 'button')
                } else {
                   actionItem.isLast = true;
                }
            } else {
                actionItem.isLast = false;
            }
        });
        console.log('actionInit actionList patched', actionList);
        component.set("v.actionList",actionList);
     
        //console.log('actionInit END');
    },
    requestAction : function(component, event, helper) {
        console.log('requestAction START');
        
        let selectedAction = event.getSource().get("v.value");
        let actionType = 'button';
        if ((typeof selectedAction) === 'undefined') {
            selectedAction = event.getParam("value");
            actionType = 'menu'
            console.log('requestAction: selectedAction from menu item',JSON.stringify(selectedAction));
        } else {
            console.log('requestAction: selectedAction from button',JSON.stringify(selectedAction));
        }
        
        var callback = component.getEvent("callback");
        console.log('requestAction: callback fetched',callback);
            
        if (callback) {
            console.log('requestAction: calling callback');
            callback.setParams({
                "channel": actionType,
                "message": selectedAction
            });
            console.log('requestAction: callback params set',callback);
            callback.fire();
        } else {
            console.log('requestAction: no callback defined');
        }
        console.log('requestAction: END');
    }
})