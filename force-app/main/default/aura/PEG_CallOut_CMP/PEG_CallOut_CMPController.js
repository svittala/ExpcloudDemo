({
	runCallOut : function(component, event, helper) {
        console.log('runCallOut: START');
        helper.doCallOut(component,event);
        console.log('runCallOut: END');
	}
})