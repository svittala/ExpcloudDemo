({
	doInit : function(component, event, helper) {
        console.log('doInit: START');
        helper.performInit(component, event, helper);
        console.log('doInit: END');
	},
    updateData : function(component, event, helper) {
		console.log('updateData: START');
        helper.performUpdate(component, event, helper);
        console.log('updateData: END');
	}
})