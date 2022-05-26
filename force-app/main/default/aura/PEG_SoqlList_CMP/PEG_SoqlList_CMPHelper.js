({
    fetchResults: function(component) {
        console.log('fetchResults: START');     
        let queryStr = component.get("v.query");
        console.log('fetchResults: queryStr retrieved',queryStr);
        
        let isInfiniteLoad = component.get("v.isInfiniteLoad");
        console.log('fetchResults: isInfiniteLoad fetched',isInfiniteLoad);
        if (isInfiniteLoad) {
            var pageSize = component.get("v.pageSize");
            var results  = component.get("v.results") || [];
            queryStr = queryStr + ' LIMIT ' + pageSize + ' OFFSET ' + results.length;
            console.log('fetchResults: queryStr updated',queryStr);
        }
        
        component.find('mergeUtil').merge(
            queryStr,
            null,
            function(mergeResult,mergeError) {
                console.log('fetchResults: result from merge');
                if (mergeResult) {
                   console.log('fetchResults: mergeResult received',mergeResult);
                   
                   component.find('soqlUtil').runQuery(
                       mergeResult,
                       component.get("v.bypassFLS"),
                       component.get("v.bypassSharing"),
                       component.get("v.queryType"),
                       component.get("v.isStorable"),
                       component.get("v.isBackground"),
                       function(queryResult,queryError) {
                           console.log('fetchResults: result from query');
                           if (queryResult) {
                               console.log('fetchResults: queryResult received',queryResult);
                               
                               if ((component.get("v.isFlatten")) || (component.get("v.isTreeView"))) {
                                   console.log('fetchResults: flattening queryResult');
                                   let treeFieldName = component.get("v.treeFieldName");
                                   console.log('fetchResults: treeFieldName fetched',treeFieldName);
                                   let treeFields = null;
                                   if (treeFieldName) treeFields = JSON.parse(treeFieldName);
                                   console.log('fetchResults: treeFields set',treeFields);
                                   
                                   queryResult = component.find('jsonUtil').flattenJson(queryResult,treeFields);
                                   console.log('fetchResults: queryResult flattened',queryResult);
                               } 
                               if (component.get("v.hasTotal")) {
                                   console.log('fetchResults: fetching last line as total');
                                   let totalLine = queryResult.pop();
                                   let totalStr =  component.get("v.totalStr");
                                   if (totalStr) {
                                      let totalJson = JSON.parse(totalStr);
                                      console.log('fetchResults: totals fetched',totalJson);
                                      let totals = [];
                                      totalJson.forEach(function(item){
                                         totals.push({"name":item,"value":totalLine[item]});
                                      });
                                      component.set("v.totals",totals);
                                      console.log('fetchResults: totals set',totals);
                                   } else {
                                      console.warn('fetchResults: no total configuration found');
                                   }
                               }
                               
                               if (isInfiniteLoad) {
                                   console.log('fetchResults: processing infinite loading',results);  
                                   results = results.concat(queryResult);
                                   console.log('fetchResults: queryResult appended to current results',results); 
                                   component.set("v.results",results);
                                   console.log('fetchResults: results saved (infinite loading)');  
                                   if (queryResult.length < pageSize) {
                                       console.log('fetchResults: last page reached',queryResult.length);
                                       component.set("v.isOngoingLoad",false);
                                   }
                                   console.log('fetchResults: results refetched',component.get("v.results"));
                               } else {
                                   component.set("v.results",queryResult);
                                   console.log('fetchResults: queryResult saved (no infinite loading)');  
                               }
                           } else {
                              component.set("v.queryError", true);
                              if(JSON.stringify(queryError).includes('secure query included')) {
                                  component.set("v.queryErrorMessage", "Error when fetching results: you don't have permissions to access one of the fields specified.");
                              } else {
                                  component.set("v.queryErrorMessage", "Error when fetching results: " + JSON.stringify(queryError));
                              }
                               /*console.error('fetchResults: triggering query error notification',JSON.stringify(queryError));
                               component.find('notifUtil').showNotice({
                                  "variant": "error",
                                  "header": "Error in query for '" + component.get("v.title") + "'!",
                                  "message": JSON.stringify(queryError)
                               });*/
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
    filterResults: function(component) {
        console.log('filterResults: START');     
        
        let searchScope = component.get("v.searchScope");
        console.log("filterResults: filter scope fetched",searchScope);
        
        let searchString = component.get("v.searchString");
        console.log("filterResults: filter requested",searchString);
        
        let resultsOrig  = component.get("v.resultsOrig");
        if (! resultsOrig) {
          resultsOrig = component.get("v.results");
          component.set("v.resultsOrig",resultsOrig);
          console.log("filterResults: original results saved",resultsOrig);
        } else {
          console.log("filterResults: original results fetched",resultsOrig);
        }

        if (searchString) {
            searchString = searchString.toLowerCase();
            console.log("filterResults filtering list",searchString);
            
            let searchTerms = searchString.split(' ');
            console.log("filterResults search terms extracted",searchTerms);
            
            let results = resultsOrig;
            if (searchScope == 'All') {
                console.log("filterResults global search requested");
                
                searchTerms.forEach(function(searchWord) {
                  console.log("filterResults processing searchWord",searchWord);
                  if ((searchWord) && (searchWord.trim())) {
                    searchWord = searchWord.trim();
                    results = results.filter(function(item) {
                      //console.log("filterResults processing item",item);
                      for (let fieldName in item) {
                        //console.log("filterResults processing fieldName",fieldName);
                        if (typeof item[fieldName] == 'string') {
                          //console.log("filterResults processing text value",item[fieldName]);
                          if ((item[fieldName].toLowerCase()).includes(searchWord)) return true;
                        }
                      }
                      //console.log("filterResults returning false for item",item);
                      return false;
                    });
                  } else {
                    console.log("filterResults ignored searchWord",searchWord);
                  }
                  console.log("filterResults results updated",results);
                });
            } else {
                console.log("filterResults scoped search requested",searchScope);
                
                let fieldJson = component.get("v.fieldJson");
                console.log("filterResults fieldJson fetched",fieldJson);
                
                let field = fieldJson.find(function(item){
                    return item.label == searchScope;
                });
                console.log("filterResults field found",field);
                let fieldName= field.fieldName;
                console.log("filterResults fieldName set",fieldName);
                
                searchTerms.forEach(function(searchWord) {
                  if ((searchWord) && (searchWord.trim())) {
                    searchWord = searchWord.trim();
                    results = results.filter(function(item2) {
                      //console.log("filterResults processing item",item2);
                      //console.log("filterResults item2 value searched",item2[fieldName]);
                      if (item2[fieldName]) {
                        return ((item2[fieldName]).toLowerCase()).includes(searchWord);
                      } else {
                        return false;
                      }
                    });
                    console.log("filterResults results updated",results);
                  } else {
                     console.log("filterResults ignored searchWord",searchWord);
                  }
                });
            }
            console.log("filterResults results filtered",results);   
            component.set("v.results",results);
        } else {
            console.log("filterResults unfiltering results",resultsOrig);   
            component.set("v.results",resultsOrig);
        }
        console.log('filterResults: END');
    }
})