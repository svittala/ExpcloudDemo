({
    fetchData : function(component,helper) {
        console.log('fetchData: START'); 
        
        let queryListJson  = component.get("v.queryListJson");
        console.log('fetchData: queryListJson retrieved',queryListJson);
        
        component.find('mergeUtil').merge(
            JSON.stringify(queryListJson),
            null,
            function(mergeResult,mergeError) {
                console.log('fetchData: result from merge');
                if (mergeResult) {
                   console.log('fetchData: mergeResult received',mergeResult);
                   
                   let mergedQueries = JSON.parse(mergeResult);
                   console.log('fetchData: mergedQueries received',mergedQueries);
                   
                   var queryCount = mergedQueries.length;
                   component.set("v.queryCount",queryCount);
                   console.log('fetchData: queryCount set',queryCount);
                   var queryResults = [];
                   
                   mergedQueries.forEach(function(queryItem) {
                       console.log('fetchData: sending soql for queryItem',queryItem);
                       component.find('soqlUtil').runQuery(
                          queryItem.query,
                          component.get("v.bypassFLS"),
                          component.get("v.bypassSharing"),
                          component.get("v.queryType"),
                          component.get("v.isStorable"),
                          component.get("v.isBackground"),
                          function(result,error) {
                              console.log('fetchData: result from SOQL query for item',queryItem);                           
                              if (result) {
                                  console.log('fetchData: results received', result);
                                  queryCount = queryCount - 1;
                                  
                                  result = component.find('jsonUtil').flattenJson(result,null);
                                  console.log('fetchData: results flattened', result);
                                  
                                  result.forEach(function(resultItem){
                                      console.log('fetchData: completing resultItem', resultItem);
                                      resultItem.title = resultItem[queryItem.display.title];
                                      resultItem.content = [];
                                      (queryItem.display.content).forEach(function(item){
                                            let newVal = Object.assign({},item);
                                            newVal.value = resultItem[newVal.value];
                                            resultItem.content.push(newVal);
                                      });
                                      resultItem.icon          = queryItem.icon;
                                      resultItem.sObjectName   = queryItem.name;
                                      resultItem.isCollapsible = queryItem.isCollapsible;
                                      resultItem.sortValue     = resultItem[queryItem.sortBy];
                                      resultItem.color         = queryItem.color;
                                      resultItem.columns       = queryItem.columns;
                                  });
                                  console.log('fetchData: result completed', result);
                                  queryResults = queryResults.concat(result);
                                  console.log('fetchData: queryResults concatenated', queryResults);
                                  
                                  if (queryCount == 0) {
                                      console.log('fetchData: last query processed', queryCount);
                                      let isAscending = component.get("v.isAscending");
                                      queryResults = helper.sortResults(component,queryResults,isAscending);
                                      console.log('fetchData: queryResult sorted', queryResults);
                                      component.set("v.queryResults", queryResults);
                                      component.set("v.queryCount",   queryCount);
                                  } else {
                                      console.log('fetchData: waiting for last query', queryCount);
                                  }
                              } else {
                                  console.error('loadKpis: SOQL query error',error);
                                  component.find('notifUtil').showNotice({
                                            "variant": "error",
                                            "header": "Error in query for '" + component.get("v.title") + "'!",
                                            "message": JSON.stringify(error) + ' for ' + queryItem.query
                                  });
                              }
                          });
                       console.log('fetchData: SOQL query sent for queryItem',queryItem);
                   });
                   
                   console.log('fetchData: all SOQL queries sent');
                    
                } else {
                   console.error('fetchData: triggering merge error notification',JSON.stringify(mergeError));
                   component.find('notifUtil').showNotice({
                      "variant": "error",
                      "header": "Error in merge for '" + component.get("v.title") + "'!",
                      "message": JSON.stringify(mergeError)
                   });
                }
            });
        console.log('fetchData: END');
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
        results.sort(sortMethod('sortValue', !isAscending));
        
        console.log('sortResults: sorted list',results);        
        return results;
    },
    filterResults: function(component,helper) {
        console.log('filterResults: START');     
        
        let displayScope = component.get("v.displayScope");
        console.log("filterResults: display scope fetched",displayScope);
        
        let queryResultsOrig  = component.get("v.queryResultsOrig");
        if (! queryResultsOrig) {
          queryResultsOrig = component.get("v.queryResults");
          component.set("v.queryResultsOrig",queryResultsOrig);
          console.log("filterResults: original results saved",queryResultsOrig);
        } else {
          console.log("filterResults: original results fetched",queryResultsOrig);
        }
        
        if (displayScope === 'All') {
            console.log("filterResults: all results to be displayed",displayScope);
            component.set("v.queryResults",queryResultsOrig);
            return;
        } else {
            console.log("filterResults: filtering results on scope",displayScope);
            
            let queryResults = queryResultsOrig.filter(function(item) {
               //console.log("filterResults processing item",item);
               if (item.sObjectName === displayScope) return true;
               return false;
            });
               
            console.log("filterResults: results filtered",queryResults);
            component.set("v.queryResults",queryResults);
            return;
        }
    }
})