({
	doInit : function(component, event, helper) {
        console.log('doInit: START');
        
        let title = component.get("v.title");
        if ((title) && (title.includes('$Label.'))) {
            console.log('initConfig: fetching title value for',title);
            title = $A.getReference(title) || title;
            console.log('initConfig: title value fetched',title);
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
        
        let queryListStr = component.get("v.queryListStr");
        console.log('doInit: queryListStr retrieved',queryListStr);      
        if (queryListStr) {
           let queryListJson = JSON.parse(queryListStr);
           console.log('doInit: queryListJson parsed',queryListJson);
           queryListJson.forEach(function(queryItem){
               console.log('doInit: initializing queryItem',queryItem);
               //queryItem.icon          = queryItem.icon          || "standard:question_feed";
               queryItem.sObjectName   = queryItem.name          || "Undefined!";
               queryItem.isCollapsible = queryItem.isCollapsible || false;
               //queryItem.color         = queryItem.color         || "slds-theme_warning";
               queryItem.columns       = queryItem.columns       || 1;
           });
           component.set("v.queryListJson",queryListJson);
           console.log('doInit: queryListJson initialized',queryListJson);
        } else {
           console.log('doInit: queryListJson not initialized');
        } 
        
        helper.fetchData(component,helper);
        
        console.log('doInit: END');
    },
    refreshList : function(component, event, helper) {
		console.log('refreshList: START');
        
        component.set("v.displayScope",'All');
        component.set("v.isStorable",false);
        helper.fetchData(component,helper);
        
        console.log('refreshList: END');
	},
    handleClick : function(component, event, helper) {
		console.log('handleClick: START');
        
    },
    changeDisplayScope : function(component, event, helper) {
		console.log('changeDisplayScope: START');
        
        let displayScope = event.getParam("value");
        component.set("v.displayScope",displayScope);
        console.log('changeDisplayScope: new scope set',displayScope);
        
        helper.filterResults(component,helper);
        
        console.log('changeDisplayScope: END')
    },
    changeSort : function(component, event, helper) {
		console.log('changeSort: START');

        let isAscending = ! component.get('v.isAscending');
        console.log('changeSort: new isAscending set',isAscending);
        
        let queryResults = component.get('v.queryResults');
        console.log('changeSort: queryResults fetched',queryResults);
        helper.sortResults(component,queryResults,isAscending);
        
        let queryResultsOrig = component.get('v.queryResultsOrig');
        console.log('changeSort: queryResultsOrig fetched',queryResultsOrig);
        if (queryResultsOrig) {
            queryResultsOrig = helper.sortResults(component,queryResultsOrig,isAscending);
            component.set('v.queryResultsOrig',queryResultsOrig);
        }
        
        component.set('v.isAscending',isAscending);
        component.set('v.queryResults',queryResults);
        
        console.log('changeSort: END');
    },
    handleTableAction: function(component, event, helper) {
        console.log('handleTableAction: START');
        
        let selectedAction = event.getParams();
        console.log('handleTableAction: selectedAction from event',JSON.stringify(selectedAction));
        
        helper.triggerAction(component,selectedAction.message,null);
        
        console.log('handleTableAction: END');
    }
})