({
	doRunQuery : function(component, event, helper) {
        console.log('doRunQuery: START');
        
        var methodArg = event.getParam('arguments');
        console.log('doRunQuery: methodArg fetched',JSON.stringify(methodArg));
        console.log('doRunQuery: methodArg.queryString fetched',JSON.stringify(methodArg.queryString));
        
        if (! methodArg.queryString) {
            console.error('doRunQuery: missing queryString arguments',JSON.stringify(methodArg));
            component.find('notifLib').showNotice({
              "variant": "error",
              "header": "Missing argument for SOQL query !",
              "message": "QueryString parameter is missing in SOQL runQuery() method."
            });
            return;
        }
        if (! methodArg.callback) {
            console.error('doRunQuery: missing callback arguments',JSON.stringify(methodArg));
            component.find('notifLib').showNotice({
              "variant": "error",
              "header": "Missing argument for SOQL query !",
              "message": "Callback parameter is missing in SOQL runQuery() method."
            });
            return;
        }

        helper.runExecQuery(component,
                            methodArg.queryString,
                            methodArg.bypassFLS,
                            methodArg.bypassSharing,
                            methodArg.queryType,
                            methodArg.isStorable,
                            methodArg.isBackground,
                            methodArg.callback);
        
        console.log('doRunQuery: END');
    },
    doRunDML : function(component, event, helper) {
        console.log('doRunDML: START');
        
        var methodArg = event.getParam('arguments');
        console.log('doRunDML: methodArg fetched',JSON.stringify(methodArg));
        
        if (! methodArg.dmlOperation) {
            console.error('doRunDML: missing dmlOperation arguments',JSON.stringify(methodArg));
            component.find('notifLib').showNotice({
              "variant": "error",
              "header": "Missing argument for DML operation !",
              "message": "dmlOperation parameter is missing in runDML() method."
            });
            return;
        }
        if ((! methodArg.itemList) || (methodArg.itemList.length < 1)) {
            console.error('doRunDML: missing dmlOperation arguments',JSON.stringify(methodArg));
            component.find('notifLib').showNotice({
              "variant": "error",
              "header": "Missing argument for DML operation !",
              "message": "itemList parameter is missing in runDML() method."
            });
            return;
        }
        if (! methodArg.callback) {
            console.error('doRunDML: missing callback arguments',JSON.stringify(methodArg));
            component.find('notifLib').showNotice({
              "variant": "error",
              "header": "Missing argument for DML operation !",
              "message": "Callback parameter is missing in SOQL runDML() method."
            });
            return;
        }

        helper.runExecDML(component,
                          methodArg.dmlOperation,
                          methodArg.itemList,
                          methodArg.callback);
        
        console.log('doRunDML: END');
    },
    // Work in Progress
    doRunMultiQuery : function(component, event, helper) {
        console.log('doRunMultiQuery: START');
        
        var methodArg = event.getParam('arguments');
        console.log('doRunMultiQuery: methodArg fetched',JSON.stringify(methodArg));
        
        if (! methodArg.queryList) {
            console.error('doRunMultiQuery: missing queryList arguments',JSON.stringify(methodArg));
            component.find('notifLib').showNotice({
              "variant": "error",
              "header": "Missing argument for SOQL queries !",
              "message": "QueryList parameter is missing in SOQL runQuery() method."
            });
            return;
        }
        if (! methodArg.callback) {
            console.error('doRunMultiQuery: missing callback arguments',JSON.stringify(methodArg));
            component.find('notifLib').showNotice({
              "variant": "error",
              "header": "Missing argument for SOQL query !",
              "message": "Callback parameter is missing in SOQL runMultiQuery() method."
            });
            return;
        }

        helper.runExecMultiQuery(component,
                            methodArg.queryList,
                            methodArg.isStorable,
                            methodArg.isBackground,
                            methodArg.callback);
        
        console.log('doRunMultiQuery: END');
    }
})