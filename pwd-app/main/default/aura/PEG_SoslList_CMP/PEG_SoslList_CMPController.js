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
        
        let displayStr = component.get('v.displayStr');
        console.log('fetchResults: displayStr fetched',displayStr);                       
        let displayJson = JSON.parse(displayStr);
        component.set('v.displayJson',displayJson);
        
        let tableActionStr = component.get("v.tableActionStr");
        console.log('doInit: tableActionStr retrieved',tableActionStr);      
        if (tableActionStr) {
           let tableActionJson = JSON.parse(tableActionStr);
           component.set("v.tableActionJson",tableActionJson);
           console.log('doInit: tableActionJson initialized',tableActionJson);
        } else {
           console.log('doInit: tableActionJson not initialized');
        }
        
        helper.fetchResults(component,helper);
        
        console.log('initConfig: END');
	},
    refreshList : function(component, event, helper) {
		console.log('refreshList: START');
        
        component.set("v.displayScope",'All');
        component.set("v.isStorable",false);
        helper.fetchResults(component,helper);
        
        console.log('refreshList: END');
	},
    triggerAction : function(component, event, helper) {
        console.log('triggerAction: START');
        let eventTriggered = event.getParam("value");
        
        if ((typeof eventTriggered) === 'undefined') {
            eventTriggered = event.getSource().get("v.value");
        }
        console.log('triggerAction eventTriggered',eventTriggered);
        
        let params = eventTriggered.split("/");
        console.log('triggerAction: params split',params);
        var recordEvent = $A.get(params[0]);
        recordEvent.setParams({
          "recordId": params[1]
        });
        recordEvent.fire();
        console.log('triggerAction: END');
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
          helper.fetchResults(component,helper);
        }
        console.log('filterList: END');
	},
    resetSearch : function(component, event, helper) {
		console.log('resetSearch: START', JSON.stringify(event.getParams()));
        if (! event.getParam('value')) {
            console.log('resetSearch: removing search filter');
            component.set("v.displayScope",'All');
            helper.fetchResults(component,helper);
        }
        console.log('resetSearch: END');
    },
    changeSort : function(component, event, helper) {
		console.log('changeSort: START');

        let isAscending = ! component.get('v.isAscending');
        console.log('changeSort: new isAscending set',isAscending);
        
        
        let results = component.get('v.results');
        console.log('changeSort: results fetched',results);
        results = helper.sortResults(component,results,isAscending);
        
        let resultsOrig = component.get('v.resultsOrig');
        console.log('changeSort: resultsOrig fetched',resultsOrig);
        if (resultsOrig) {
            resultsOrig = helper.sortResults(component,resultsOrig,isAscending);
            component.set('v.resultsOrig',resultsOrig);
        } 

        component.set('v.results',results);
        component.set('v.isAscending',isAscending);
        
        console.log('changeSort: END');
    },
    changeDisplayScope : function(component, event, helper) {
		console.log('changeDisplayScope: START');
        
        let displayScope = event.getParam("value");
        component.set("v.displayScope",displayScope);
        console.log('changeDisplayScope: new scope set',displayScope);
        
        helper.filterResults(component,helper);
        
        console.log('changeDisplayScope: END')
    },
    handleTableAction: function(component, event, helper) {
        console.log('handleTableAction: START');
        
        let selectedAction = event.getParams();
        console.log('handleTableAction: selectedAction from event',JSON.stringify(selectedAction));
        
        helper.triggerAction(component,selectedAction.message,null);
        
        console.log('handleTableAction: END');
    }
})