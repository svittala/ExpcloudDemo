({
	initConfig : function(component, event, helper) {
        console.log('initConfig: START');
        
        let title = component.get("v.title");
        if ((title) && (title.includes('$Label.'))) {
            console.log('initConfig: fetching title value for',title);
            title = $A.getReference(title) || title;
            console.log('initConfig: title value fetched',title);
            component.set("v.title",title);
        }
        
        let tableActionStr = component.get("v.tableActionStr");
        console.log('initConfig: tableActionStr retrieved',tableActionStr);      
        if (tableActionStr) {
           let tableActionJson = JSON.parse(tableActionStr);
           component.set("v.tableActionJson",tableActionJson);
           console.log('initConfig: tableActionJson initialized',tableActionJson);
        } else {
           console.log('initConfig: tableActionJson not initialized');
        }
        
        let soqlListStr = component.get("v.soqlListStr");
        console.log('initConfig: soqlListStr retrieved',soqlListStr);      
        if (soqlListStr) {
           let soqlListJson = JSON.parse(soqlListStr);
           soqlListJson.forEach(function(item){
              item.fields = JSON.stringify(item.fields);
               if (item.tableActions) {
                 item.tableActions = JSON.stringify(item.tableActions);
               } else {
                 item.tableActions = "[]";
               }
           });
           component.set("v.soqlListJson",soqlListJson);
           console.log('initConfig: soqlListJson initialized',soqlListJson);
            
           let context = component.find("contextMgr").getValue();
           console.log('initConfig: context fetched',JSON.stringify(context));
           let selection = context.selection;
           console.log('initConfig: selection initialized',selection);
           
           let selectedQuery = soqlListJson[0];
           if(selection) {
               selectedQuery = soqlListJson.find(function(element) {
                  return element.name == selection;
               }) || soqlListJson[0];
           }
           component.set("v.selectedQuery",selectedQuery);
           console.log('initConfig: selectedQuery initialized',selectedQuery);
        } else {
           console.warn('initConfig: soqlListJson not initialized');
        } 
        
        console.log('initConfig: END');
	},
    handleChange : function(component, event, helper) {
        console.log('handleChange: START');
   
        let queryNbr = event.getSource().get("v.value");
        console.log('handleChange: queryNbr',queryNbr);
        
        component.set('v.selectedQuery',null);
        
        let selectedQuery = (component.get('v.soqlListJson'))[queryNbr];
        component.set('v.selectedQuery',selectedQuery);
        console.log('handleChange: selectedQuery',JSON.stringify(selectedQuery));
        
        console.log('handleChange: END');
    },
    handleResize : function(component, event, helper) {
        console.log('handleResize: START');

        let containingDiv = component.find("containingDiv");
        console.log('handleResize: containingDiv',containingDiv.offsetWidth );
        
        console.log('handleResize: END');        
    },
    expandCollapse : function(component, event, helper) {
        console.log('expandCollapse: START');
    
        let isExpanded = !component.get("v.isExpanded");
        console.log("expandCollapse: newState",isExpanded);
        component.set("v.isExpanded", isExpanded);
        
        console.log('expandCollapse: END');
    },
    handleTableAction : function (component, event, helper) {
        console.log('handleTableAction: START');
        
        let selectedAction = event.getParams();
        console.log('handleTableAction: selectedAction from event',JSON.stringify(selectedAction));
        
        component.find('mergeUtil').trigger(
            selectedAction.message.event,
            null,
            null);
        
        console.log('handleTableAction: END');
    }
})