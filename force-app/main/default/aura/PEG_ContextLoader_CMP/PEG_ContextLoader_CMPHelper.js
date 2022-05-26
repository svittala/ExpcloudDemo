({
	performInit : function(component,event,helper) {
        console.log("performInit: START");

        let recordTypesStr = component.get("v.recordTypesStr");
        console.log("performInit: recordTypesStr fetched",recordTypesStr);
        if (recordTypesStr) {
            let recordTypesList = JSON.parse(recordTypesStr);
            console.log("performInit: recordTypesList parsed",recordTypesList);

            let rtFetchAction = component.get("c.getRecordTypeIDs");
    		rtFetchAction.setParams({"names":  recordTypesList });
	    	console.log('performInit: rtFetchAction params set ',JSON.stringify(rtFetchAction.getParams()));
        
    		rtFetchAction.setCallback(this, function(response){
            	console.log('performInit: rtFetchAction response received',response);
            
            	if (response.getState() == "SUCCESS"){
                	console.log('performInit: rtFetchAction OK response received ',JSON.stringify(response.getReturnValue()));
                    let contextMgr = component.find("contextMgr");
                    
					let context = contextMgr.getValue();
					if (context) {
				    	context.RT = response.getReturnValue();
					} else {
						context = {"RT" : response.getReturnValue()};
					}
					if (context.LV) context.isReady = true;
					contextMgr.setValue(context);
                	console.log('performInit: END --> context update with RT ',context);
        		} else {
            		console.warn('performInit: END --> KO rtFetchAction ',JSON.stringify(response.getError()));
                }
        	});
        	console.log('performInit: rtFetchAction set');
               
       		$A.enqueueAction(rtFetchAction);
        	console.log('performInit: rtFetchAction sent'); 
        }
        
        
        let listViewStr = component.get("v.listViewStr");
        console.log("performInit: listViewStr fetched",listViewStr);
 		if (listViewStr) {
            let listViewList = JSON.parse(listViewStr);
            console.log("performInit: listViewList parsed",listViewList);

			let lvFetchAction = component.get("c.getListViewIDs");
    		lvFetchAction.setParams({"names":  listViewList });
	    	console.log('performInit: lvFetchAction params set ',JSON.stringify(lvFetchAction.getParams()));
        
    		lvFetchAction.setCallback(this, function(response){
            	console.log('performInit: lvFetchAction response received',response);
            
            	if (response.getState() == "SUCCESS"){
                	console.log('performInit: lvFetchAction OK response received ',JSON.stringify(response.getReturnValue()));
                    let contextMgr = component.find("contextMgr");  
					let context = contextMgr.getValue();
					if (context) {
				    	context.LV = response.getReturnValue();
					} else {
						context = {"LV" : response.getReturnValue()};
					}
					if (context.RT) context.isReady = true;
					contextMgr.setValue(context);
                	console.log('performInit: END --> context update with LV ',context);
        		} else {
            		console.warn('performInit: END --> KO lvFetchAction ',JSON.stringify(response.getError()));
                }
        	});
        	console.log('performInit: lvFetchAction set');
               
       		$A.enqueueAction(lvFetchAction);
        	console.log('performInit: lvFetchAction sent'); 
        }
        
        console.log("performInit: END");
	}
})