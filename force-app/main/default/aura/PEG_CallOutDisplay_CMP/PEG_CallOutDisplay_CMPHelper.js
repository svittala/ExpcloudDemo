({
	performCallout : function(component,helper) {
		console.log('performCallout: START');
        
        component.set("v.requestDone",false);
        
        let calloutParams = {
            "targetURL":    component.get("v.targetURL"),
            "headerParams": component.get("v.headerParams"),
            "requestBody":  component.get("v.requestBody")
        }
        let calloutStr = JSON.stringify(calloutParams);
        console.log('performCallout: calloutStr prepared',calloutStr);
        
        component.find('mergeUtil').merge(
            calloutStr,
            null,
            function(mergeResult,mergeError) {
                console.log('performCallout: result from merge');
                if (mergeResult) {
                   console.log('performCallout: mergeResult fetched',mergeResult); 
                   calloutParams = JSON.parse(mergeResult);
                   console.log('performCallout: calloutParams parsed',calloutParams); 
  
                   component.find("calloutUtil").runCallOut(
                       calloutParams.targetURL,
                       component.get("v.httpMethod"),
                       calloutParams.headerParams,
                       calloutParams.requestBody,
                       function(calloutResponse,calloutError) { 
                          console.log('performCallout: result from callout');
                          if (calloutResponse) {
                              console.log('performCallout: calloutResponse fetched',calloutResponse); 
                              let calloutResponseJson = JSON.parse(calloutResponse);
                              console.log('performCallout: calloutResponse parsed',calloutResponseJson);
                              
                              if ((component.get("v.isFlatten")) || (component.get("v.isTreeView"))) {
                                   console.log('performCallout: flattening calloutResponseJson');
                                   let treeFields = component.get("v.treeFields");
                                   console.log('performCallout: treeFields fetched',treeFields);
                                   let treeFieldsJSON = null;
                                   if (treeFields) treeFieldsJSON = JSON.parse(treeFields);
                                   console.log('performCallout: treeFieldsJSON set',treeFieldsJSON);
                                   
                                   calloutResponseJson = component.find('jsonUtil').flattenJson(calloutResponseJson,treeFieldsJSON);
                                   console.log('performCallout: calloutResponseJson flattened',JSON.stringify(calloutResponseJson));
                              } else {
                                  console.log('performCallout: keeping response unflattened');
                              }
 
                              if (component.get("v.showObject")) {
                                  console.log('performCallout: initializing Object');
                                  helper.updateObject(component,calloutResponseJson);
                              } else {
                                  console.log('performCallout: no Object to init');
                              }
              
                              if (component.get("v.showList")) {
                                  console.log('performCallout: initializing List');
                                  helper.updateList(component,calloutResponseJson,helper);
                              } else {
                                  console.log('performCallout: no List to init');
                              }
               
                              component.set("v.requestDone",true);
                              console.log('performCallout: END OK');
                          } else {
                              console.error('performCallout: triggering callout error notification',JSON.stringify(calloutError));
                              component.find('notifUtil').showNotice({
                                  "variant": "error",
                                  "header": "Error in callout for '" + component.get("v.title") + "'!",
                                  "message": JSON.stringify(calloutError)
                              });
                              component.set("v.requestDone",true);
                          }
                       }
                    );
                } else {
                   console.error('performCallout: triggering merge error notification',JSON.stringify(mergeError));
                   component.find('notifUtil').showNotice({
                      "variant": "error",
                      "header": "Error in merge for '" + component.get("v.title") + "'!",
                      "message": JSON.stringify(mergeError)
                   });
                   component.set("v.requestDone",true);
                }
            }
        );
     
        console.log('performCallout: callout requested');
	},
    updateObject : function(component,responseJson) {
        console.log('updateObject: START');
        
        let fieldsJSON = component.get("v.fieldsJSON");
        console.log('updateObject: fieldsJSON fetched',fieldsJSON);
        fieldsJSON.forEach(function(fieldItem){
            console.log('updateObject: processing field',fieldItem);
            console.log('updateObject: fieldItem.fieldName',fieldItem.fieldName);
            fieldItem.value = responseJson[fieldItem.fieldName];
            console.log('updateObject: field updated',fieldItem);
        });
        console.log('updateObject: fieldsJSON (re)set',fieldsJSON);
        component.set("v.objectFields",fieldsJSON);
        
        console.log('updateObject: END');
    },
    updateList : function(component,responseJson,helper) {
        console.log('updateList: START');
        
        let listResults;
        let listField = component.get("v.listField");
        console.log('updateList: listField fetched',listField);
        if (listField) {
            console.log('updateList: using sublist');
            listResults = responseJson[listField];
        } else {
            console.log('updateList: using main list');
            listResults = responseJson;
        }
        console.log('updateList: listResults set',listResults);
        
        component.set("v.results",listResults);
        
        console.log('updateList: END');     
    }
})