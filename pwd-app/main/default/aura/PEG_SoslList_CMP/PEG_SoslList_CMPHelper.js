({ 
    fetchResults: function(component,helper) {
        console.log('fetchResults: START');     
        let queryStr = component.get("v.query");
        console.log('fetchResults: queryStr retrieved',queryStr);
        let searchString = component.get("v.searchString");
        console.log('fetchResults: searchString retrieved',searchString);
        
        component.find('mergeUtil').merge(
            queryStr,
            {"value":searchString},
            function(mergeResult,mergeError) {
                console.log('fetchResults: result from merge');
                if (mergeResult) {
                   console.log('fetchResults: mergeResult received',mergeResult);
                   
                   component.find('soslUtil').runQuery(
                       mergeResult,
                       component.get("v.isStorable"),
                       component.get("v.isBackground"),
                       function(queryResult,queryError) {
                           console.log('fetchResults: result from query');
                           if (queryResult) {
                               console.log('fetchResults: queryResult received',queryResult);
                               
                               let displayJson = component.get('v.displayJson');
                               console.log('fetchResults: displayJson fetched',displayJson);
                               
                               let results = [];
                               let resultsCount = 0;
                               let currentObject = {};
                               queryResult.forEach(function(objResult, objResultKey) {
                                   console.log('fetchResults: processing object result',objResult);
                                
                                   currentObject = displayJson[objResultKey];                                
                                   console.log('fetchResults: for object',currentObject);
                                   
                                   resultsCount = resultsCount + objResult.length;
                                   //console.log('fetchResults: resultsCount increased',resultsCount);
                                   
                                   let items = [];
                                   objResult.forEach(function(rcdResult, rcdResultKey) {
                                       //console.log('fetchResults: processing record result',rcdResult);
                                       
                                       let contentDetails = [];
                                       (currentObject.display.content).forEach(function(fieldItem){
                                          let newVal = Object.assign({},fieldItem);
                                          newVal.value = rcdResult[newVal.value];
                                          contentDetails.push(newVal);
                                       });
                                       //console.log('fetchResults: contentDetails prepared',contentDetails);
                                       
                                       results.push({
                                          title        : rcdResult[currentObject.display.title] || "Undefined!",
                                          name         : currentObject.name                     || "Undefined!",
                                          icon         : currentObject.icon,
                                          color        : currentObject.color,
                                          columns      : currentObject.columns                  || 1,
                                          isCollapsible: currentObject.isCollapsible            || false,
                                          content      : contentDetails,
                                          id           : rcdResult.Id
                                       });
                                   });
                                   //console.log('fetchResults: items initialized',items);
                                   
                                   /*
                                   results.push({
                                       name         : currentObject.name          || "Undefined!",
                                       icon         : currentObject.icon          || "standard:question_feed",
                                       color        : currentObject.color         || "undefined",
                                       columns      : currentObject.columns       || 1,
                                       isCollapsible: currentObject.isCollapsible || false,
                                       values       : items }); 
                                   */
                                   //console.log('fetchResults: results updated',results);
                               });
                               console.log('fetchResults: results initialized',results);
                               
                               let isAscending = component.get("v.isAscending");
                               console.log('fetchResults: isAscending fetched',isAscending);
                               
                               //console.log('fetchResults: helper fetched',helper);
                               results = helper.sortResults(component,results,isAscending);
                               console.log('fetchResults: results sorted',results);
                               
                               component.set("v.resultsCount",resultsCount);
                               component.set("v.results",results);
                               
                               console.log('fetchResults: results saved',results);  
                           } else {
                               console.error('fetchResults: triggering query error notification',JSON.stringify(queryError));
                               component.find('notifUtil').showNotice({
                                  "variant": "error",
                                  "header": "Error in query for '" + component.get("v.title") + "'!",
                                  "message": JSON.stringify(queryError)
                               });
                           }
                       }
                   );
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
    triggerAction : function(component,selectedAction,selectedRow) {
        console.log('triggerAction: START');
        //let selectedActionStr = JSON.stringify(selectedAction);
        //console.log('triggerAction: action stringified',selectedActionStr);
        
        component.find('mergeUtil').trigger(
            selectedAction.event,
            selectedRow,
            null);
        
        console.log('triggerAction: END');
    },
    sortResults : function(component,results,isAscending) {
        console.log('sortResults: START',isAscending);
        
        console.log('sortResults: current list',results);

        let sortMethod = (component.find('jsonUtil')).getSort();
        results.sort(sortMethod('title', !isAscending));
        
        console.log('sortResults: sorted list',results);        
        return results;
    },
    filterResults: function(component,helper) {
        console.log('filterResults: START');     
        
        let displayScope = component.get("v.displayScope");
        console.log("filterResults: display scope fetched",displayScope);
        
        let resultsOrig  = component.get("v.resultsOrig");
        if (! resultsOrig) {
          resultsOrig = component.get("v.results");
          component.set("v.resultsOrig",resultsOrig);
          console.log("filterResults: original results saved",resultsOrig);
        } else {
          console.log("filterResults: original results fetched",resultsOrig);
        }
        
        if (displayScope === 'All') {
            console.log("filterResults: all results to be displayed",displayScope);
            component.set("v.results",resultsOrig);
            return;
        } else {
            console.log("filterResults: filtering results on scope",displayScope);
            
            let results = resultsOrig.filter(function(item) {
               //console.log("filterResults processing item",item);
               if (item.name === displayScope) return true;
               return false;
            });
               
            console.log("filterResults: results filtered",results);
            component.set("v.results",results);
            return;
        }
    }
})