({
	doGetSort : function(component, event, helper) {
        console.log('doGetSort triggered');
		return helper.sortBy;
	},
    doJsonFlatten : function(component, event, helper) {
        console.log('doJsonFlatten: START');
        
        let methodArg = event.getParam('arguments');
        //console.log('doJsonFlatten: methodArg fetched',JSON.stringify(methodArg));
        
        let jsonInput = methodArg.json;
        //console.log('doJsonFlatten: jsonInput fetched',JSON.stringify(jsonInput));
        let jsonChildren = methodArg.children;
        //console.log('doJsonFlatten: jsonChildren fetched',JSON.stringify(jsonChildren));
        
        if (jsonInput) {
            console.log('doJsonFlatten: processing json input');
            
            if (jsonInput.constructor === [].constructor) {
               console.log('doJsonFlatten: flattening list');
               helper.flattenJsonList(jsonInput,jsonChildren,helper);
               console.log('doJsonFlatten: END / list flattened',jsonInput);
               return jsonInput;
            } else if (jsonInput.constructor === {}.constructor) {
               console.log('doJsonFlatten: flattening object');
               helper.flattenJsonObject(jsonInput,jsonChildren,helper);
               console.log('doJsonFlatten: END / object flattened',jsonInput);
               return jsonInput;
            } else {
               console.error('doJsonFlatten: END / bad json input');
               return null;
            }
        } else {
            console.error('doJsonFlatten: END / missing json input');
            return null;
        }
	},
    doJsonTranspose : function(component, event, helper) {
        console.log('doJsonTranspose: START');
        
        let methodArg = event.getParam('arguments');
        console.log('doJsonTranspose: methodArg fetched',JSON.stringify(methodArg));
        
        let jsonInput = methodArg.json;
        console.log('doJsonTranspose: jsonInput fetched',JSON.stringify(jsonInput));
        
        if (jsonInput) {
            if (jsonInput.constructor === [].constructor) {
                let transposedJson = helper.transposeJson(jsonInput);
                console.log('doJsonTranspose: END',transposedJson);
                return transposedJson;
            } else {
                console.error('doJsonTranspose: END / json input of wrong type');
                return null;
            }
        } else {
            console.error('doJsonTranspose: END / missing json input');
            return null;
        }
    },
    doGetColors : function(component, event, helper) {
        console.log('doGetColors triggered');
        let methodArg = event.getParam('arguments');
        let colorNumber = methodArg.colorNumber;
        console.log('doGetColors: colorNumber requested',colorNumber);
		return helper.getColors(colorNumber);
	}
})