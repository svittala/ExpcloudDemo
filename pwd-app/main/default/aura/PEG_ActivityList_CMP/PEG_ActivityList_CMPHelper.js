({
	fetchActivities : function(component,helper) {
        console.log('fetchActivities: START'); 
        
        let scopes = {};
        let taskScope  = component.get("v.taskScope");
        console.log('fetchActivities: taskScope retrieved',taskScope);
        if (taskScope) scopes["task"] = taskScope;
        let eventScope = component.get("v.eventScope");
        console.log('fetchActivities: eventScope retrieved',eventScope);
        if (eventScope) scopes["event"] = eventScope;
        console.log('fetchActivities: scopes initialized',scopes);
        console.log('fetchActivities: fetchCount computed',Object.keys(scopes).length);
        component.set("v.fetchCount",Object.keys(scopes).length);
        component.set("v.results",null);
        
        component.find('mergeUtil').merge(
            JSON.stringify(scopes),
            null,
            function(mergeResult,mergeError) {
                console.log('fetchActivities: result from merge');
                if (mergeResult) {
                   console.log('fetchActivities: mergeResult received',mergeResult);
                   
                   let mergedScopes = JSON.parse(mergeResult);
                   console.log('fetchActivities: mergeResult received',mergedScopes);
                               
                   if (mergedScopes.task) {
                       let taskQuery = component.get("v.taskQuery");
                       console.log('fetchActivities: taskQuery fetched',taskQuery);
                    
                       component.find('soqlUtil').runQuery(
                          taskQuery + ' ' + mergedScopes.task,
                          component.get("v.bypassFLS"),
                          component.get("v.bypassSharing"),
                          component.get("v.queryType"),
                          component.get("v.isStorable"),
                          component.get("v.isBackground"),
                          function(queryResult,queryError) {
                              helper.handleActivityLoad(queryResult,queryError,component);
                          }
                       );
                       console.log('fetchActivities: taskQuery sent');
                   }
                    
                   if (mergedScopes.event) {
                       let eventQuery = component.get("v.eventQuery");
                       console.log('fetchActivities: eventQuery fetched',eventQuery);
                    
                       component.find('soqlUtil').runQuery(
                          eventQuery + ' ' + mergedScopes.event,
                          component.get("v.bypassFLS"),
                          component.get("v.bypassSharing"),
                          component.get("v.queryType"),
                          component.get("v.isStorable"),
                          component.get("v.isBackground"),
                          function(queryResult,queryError) {
                              helper.handleActivityLoad(queryResult,queryError,component);
                          }
                       );
                       console.log('fetchActivities: eventQuery sent');
                   }
                
                   console.log('fetchActivities: all queries sent');
                } else {
                   console.error('fetchResults: triggering merge error notification',JSON.stringify(mergeError));
                   component.find('notifUtil').showNotice({
                      "variant": "error",
                      "header": "Error in merge for '" + component.get("v.title") + "'!",
                      "message": JSON.stringify(mergeError)
                   });
                }
            }
        );
        
        console.log('fetchResults: END');
    },
    handleActivityLoad : function(activityResult,activityError,component) {
        console.log('handleActivityLoad: START');
        if (activityResult) {
           console.log('handleActivityLoad: activityResult received',activityResult);
                               
           let results = component.get('v.results');
           console.log('handleActivityLoad: current results fetched',results);
                               
           if (results) {
               activityResult = activityResult.concat(results);
               console.log('handleActivityLoad: activityResult concatenated',activityResult);
               activityResult.sort(function(a,b){
                   let aa = (a.StartDateTime || a.ActivityDate) || '';
                   let bb = (b.StartDateTime || b.ActivityDate) || '';
                   return ((aa < bb) ? 1 : ((aa > bb) ? -1 : 0) );    
               });
               console.log('handleActivityLoad: activityResult sorted',activityResult);
           }
           component.set("v.results",activityResult);
           console.log('handleActivityLoad: activityResult saved');
           
           let fetchCount = component.get("v.fetchCount");
           console.log('handleActivityLoad: decreasing fetchCount from',fetchCount);
           component.set("v.fetchCount",fetchCount - 1);
        } else {
           console.error('handleActivityLoad: triggering load error notification',JSON.stringify(activityError));
           component.find('notifUtil').showNotice({
                "variant": "error",
                "header": "Error in activity load for '" + component.get("v.title") + "'!",
                "message": JSON.stringify(activityError)
           });
        } 
        return;           
    },     
    triggerAction : function(component,selectedAction,selectedRow) {
        console.log('triggerAction: START');
        //let selectedActionStr = JSON.stringify(selectedAction);
        //console.log('triggerAction: action stringified',selectedActionStr);
        
        component.find('mergeUtil').trigger(
            selectedAction.event,
            selectedRow,
            null);
      
        console.log('triggerAction: END');
    }
})