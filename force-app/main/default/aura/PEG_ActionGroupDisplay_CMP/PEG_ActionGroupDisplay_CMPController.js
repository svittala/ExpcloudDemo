({
	parseActionList : function(component, event, helper) {
        console.log('parseActionList: START');
        
        let title = component.get("v.title");
        if ((title) && (title.includes('$Label.'))) {
            console.log('parseActionList: fetching title value for',title);
            title = $A.getReference(title) || title;
            console.log('parseActionList: title value fetched',title);
            component.set("v.title",title);
        }
        
        let actionListStr = component.get("v.actionListStr");
        console.log('parseActionList: actionListStr retrieved',actionListStr);
        
        let actionListJson = JSON.parse(actionListStr);
        component.set("v.actionListJson",actionListJson);
        console.log('parseActionList: tableActionList END',actionListJson);
	},
    handleAction : function(component, event, helper) {
        console.log('handleAction: START');
        
        let selectedAction = event.getParams();
        console.log('handleAction: selectedAction from event',JSON.stringify(selectedAction));
        
        component.find('mergeUtil').trigger(
            selectedAction.message.event,
            null,
            null);
                      
        //helper.triggerAction(component,selectedAction.message,null);
        
        console.log('handleAction: END');
        
        
    }
    
})