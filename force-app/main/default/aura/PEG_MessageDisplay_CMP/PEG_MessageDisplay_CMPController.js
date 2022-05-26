({
    doInit : function(component, event, helper) {
        console.log('updateConfiguration: START');
        helper.setConfiguration(component,helper);
        helper.setErrorMessage(component,helper);
        console.log('updateConfiguration: START');
    },
    updateConfiguration : function(component, event, helper) {
        console.log('updateConfiguration: START');
        helper.setConfiguration(component,helper);
        console.log('updateConfiguration: END'); 
    },
    updateErrorMessage : function(component, event, helper) {
        console.log('updateErrorMessage: START');
        helper.setErrorMessage(component,helper);
        console.log('updateConfiguration: END'); 
    }
})