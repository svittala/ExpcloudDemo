({
	doInit : function(component, event, helper) {
        console.log('doInit: START');
        
        let title = component.get("v.title");
        if ((title) && (title.includes('$Label.'))) {
            console.log('doInit: fetching title value for',title);
            title = $A.getReference(title) || title;
            console.log('doInit: title value fetched',title);
            component.set("v.title",title);
        }
        
        let tableActionStr = component.get("v.tableActionStr");
        console.log('doInit: tableActionStr retrieved',tableActionStr);      
        if (tableActionStr) {
           let tableActionJson = JSON.parse(tableActionStr);
           component.set("v.tableActionJson",tableActionJson);
           console.log('doInit: tableActionJson initialized',tableActionJson);
        } else {
           console.log('doInit: tableActionJson not initialized');
        } 
        
        let rowActionStr = component.get("v.rowActionStr");
        console.log('doInit: rowActionStr retrieved',rowActionStr);
        if (rowActionStr) {
           let rowActionJson = JSON.parse(rowActionStr);
           component.set("v.rowActionJson",rowActionJson);
           console.log('doInit: rowActionJson initialized',rowActionJson);
        } else {
           console.log('doInit: rowActionJson not initialized');
        }  
        
        helper.fetchActivities(component,helper);
        
        console.log('doInit: END');
	},
    refreshList : function(component, event, helper) {
		console.log('refreshList: START');
        
        helper.fetchActivities(component,helper);
        
        console.log('refreshList: END');
	},
    handleTableAction: function(component, event, helper) {
        console.log('handleTableAction: START');
        
        let selectedAction = event.getParams();
        console.log('handleTableAction: selectedAction from event',JSON.stringify(selectedAction));
        
        helper.triggerAction(component,selectedAction.message,null);
        
        console.log('handleTableAction: END');
    },
    handleRowAction: function(component, event, helper) {
        console.log('handleRowAction: START');
        
        let selectedAction = event.getParams();
        console.log('handleRowAction: selectedAction from event',JSON.stringify(selectedAction));
        
        helper.triggerAction(component,
                             selectedAction.message.action,
                             selectedAction.message.row);
        
        console.log('handleRowAction: END');
    },
    expandCollapse  : function(component, event, helper) {
        var isExpanded = component.get("v.isExpanded");
        component.set("v.isExpanded", !isExpanded);
    }
})