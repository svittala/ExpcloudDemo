({
	doInit : function(component, event, helper) {
        console.log('doInit: START');
        helper.setConfiguration(component,helper);
        helper.setTitle(component,helper);
        helper.setMessage(component,helper);
        console.log('doInit: START');
    },
    updateConfiguration : function(component, event, helper) {
        console.log('updateConfiguration: START');
        helper.setConfiguration(component,helper);
        console.log('updateConfiguration: END'); 
    },
    updateTitle : function(component, event, helper) {
        console.log('updateTitle: START');
        helper.setTitle(component,helper);
        console.log('updateTitle: END'); 
    },
    updateMessage : function(component, event, helper) {
        console.log('updateMessage: START');
        helper.setMessage(component,helper);
        console.log('updateMessage: END'); 
    }
})