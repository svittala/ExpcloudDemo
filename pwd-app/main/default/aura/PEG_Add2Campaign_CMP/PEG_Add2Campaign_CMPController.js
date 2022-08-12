({
	handleInit : function(component, event, helper) {
        console.log('handleInit: START');
        helper.doInit(component);
        console.log('handleInit: END');	
	},
    handleDBLoaded: function(component, event, helper) {
        console.log('handleDBLoaded: START');
        helper.finalizeInit(component,event,helper);
        console.log('handleDBLoaded: END');
    },
    add2Campaign: function(component, event, helper) {
        console.log('add2campaign: START');
        helper.doAdd2Campaign(component,event,helper);
        console.log('add2campaign: END');
    },
    confirmAction: function(component, event, helper) {
        console.log('confirmAction: START');
        helper.doAction(component,event,helper);
        console.log('confirmAction: END');
    },
    cancelAction: function(component, event, helper) {
        console.log('cancelAction: START');
        component.set("v.actionError",null);
        component.set("v.isRunning",false);
        console.log('cancelAction: END');
    }
})