({
    loadData : function(component,helper) {
		console.log('loadData: START');   
        
        let queryStr = component.get("v.query");
        console.log('loadData: queryStr retrieved',queryStr);
        
        component.find('mergeUtil').merge(
            queryStr,
            null,
            function(mergeResult,mergeError) {
                console.log('loadData: result from merge');
                if (mergeResult) {
                   console.log('loadData: mergeResult received',mergeResult);
                   
                   component.find('soqlUtil').runQuery(
                       mergeResult,
                       component.get("v.bypassFLS"), // bypass FLS
                       component.get("v.bypassSharing"),
                       component.get("v.queryType"),
                       component.get("v.isStorable"),
                       component.get("v.isBackground"),
                       function(queryResult,queryError) {
                           console.log('loadData: result from query');
                           if (queryResult) {
                               console.log('loadData: queryResult received',JSON.stringify(queryResult));
                               
                               queryResult = component.find('jsonUtil').transposeJson(queryResult);
                               console.log('loadData: queryResult transposed',JSON.stringify(queryResult));
                               component.set("v.data",queryResult);
                               
                               let dimension = component.get("v.dimension");
                               console.log('loadData: dimension fetched',dimension);
                               let dimensionValues = queryResult[dimension];
                               console.log('loadData: dimensionValues init',dimensionValues);
                               //component.set("v.dimensionValues",dimensionValues);
                               
                               if (dimensionValues) {
                                 let uniqueDimensions = new Set();
                                 let tmpDim;
                                 dimensionValues.forEach(function(row){
                                   tmpDim = row || 'Undefined';
                                   console.log('loadData: processing tmpDim',tmpDim);
                                   uniqueDimensions.add(tmpDim);
                                 });
                                 console.log('loadData: uniqueDimensions extracted',uniqueDimensions);
                               
                                 let colorList = component.find('jsonUtil').getColors(uniqueDimensions.size);
                                 console.log('loadData: colorList fetched',colorList);
                                 let legend = [];
                                 let iter = 0;
                                 uniqueDimensions.forEach(function(dimVal) {
                                   //console.log('loadData: processing dimVal/dimIter',dimVal,dimIter);
                                   legend.push({"name": dimVal,
                                                "color": colorList[iter]});
                                   iter += 1;
                                 });
                                 console.log('loadData: legend initialized',legend);
                                 component.set("v.legend",legend);          
                                          
                                 let measureStr = component.get("v.measureStr");
                                 console.log('doInit measureStr fetched',measureStr);
                                 let measureJson = JSON.parse(measureStr);
                                 console.log('loadData: measureJson parsed',measureJson);
                               
                                 let measureValues = [];
                                 const sumMethod = (accumulator, currentValue) => (accumulator || 0) + (currentValue || 0);
                               
                                 measureJson.forEach(function(measure) {
                                   console.log('loadData: processing measure',measure);
                                   //console.log('loadData: measure values',JSON.stringify(queryResult[measure]));
                                   //console.log('loadData: measure sum',(queryResult[measure]).reduce(sumMethod));
                                   if (queryResult[measure]) {
                                     measureValues.push({"name" : measure,
                                                         "total": (queryResult[measure]).reduce(sumMethod)});
                                   } else {
                                     measureValues.push({"name" : measure,
                                                         "total": 0});
                                   }
                                 });
                                 console.log('loadData: measureValues init',JSON.stringify(measureValues));
                                 component.set("v.measureValues",measureValues); 
                               }
                           }
                           else {
                               console.error('loadData: triggering query error notification',JSON.stringify(queryError));
                               component.find('notifUtil').showNotice({
                                  "variant": "error",
                                  "header": "Error in query for '" + component.get("v.title") + "'!",
                                  "message": JSON.stringify(queryError)
                               });
                           }
                       }
                   );
                }
                else {
                   console.error('loadData: triggering merge error notification',JSON.stringify(mergeError));
                   component.find('notifUtil').showNotice({
                      "variant": "error",
                      "header": "Error in merge for '" + component.get("v.title") + "'!",
                      "message": JSON.stringify(mergeError)
                   });
                }
            }
        );
        console.log('loadData: END');  
	}
})