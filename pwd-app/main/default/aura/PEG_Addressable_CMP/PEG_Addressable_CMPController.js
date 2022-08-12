({
	doInit : function(component, event, helper) {
        console.log('doInit: START');
        
        //component.set("v.body",null);
		helper.initComponent(component, event, helper);
        
        console.log('doInit: END');
	},
    doRefresh : function(component, event, helper) {
        console.log('doRefresh: START');
        
        var wkAPI = component.find("workspaceUtil");
        console.log('doRefresh: wkAPI',wkAPI);
        
        
        wkAPI.isConsoleNavigation().then(function(consoleMode) {
            console.log('doRefresh: console mode',consoleMode);
            if (! consoleMode) {
                helper.initComponent(component, event, helper);
            }
        }).catch(function(error) {
            console.error('doRefresh: error raised',JSON.stringify(error));
        });
        //component.set("v.body",null);
		//helper.initComponent(component, event, helper);
        
        console.log('doRefresh: END');
	}
})