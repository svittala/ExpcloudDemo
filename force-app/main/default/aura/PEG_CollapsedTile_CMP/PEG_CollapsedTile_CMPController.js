({
	expandCollapse  : function(component, event, helper) {
        let isExpanded = component.get("v.isExpanded");
        component.set("v.isExpanded", !isExpanded);
    },
    editObject : function(component, event, helper) {
        let recordId = component.get("v.recordId");
        let eventTriggered = event.getParam("value");

        if ((typeof eventTriggered) === 'undefined') {
            eventTriggered = event.getSource().get("v.value");
        }
        console.log('editObject eventTriggered',eventTriggered);
        
        var recordEvent = $A.get(eventTriggered);
        recordEvent.setParams({
          "recordId": recordId
        });
        recordEvent.fire();
    }
})