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
        
        let showObject = component.get("v.showObject");
        if (showObject) {
            let fieldsStr = component.get("v.fieldsStr");
            console.log('doInit: fieldsStr retrieved',fieldsStr);
        
            let fieldsJSON = JSON.parse(fieldsStr);
            component.set("v.fieldsJSON",fieldsJSON);
            console.log('doInit: fieldsJSON initialized',fieldsJSON);
        } else {
            console.log('doInit: fieldsStr config ignored');
        }
        
        let showList = component.get("v.showList");
        if (showList) {
            let listStr = component.get("v.listStr");
            console.log('doInit: listStr retrieved',listStr);
        
            let listJSON = JSON.parse(listStr);
            component.set("v.listJSON",listJSON);
            console.log('doInit: listJSON initialized',listJSON);
        } else {
            console.log('doInit: listStr config ignored');
        }
        
        let tableActionStr = component.get("v.tableActionStr");
        console.log('initConfig: tableActionStr retrieved',tableActionStr);      
        if (tableActionStr) {
           let tableActionJson = JSON.parse(tableActionStr);
           component.set("v.tableActionJson",tableActionJson);
           console.log('initConfig: tableActionJson initialized',tableActionJson);
        } else {
           console.warn('initConfig: tableActionJson not initialized');
        } 
        
        let rowActionStr = component.get("v.rowActionStr");
        console.log('initConfig: rowActionStr retrieved',rowActionStr);       
        if (rowActionStr) {
           let rowActionJson = JSON.parse(rowActionStr);
           component.set("v.rowActionJson",rowActionJson);
           console.log('initConfig: rowActionJson initialized',rowActionJson);
        } else {
           console.warn('initConfig: rowActionJson not initialized');
        } 
        
        helper.performCallout(component,helper);
        
        console.log('doInit: END');
	},
    refreshData : function(component, event, helper) {
        console.log('refreshData: START');
        
        helper.performCallout(component,helper);
        
        console.log('refreshData: END');
    },
    sortList: function(component, event, helper) {
        console.log('sortList: START');
           
        let fieldName     = event.getParam('fieldName');
        let sortDirection = event.getParam('sortDirection');
        console.log('sortList: new sorting by ' + fieldName + ' ' + sortDirection);

        let tableComponent = event.getSource();
        console.log('sortList: current sort field',     tableComponent.get("v.sortedBy"));
        console.log('sortList: current sort direction', tableComponent.get("v.sortedDirection"));
        
        tableComponent.set("v.sortedBy", fieldName);
        tableComponent.set("v.sortedDirection", sortDirection);
        
        let results   = component.get("v.results");
        let isReverse = sortDirection !== 'asc';
        console.log('sortList: current list',results);

        let sortMethod = (component.find('jsonUtil')).getSort();
        results.sort(sortMethod(fieldName, isReverse));
        console.log('sortList: sorted list',results);        
        component.set("v.results", results);
           
        console.log('sortList: END');
    },
    handleTableAction: function(component, event, helper) {
        console.log('handleTableAction: START');
        
        let selectedAction = event.getParams();
        console.log('handleTableAction: selectedAction from event',JSON.stringify(selectedAction));
        
        let resultTable = component.find('resultTable');
        let selectedRows = '';
        if (resultTable) {
            // very important : remove "" chars added at start/end by 2nd stringify
            selectedRows = JSON.stringify(JSON.stringify(resultTable.getSelectedRows())).slice(1,-1);
            console.log('handleTableAction: selectedRows fetched',selectedRows);
        }
        
        let recordData = {};
        let fieldsJSON = component.get("v.fieldsJSON");
        if (fieldsJSON) {
	        console.log('handleTableAction: fieldsJSON fetched',fieldsJSON);
    	    fieldsJSON.forEach(function(fieldItem){
        	    console.log('handleTableAction: processing field',fieldItem);
            	recordData[fieldItem.fieldName] = fieldItem.value;
        	});
        	console.log('handleTableAction: recordData init',recordData);
        }
        
        component.find('mergeUtil').trigger(
            selectedAction.message.event,
            {"Record":recordData,
             "SelectedRows":selectedRows},
            null);
        
        console.log('handleTableAction: END');
    },
    handleRowAction: function(component, event, helper) {
        console.log('handleRowAction: START');
        
        let selectedAction = event.getParams();
        console.log('handleRowAction: selectedAction from event',JSON.stringify(selectedAction));
        
        let action = event.getParam('action');
        console.log('handleRowAction: action name', action.name);
        let rowActionJson = component.get("v.rowActionJson");
        console.log('handleRowAction: rowActionJson fetched', rowActionJson);
                
        if (rowActionJson) {
            selectedAction = rowActionJson.find(function(element){
                return element.label == action.name;
            });
            console.log('handleRowAction: selectedAction found', selectedAction);
        } else {
            console.error('handleRowAction: no rowActionJson fetched',action.name);
            component.find('notifUtil').showNotice({
                 "variant": "error",
                 "header": "Error in row action trigger !",
                 "message": "Row action not defined: " + action.name
            });
            return;
        }
            
        let row    = event.getParam('row');
        console.log('handleRowAction: row',row);
        
        component.find('mergeUtil').trigger(
            selectedAction.event,
            row,
            null);
       
        console.log('handleRowAction: END');
    },
    expandCollapse  : function(component, event, helper) {
        var isExpanded = component.get("v.isExpanded");
        component.set("v.isExpanded", !isExpanded);
    }
})