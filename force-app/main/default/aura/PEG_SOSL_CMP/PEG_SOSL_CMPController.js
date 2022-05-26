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
              "header": "Missing argument for SOSL query !",
              "message": "QueryString parameter is missing in SOSL runQuery() method."
            });
            return;
        }
        if (! methodArg.callback) {
            console.error('doRunQuery: missing callback arguments',JSON.stringify(methodArg));
            component.find('notifLib').showNotice({
              "variant": "error",
              "header": "Missing argument for SOSL query !",
              "message": "Callback parameter is missing in SOSL runQuery() method."
            });
            return;
        }

        helper.runExecQuery(component,
                            methodArg.queryString,
                            methodArg.isStorable,
                            methodArg.isBackground,
                            methodArg.callback);
        
        console.log('doRunQuery: END');
    }
})