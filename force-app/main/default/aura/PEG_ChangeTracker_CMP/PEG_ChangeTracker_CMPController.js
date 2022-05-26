({
	doInit : function(component, event, helper) {
        console.log('doInit: START');
		helper.performInit(component, event, helper);        
        console.log('doInit: END');
	},
    handleUpdates : function(component, event, helper) {
        console.log('handleUpdates: START');
        helper.processChanges(component, event, helper);
        console.log('handleUpdates: END');
	},
    handleOptionSelect : function(component, event, helper) {
        console.log('handleOptionSelect START');
        helper.processOption(component,helper);
        console.log('handleOptionSelect END');
    }
})