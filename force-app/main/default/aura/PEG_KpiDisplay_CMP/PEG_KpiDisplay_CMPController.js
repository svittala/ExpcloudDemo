({
	doInit : function(component, event, helper) {
        console.log('doInitKPI: START');
        
        let title = component.get("v.title");
        if ((title) && (title.includes('$Label.'))) {
            console.log('doInitKPI: fetching title value for',title);
            title = $A.getReference(title) || title;
            console.log('doInitKPI: title value fetched',title);
            component.set("v.title",title);
        }
        
        let tableActionStr = component.get("v.tableActionStr");
        console.log('doInitKPI: tableActionStr retrieved',tableActionStr);      
        if (tableActionStr) {
           let tableActionJson = JSON.parse(tableActionStr);
           component.set("v.tableActionJson",tableActionJson);
           console.log('doInitKPI: tableActionJson initialized',tableActionJson);
        } else {
           console.log('doInitKPI: tableActionJson not initialized');
        } 
        
        let kpiActionStr = component.get("v.kpiActionStr");
        console.log('doInitKPI: kpiActionStr retrieved',kpiActionStr);      
        if (kpiActionStr) {
           let kpiActionJson = JSON.parse(kpiActionStr);
           if (kpiActionJson.length > 1) {
             kpiActionJson[kpiActionJson.length - 1].isLast = true;     
           }
           component.set("v.kpiActionJson",kpiActionJson);
           console.log('doInitKPI: kpiActionJson initialized',kpiActionJson);
        } else {
           console.log('doInitKPI: kpiActionJson not initialized');
        }
        
        console.log('doInitKPI: loading KPIdefinition');
        helper.loadKpis(component);
        
        console.log('doInitKPI: END');
	},
    refreshKPIs : function (component, event, helper) {
        console.log('refreshKPIs: START');
            
        helper.loadKpis(component);
        
        console.log('refreshKPIs: END');
    },
    /*
    openKpiReport : function (component, event, helper) {
        console.log('openKpiReport: START');
        
        let selectedKpi = event.getSource().get("v.value");
        console.log('openKpiReport: selectedKpi from event',JSON.stringify(selectedKpi));
        */
        /*
        let eventToTrigger = $A.get("e.force:navigateToObjectHome");
        eventToTrigger.setParams({
            "scope": selectedKpi.name
        });
        */
        /*
         [{"label":"Agence", "icon":"new_window" , "event":{"name":"e.force:navigateToSObject",  
                                                   "params":{"recordId":"{{{Context.agency.Id}}}",
                                                   "slideDevName":"related" } } }, 
          { "label":"Plan 2",  "event":{ "name":"e.force:navigateToURL",
                                         "params":{  "url":"/lightning/n/Plan_2"  } }    },
          { "label":"Calendar", "icon":"open", "event":{ "name":"e.force:navigateToObjectHome",
                                               "params":{ "scope":"Event"             }         }     } ]
         * */
        /*
        helper.triggerAction(component,
                             {"event":{
                                 "name":"e.ltng:sendMessage",
                                 "params":{
                                     "channel": "PEG_ActionPlan",
                                     "message": {"name":"e.force:navigateToSObject",
                                                 "selection":selectedKpi.name,
                                                 "params":{"recordId": "{{{Context.agency.Id}}}"}}
                                 }
                             }},    
                             null);
        */
        /*
        let eventToTrigger = $A.get("e.ltng:sendMessage");
        eventToTrigger.setParams({
            "channel": "PEG_ActionPlan",
            "message": {"name":"e.force:navigateToSObject",
                        "selection":"Opportunities",
                        "params":{"recordId": "{{{Context.agency.Id}}}"}}
        });
        console.log('openKpiReport: triggering event',eventToTrigger);
        
        eventToTrigger.fire();
        */
    /*    
        console.log('openKpiReport: END');
    },
    */
    handleTableAction: function(component, event, helper) {
        console.log('handleTableAction: START');
        
        let selectedAction = event.getParams();
        console.log('handleTableAction: selectedAction from event',JSON.stringify(selectedAction));
        
        helper.triggerAction(component,selectedAction.message,null);
        
        console.log('handleTableAction: END');
    },
    handleKpiAction: function(component, event, helper) {
        console.log('handleKpiAction: START');
        
        let selectedKPI    = event.getSource().get("v.value");
        console.log('handleKpiAction: selectedKPI from event',JSON.stringify(selectedKPI));

        let selectedActionName = event.getSource().get("v.alternativeText");
        console.log('handleKpiAction: selectedActionName from event',JSON.stringify(selectedActionName));
        
        let kpiActionJson = component.get("v.kpiActionJson");
        let selectedAction = kpiActionJson.find(function(element) {
            return element.name ==  selectedActionName;
         });
        console.log('handleKpiAction: selectedAction from config',JSON.stringify(selectedAction));
        
        helper.triggerAction(component,selectedAction,selectedKPI);
        
        console.log('handleKpiAction: END');
    }
})