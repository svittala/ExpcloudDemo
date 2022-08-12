({
	doCallOut : function(component,event) {
        console.log('doCallOut START');
        
        let eventArguments = event.getParam('arguments');
        console.log('doCallOut: eventArguments fetched',eventArguments);
        
        let requestParams = {};
        let callback;
        if (eventArguments) {
            console.log('doCallOut: targetURL from event',eventArguments.targetURL);
            requestParams.targetURL = eventArguments.targetURL;
            
            console.log('doCallOut: httpMethod from event',eventArguments.httpMethod);
            requestParams.httpMethod = eventArguments.httpMethod;
            
            
            //requestParams.headerParams = new Map();
            if ((eventArguments.headerParams) && (eventArguments.headerParams.length > 0)) {
               console.log('performCallout: converting headerParams', eventArguments.headerParams);
               /*eventArguments.headerParams =  JSON.parse(eventArguments.headerParams);
               console.log('performCallout: headerParams parsed', eventArguments.headerParams);
               for (let paramIter in (eventArguments.headerParams)) {
                  console.log('performCallout: processing paramIter',paramIter);
                  (requestParams.headerParams).set(paramIter,(eventArguments.headerParams)[paramIter]);
               }*/
               requestParams.headerParams = JSON.parse(eventArguments.headerParams);
               console.log('performCallout: headerParams init',requestParams.headerParams); 
            } else {
               console.log('performCallout: ignoring headerParams', eventArguments.headerParams);
            }
            /*
            console.log('doCallOut: headerParams from event',JSON.stringify(eventArguments.headerParams));
            if(eventArguments.headerParams) {
                requestParams.headerParams = JSON.parse(eventArguments.headerParams);
            } else {
                requestParams.headerParams = {};
            }
            */
            console.log('doCallOut: requestBody from event',eventArguments.requestBody);
            requestParams.requestBody = eventArguments.requestBody;
            
            console.log('doCallOut: requestParams init',requestParams);
            
            console.log('doCallOut: callback from event',callback);
            callback = eventArguments.callback;
        }         
                
                
        var executeRequestAction = component.get("c.executeRequest");                  
        executeRequestAction.setParams(requestParams);
        console.log('doCallOut: params set',executeRequestAction.getParams());

        executeRequestAction.setCallback(this, function(response){
            console.log('doCallOut: response received',response);
            
            if (response.getState() == "SUCCESS"){
                console.log('doCallOut: OK response received',response.getReturnValue());
                if (callback) callback(response.getReturnValue(),null);
            } else {
                console.log('doCallOut: KO response received',response.getError());
                if (callback) callback(null,response.getError());
            }
            
            console.log('doCallOut: END');
        });
        console.log('doCallOut: executeRequestAction set',executeRequestAction);
                
        $A.enqueueAction(executeRequestAction);
        console.log('doCallOut: executeRequestAction sent');
	}
})