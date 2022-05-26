({
	runExecQuery : function(component,query,setStorable,setBackground,callback) {
        console.log('runExecQuery: START');
       
        if ((! callback) || (! query)) {   
            console.error('runExecQuery: missing parameters');
            return;
        }
        
        let queryAction;
        if (setStorable) {
           queryAction = component.get("c.executeQueryStorable");
           console.log('runExecQuery: storable query requested',setStorable);
        } else {
           queryAction = component.get("c.executeQuery");
           console.log('runExecQuery: non storable query requested',setStorable);
        }  
        queryAction.setParams({
            "queryString": query
        });
        console.log('runExecQuery: queryAction params set',{
            "queryString": query
        });
        
        /*
        if (setStorable) {
           queryAction.setStorable();
        }
        console.log('runExecQuery: setStorable set',setStorable);
        */
        if (setBackground) {
           queryAction.setBackground();
        }
        console.log('runExecQuery: setBackground set',setBackground);
        
        var callbackAction = callback;
        queryAction.setCallback(this, function(response){
            console.log('runExecQuery: response received',response);
            
            if (response.getState() == "SUCCESS"){
                console.log('runExecQuery: OK response received',response.getReturnValue());
                callback(response.getReturnValue(),null);
            } else {
                console.log('runExecQuery: KO response received',response.getError());
                callback(null,response.getError());
            }
            console.log('runExecQuery: END');
        });
        console.log('runExecQuery: queryAction set',queryAction);
                
        $A.enqueueAction(queryAction);
        console.log('runExecQuery: queryAction sent');
	}
})