({
	runExecQuery : function(component,query,bypassFLS,bypassSharing,queryType,setStorable,setBackground,callback) {
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
            "queryString":   query,
            "bypassFLS":     bypassFLS,
            "bypassSharing": bypassSharing,
            "queryType":     queryType
        });
        console.log('runExecQuery: queryAction params set',{
            "queryString":   query,
            "bypassFLS":     bypassFLS,
            "bypassSharing": bypassSharing,
            "queryType":     queryType
        });
        
        /*if (setStorable) {
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
	},
    runExecDML : function(component, dmlOperation, itemList, callback) {
        console.log('runExecDML: START');
        
        if ((! callback) || (! dmlOperation) || (! itemList)) {   
            console.error('runExecDML: missing parameters');
            return;
        }
        
        var dmlAction = component.get("c.executeDML");
        dmlAction.setParams({
            "itemList": itemList,
            "operation": dmlOperation
        });
        console.log('runExecDML: dmlAction params set',{
            "itemList": itemList,
            "operation": dmlOperation
        });
        
        var callbackAction = callback;
        dmlAction.setCallback(this, function(response){
            console.log('runExecDML: response received',response);
            
            if (response.getState() == "SUCCESS"){
                console.log('runExecDML: OK response received',response.getReturnValue());
                callback(response.getReturnValue(),null);
            } else {
                console.log('runExecDML: KO response received',response.getError());
                callback(null,response.getError());
            }
            console.log('runExecDML: END');
        });
        console.log('runExecDML: queryAction set',dmlAction);
                
        $A.enqueueAction(dmlAction);
        console.log('runExecDML: queryAction sent');
     },
    // Work in Progress
     runExecMultiQuery : function(component,queryList,setStorable,setBackground,callback) {
        console.log('runExecMultiQuery: START');
       
        if ((! callback) || (! queryList)) {   
            console.error('runExecMultiQuery: missing parameters',
                          {"queryList":queryList,"callback":callback});
            return;
        }
        
        var queryAction = component.get("c.executeMultiQuery");
        queryAction.setParams({
            "queries": queryList
        });
        console.log('runExecMultiQuery: multiQueryAction params set',{
            "queries": queryList
        });
        
        if (setStorable) {
           queryAction.setStorable();
        }
        console.log('runExecMultiQuery: setStorable set',setStorable);
        
        if (setBackground) {
           queryAction.setBackground();
        }
        console.log('runExecMultiQuery: setBackground set',setBackground);
        
        var callbackAction = callback;
        queryAction.setCallback(this, function(response){
            console.log('runExecMultiQuery: response received',response);
            
            if (response.getState() == "SUCCESS"){
                console.log('runExecMultiQuery: OK response received',response.getReturnValue());
                callback(response.getReturnValue(),null);
            } else {
                console.log('runExecMultiQuery: KO response received',response.getError());
                callback(null,response.getError());
            }
            console.log('runExecMultiQuery: END');
        });
        console.log('runExecMultiQuery: multiQueryAction set',queryAction);
                
        $A.enqueueAction(queryAction);
        console.log('runExecMultiQuery: multiQueryAction sent');
	}
})