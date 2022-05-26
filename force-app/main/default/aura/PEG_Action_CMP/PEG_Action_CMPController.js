({
	runAction : function(component, event, helper) {
        console.log('runAction: START');
        helper.performAction(component,event);
        console.log('runAction: END');
	}
})