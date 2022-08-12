({
	triggerAction : function(component,selectedAction) {
        console.log('triggerAction: START');
        let selectedActionStr = JSON.stringify(selectedAction);
        console.log('triggerAction: action stringified',selectedActionStr);
        
        let targetId = component.get("v.targetId");
        console.log('triggerAction: targetId fetched');
                    
        component.find('mergeUtil').trigger(
            selectedAction.event,
            {"Id":targetId},
            function(result,error) {
                  console.log('triggerAction result from merge');
                  if (result) {
                      console.log('triggerAction: result parsed',JSON.stringify(result));
                  } else {
                      console.error('triggerAction: triggering merge error notification',JSON.stringify(error));
                      component.find('notifUtil').showNotice({
                         "variant": "error",
                         "header": "Error in merge !",
                         "message": JSON.stringify(error)
                      });
                  }
              }
        );
        console.log('triggerAction: END');
    }
})