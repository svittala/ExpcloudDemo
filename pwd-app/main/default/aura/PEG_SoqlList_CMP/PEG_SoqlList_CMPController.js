({
    initConfig : function(component, event, helper) {
        console.log('initConfig: START');
        
        var title = component.get("v.title");
        if ((title) && (title.includes('$Label.'))) {
            console.log('initConfig: fetching title value for',title);
            title = $A.getReference(title) || title;
            console.log('initConfig: title value fetched',title);
            component.set("v.title",title);
        }
        
        let fieldStr = component.get("v.fields");
        console.log('initConfig: fields retrieved',fieldStr);      
        if (fieldStr) {
           let fieldJson = JSON.parse(fieldStr);
           component.set("v.fieldJson",fieldJson);
           console.log('initConfig: fieldJson initialized',fieldJson);
        } else {
           console.warn('initConfig: fieldJson not initialized');
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
    
        let isInfiniteLoad = component.get("v.isInfiniteLoad");
        console.log('initConfig: isInfiniteLoad fetched',isInfiniteLoad);
        if (isInfiniteLoad) {
            component.set("v.isOngoingLoad",true);
            console.log('initConfig: initializing infinite load');
        }
        
        console.log('initConfig: triggering initial load');
        component.set("v.resultsOrig",null);
        component.set("v.searchString","");
        helper.fetchResults(component);
        
        console.log('initConfig: END');
    },
    refreshList : function(component, event, helper) {
		console.log('refreshList: START');

        let isInfiniteLoad = component.get("v.isInfiniteLoad");
        console.log('refreshList: isInfiniteLoad fetched',isInfiniteLoad);
        if (isInfiniteLoad) {
            component.set("v.isOngoingLoad",true);
            console.log('refreshList: resetting infinite load');
        }
        
        console.log('initConfig: triggering reload');
        component.set("v.results",null);
        component.set("v.resultsOrig",null);
        component.set("v.searchString","");
        helper.fetchResults(component);
        
        console.log('refreshList: END');
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
        
        component.find('mergeUtil').trigger(
            selectedAction.message.event,
            {"SelectedRows":selectedRows},
            null);
                      
        //helper.triggerAction(component,selectedAction.message,null);
        
        console.log('handleTableAction: END');
    },
    handleRowAction: function(component, event, helper) {
        console.log('handleRowAction: START');
        
        let selectedAction = event.getParams();
        console.log('handleRowAction: selectedAction from event',JSON.stringify(selectedAction));
        
        let action = event.getParam('action');
        console.log('handleRowAction: action name', action.name);
        
        if (! action.name) {
            console.warn('handleRowAction: no action name defined --> action ignored !');
            return;
        }
        
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
                 "header": "Error in row action trigger for '" + component.get("v.title") + "'!",
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
        
        //helper.triggerAction(component,selectedAction,row);
       
        console.log('handleRowAction: END');
    },
    expandCollapse  : function(component, event, helper) {
        var isExpanded = component.get("v.isExpanded");
        component.set("v.isExpanded", !isExpanded);
    },
    filterList : function(component, event, helper) {
		console.log('filterList: START');

        //console.log('filterList: event', JSON.stringify(event.getParams()));
        
        let isEnterKey = event.keyCode === 13;
        //console.log('filterList: keyCode',event.keyCode);
        if (isEnterKey) {
          //console.log('filterList search string fetched',component.get('v.searchString'));
          helper.filterResults(component);
        }
        console.log('filterList: END');
	},
    changeScope : function(component, event, helper) {
		console.log('changeScope: START');
        
        let searchScope = event.getParam("value");
        component.set("v.searchScope",searchScope);
        console.log('changeScope: new scope set',searchScope);
        
        let searchString = component.get("v.searchString");
        console.log('changeScope: searchString fetched',searchString);
        if (searchString) {
            console.log('changeScope: refreshing search');
            helper.filterResults(component);
        }
        
        console.log('changeScope: END')
    },
    resetSearch : function(component, event, helper) {
		console.log('resetSearch: START', JSON.stringify(event.getParams()));
        if (! event.getParam('value')) {
            console.log('resetSearch: removing search filter');
            helper.filterResults(component);
        }
        console.log('resetSearch: END');
    },
    loadMoreData : function(component, event, helper) {
		console.log('loadMoreData: START');
        
        let searchString = component.get("v.searchString");
        console.log('loadMoreData: searchString fetched',searchString);
        if (searchString) {
            console.log('loadMoreData: blocking infinite load when search ongoing');
        } else {
            console.log('loadMoreData: triggering next page load');
            component.set("v.resultsOrig",null);
            component.set("v.searchString","");
            helper.fetchResults(component);  
        }
        
        console.log('loadMoreData: END');
    }
})