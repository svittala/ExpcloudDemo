({
	doInit : function(component, event, helper) {
        
        var activity = component.get("v.activity");
        
        if (activity.TaskSubtype == 'Task') {
            component.set("v.icon","standard:task");
            component.set("v.class","slds-timeline__media_task");
        } else if (activity.TaskSubtype == 'Email'){
            component.set("v.icon","standard:email");
            component.set("v.class","slds-timeline__media_email");
        } else if (activity.TaskSubtype == 'Call'){
            component.set("v.icon","standard:log_a_call");
            component.set("v.class","slds-timeline__media_call");
        } else {
            //Event : TaskSubtype is null !!!
            //console.log('doInit: task.TaskSubtype',task.TaskSubtype);
        }
        
        if ((activity.ActivityDate) && (activity.IsClosed == false)) {
            var todayDate = new Date();
            var todayDateStr = todayDate.toISOString().substring(0,10);         
            component.set("v.overdue",todayDateStr > activity.ActivityDate);
        } else {
            component.set("v.overdue",false);
        }
	},
    navigateToObject: function(component, event, helper) {
        console.log('navigateToObject: START');
        
        /*console.log('navigateToObject: event', event);
        console.log('navigateToObject: event src', event.srcElement);
        console.log('navigateToObject: event src title', event.srcElement.title);
        console.log('navigateToObject: event to', event.toElement);
        console.log('navigateToObject: event to title', event.toElement.title);*/
        //console.log('navigateToObject: event params', JSON.stringify(event.getParams()));
        
        //var objectId = event.getSource().get("v.title");
        let objectId = event.srcElement.title;
        console.log('navigateToObject: objectId', objectId);
        
        let navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
                 "recordId": objectId
        });
        console.log('navigateToObject: firing navigation');
        navEvt.fire();
    },
    handleMenuAction : function(component, event, helper) {
        console.log('handleMenuAction: START');
        
        let selectedAction = event.getParams();
        console.log('handleMenuAction: selectedAction',JSON.stringify(selectedAction));
        
        let activity = component.get("v.activity");
        console.log('handleMenuAction: activity fetched',activity);
        
        let menuCallback = component.getEvent("menuCallback");
        console.log('handleMenuAction: callback fetched',JSON.stringify(menuCallback));
            
        if (menuCallback) {
            console.log('handleMenuAction: calling callback');
            menuCallback.setParams({
                "channel": selectedAction.channel,
                "message": {"action": selectedAction.message,
                            "row": activity}
            });
            console.log('handleMenuAction: callback params set',JSON.stringify(menuCallback));
            menuCallback.fire();
        } else {
            console.log('handleMenuAction: no callback defined');
        }
        
        console.log('handleMenuAction: END');
    }
})