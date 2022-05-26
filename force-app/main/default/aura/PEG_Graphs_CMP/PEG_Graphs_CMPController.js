({
	initData : function(component, event, helper) {
        console.log('initData START');
        
        let title = component.get("v.title");
        if ((title) && (title.includes('$Label.'))) {
            console.log('initData: fetching title value for',title);
            title = $A.getReference(title) || title;
            console.log('initData: title value fetched',title);
            component.set("v.title",title);
        }
        
        let cardActionStr = component.get("v.cardActionStr");
        console.log('initData: tableActionStr retrieved',cardActionStr);      
        if (cardActionStr) {
           let cardActionJson = JSON.parse(cardActionStr);
           component.set("v.cardActionJson",cardActionJson);
           console.log('initData: cardActionJson initialized',cardActionJson);
        } else {
           console.log('initData: cardActionJson not initialized');
        }
        
        let contextData = (component.find("contextMgr")).getValue();
        if (contextData) {
            let queryStr = component.get("v.query");
            if ((! queryStr.includes('{{{Context'))  || (contextData.agency)) {
               helper.loadData(component,helper);
            }
        } else {
            console.warn('initData : no context set yet',contextData);
        }
        console.log('initData END');
	},
    reloadData : function(component, event, helper) {
        console.log('reloadData START');
        
        helper.loadData(component,helper);
        
        console.log('reloadData END');
    },
    handleCardAction : function (component, event, helper) {
        console.log('handleCardAction: START');
        
        let selectedAction = event.getParams();
        console.log('handleCardAction: selectedAction from event',
                    JSON.stringify(selectedAction));
        
        component.find('mergeUtil').trigger(
            selectedAction.message.event,
            null,
            null);
        
        console.log('handleCardAction: END');
    }
})