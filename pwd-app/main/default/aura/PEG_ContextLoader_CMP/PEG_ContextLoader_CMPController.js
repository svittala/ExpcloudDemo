({
	doInit : function(component, event, helper) {
        console.log("doInit: START");
        helper.performInit(component,event,helper);
        console.log("doInit: END");
	}
})