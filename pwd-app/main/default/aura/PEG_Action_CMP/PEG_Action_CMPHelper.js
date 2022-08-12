({
	performAction : function(component,event) {
        console.log('performAction START');
        
        let eventArguments = event.getParam('arguments');
        console.log('performAction: eventArguments fetched',JSON.stringify(eventArguments));
        
        let requestParams = {};
        let successCallback;
        let errorCallback;
        let mode;
        if (eventArguments) {
            console.log('performAction: action from event',eventArguments.action);
            requestParams.action = eventArguments.action;
            
            console.log('performAction: target from event',JSON.stringify(eventArguments.target));
            requestParams.target = eventArguments.target;
            
            console.log('doCallOut: requestParams init',JSON.stringify(requestParams));
            
            console.log('performAction: onSuccess callback from event',eventArguments.onSuccess);
            successCallback = eventArguments.onSuccess; 
            
            console.log('performAction: onError callback from event',eventArguments.onError);
            errorCallback = eventArguments.onError; 
            
            console.log('performAction: mode from event',eventArguments.mode);
            mode = eventArguments.mode; 
        }
        else {
            console.error('performAction : missing event arguments');
            return;
        }
                              
        let executeActionRequest = component.get("c.executeAction");
        console.log('performAction : action selected');
        
        executeActionRequest.setParams(requestParams);
        console.log('performAction: params set',JSON.stringify(executeActionRequest.getParams()));

        executeActionRequest.setCallback(this, function(response){
            console.log('performAction: response received',response);
            
            if (response.getState() == "SUCCESS"){
                console.log('performAction: OK response received');
                //console.log('performAction: OK response received',response.getReturnValue());
                if (successCallback) successCallback(response.getReturnValue());
            } else {
                console.log('performAction: KO response received',response.getError());
                if (errorCallback) errorCallback(response.getError());
            }
            
            console.log('performAction: END');
        });
        console.log('performAction: executeActionRequest set',executeActionRequest);
                
        $A.enqueueAction(executeActionRequest);
        console.log('performAction: executeActionRequest sent');
	}
})