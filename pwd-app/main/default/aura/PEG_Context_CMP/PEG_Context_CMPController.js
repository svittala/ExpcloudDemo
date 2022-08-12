({
    getValue : function(component, event, helper) {
	    console.log('getValue START');
        console.log('getValue current value ',JSON.stringify(helper.CONTEXT));
        console.log('getValue END');
        return helper.CONTEXT;
	},
    setValue : function(component, event, helper) {
	    console.log('setValue START');
        
        let eventArgs = event.getParam('arguments');
        console.log('setValue eventArgs provided',JSON.stringify(eventArgs));
        if (eventArgs) {
            helper.CONTEXT = eventArgs.context;
            console.log('setValue helper context updated',JSON.stringify(helper.CONTEXT));
            
            let msgEvent = $A.get("e.ltng:sendMessage");
            msgEvent.setParams({
                "channel": "PEG_Context",
                "message": helper.CONTEXT
            });
            console.log('setValue firing sendMessage event',msgEvent);
            msgEvent.fire();
        }
        console.log('setValue END');
	},
    handleContextChange : function(component, event, helper) {
        console.log('handleContextChange: START');
        
        let evtParams = event.getParams();
        //console.log('handleContextChange: evtParams',JSON.stringify(evtParams));

        if ((evtParams) && (evtParams.channel == 'PEG_Context')) {
            console.log('handleContextChange context fetched',JSON.stringify(evtParams.message));
            
            var callback = component.getEvent("onValueUpdate");
            console.log('handleContextChange: valueUpdated fetched',callback);
            
            let evtSource = event.getSource();
            console.log('handleContextChange: evtSource',JSON.stringify(evtSource));
            console.log('handleContextChange: component',JSON.stringify(component));
            console.log('handleContextChange: same source?',evtSource == component);
            
            if (callback) {
               console.log('handleContextChange: calling callback');
               callback.fire();
            } 
        } else {
            console.log('handleContextChange message ignored');
        }
          
        console.log('handleContextChange END');
    }
})