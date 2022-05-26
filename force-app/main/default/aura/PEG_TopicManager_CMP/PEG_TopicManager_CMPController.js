({
	handleInit : function(component, event, helper) {
        console.log('handleInit: START');
        //component.set("v.isReady",false);
        helper.doInit(component,event,helper);
        console.log('handleInit: END');	
	},
    refreshLists : function(component, event, helper) {
		console.log('refreshLists: START');
        component.set("v.networkList",null);
        component.set("v.assignmentList",null);
        component.set("v.soqlError",null)
        component.set("v.isReady",false);
        helper.doInit(component,event,helper);
        console.log('refreshLists: END');
	},
    handleSelectNetwork : function(component, event, helper) {
		console.log('handleSelectNetwork: START');
        helper.loadNetworkTopics(component,event,helper);
        console.log('handleSelectNetwork: END');
	},
    handleAddTopic : function(component, event, helper) {
		console.log('handleAddTopic: START');
        helper.addTopic(component,event,helper);
        console.log('handleAddTopic: END');
	},
    handleRemoveTopic : function(component, event, helper) {
		console.log('handleRemoveTopic: START');
        helper.removeTopic(component,event,helper);
        console.log('handleRemoveTopic: END');
	}
})