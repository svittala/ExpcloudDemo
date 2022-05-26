({
	fetchData : function(component,helper) {
        console.log('fetchData: START'); 
        
        let soqlQuery  = component.get("v.soqlQuery");
        console.log('fetchData: soqlQuery retrieved',soqlQuery);
        
        component.find('mergeUtil').merge(
            soqlQuery,
            null,
            function(mergeResult,mergeError) {
                console.log('fetchData: result from merge');
                if (mergeResult) {
                   console.log('fetchData: mergeResult received',mergeResult);
                       
                   component.find('soqlUtil').runQuery(
                          mergeResult,
                          false,
                          false,
                          "",
                          false,
                          false,
                          function(queryResult,queryError) {
                              if (queryResult) {
                                  console.log('fetchData: queryResult received',JSON.stringify(queryResult));
                                  
                                  //let fieldJson  = component.get("v.fieldJson");
                                  //console.log('fetchData: fieldJson retrieved',fieldJson);
                                  
                                  let fieldStr = component.get("v.fieldStr");
                                  console.log('fetchData: fieldStr retrieved',fieldStr);
                                  
                                  component.find('mergeUtil').merge(
                                      fieldStr,
                                      queryResult[0],
                                      function(mergeResult2,mergeError2) {
                                          console.log('fetchData: second merge done');
                                          if(mergeResult2) {
                                              console.log('fetchData: mergeResult2 received',mergeResult2);
                                              component.set("v.fieldJson",JSON.parse(mergeResult2));
                                              component.set("v.showTabs",true);
                                          } else {
                                              console.error('fetchData: triggering second merge error notification',JSON.stringify(mergeError2));
                                              component.find('notifUtil').showNotice({
                                                  "variant": "error",
                                                  "header": "Error in query result merge execution !",
                                                  "message": JSON.stringify(mergeError2)
                                              });
                                          }
                                      });
                              } else {
                                  console.error('fetchData: triggering query error notification',JSON.stringify(queryError));
                                  component.find('notifUtil').showNotice({
                                      "variant": "error",
                                      "header": "Error in query for '" + component.get("v.title") + "'!",
                                      "message": JSON.stringify(queryError)
                                  });
                              }
                          });
                } else {
                    console.error('fetchData: triggering merge error notification',JSON.stringify(mergeError));
                    component.find('notifUtil').showNotice({
                         "variant": "error",
                         "header": "Error in merge for '" + component.get("v.title") + "'!",
                         "message": JSON.stringify(mergeError)
                    });
                }
            });
                                              	
	}
})