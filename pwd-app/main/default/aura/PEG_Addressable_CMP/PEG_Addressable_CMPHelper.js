({
	initComponent : function(component,event,helper) {
        console.log('initComponent: START');
        
		let pageReference = component.get("v.pageReference");
        console.log('initComponent: pageReference fetched',JSON.stringify(pageReference));
        
        let state = pageReference.state;
        console.log('initComponent: state fetched',JSON.stringify(state));
        
        var wkAPI = component.find("workspaceUtil");
        console.log('initComponent: wkAPI',wkAPI);
        
        
        wkAPI.isConsoleNavigation().then(function(consoleMode) {
            console.log('initComponent: console mode',consoleMode);
            if (consoleMode) return wkAPI.getEnclosingTabId();
        }).then(function(tabId){
            console.log('initComponent: tab ID fetched',tabId);
            return wkAPI.setTabLabel(
                {"tabId": tabId,
                 "label": state.c__label || 'TAB' });
        }).then(function(tabInfo){
            console.log('initComponent: tab renamed',tabInfo);
        }).catch(function(error) {
            console.error('initComponent: error raised',JSON.stringify(error));
        });
        
        /*
        wkAPI.isConsoleNavigation().then(function() {
        wkAPI.getEnclosingTabId().then(function(tabId) {
            console.log('initComponent: tab ID fetched',tabId);
            return workspaceAPI.setTabLabel(
                {"tabId":tabId,
                 "label": state.c__label || 'TAB' });
        }).then(function(tabInfo){
            console.log('initComponent: tab renamed',tabInfo);
        }).catch(function(error) {
            console.error('initComponent: error catched',error);
        });*/
        
        if (! state.c__component) {
            console.error('initComponent: missing component name');
            helper.displayError(component,
                          'Initialization failure: '
                          + 'Missing component name');
            return;
        }
            
        if (state.c__configuration) {
            console.log('initComponent: fetching config',state.c__configuration);
            component.find('soqlUtil').runQuery(
                "SELECT Parameters__c FROM PEG_Configuration__mdt WHERE DeveloperName = '"
                        + state.c__configuration + "' WITH SECURITY_ENFORCED",
                true, false, "DEV",
                true, false,
                function(soqlResult,soqlError) {
                   console.log('initComponent: result from query');
                   if (soqlResult) {
                       console.log('initComponent: soqlResult received',soqlResult);
                       let configuration = JSON.parse(soqlResult[0].Parameters__c);
                       console.log('initComponent: configuration extracted',configuration);                      
                       let context = Object.assign({},state.c__context || {});
                       console.log('initComponent: context init',JSON.stringify(context));
                       context = Object.assign(context, configuration);
                       console.log('initComponent: context updated',JSON.stringify(context));
                       helper.createTarget(component,helper,state.c__component,context);
                   } else {
                       console.error('initComponent: soqlError received',JSON.stringify(soqlError));
                       helper.displayError(component,
                          'Initialization failure (SOQL): '
                          + JSON.stringify(soqlError));
                   }
                }
            );
        } else {
            console.log('initComponent: no config fetch required');
            helper.createTarget(component,helper,state.c__component,state.c__context);
        }
        
        //pageReference.status = {};
        //component.set("v.pageReference",pageReference);
        
        console.log('initComponent: END');
	},
    createTarget : function(component,helper,targetComponent,targetParameters) {
        console.log('createTarget: START');
        
        console.log('createTarget: creating component',targetComponent);
        console.log('createTarget: with parameters',JSON.stringify(targetParameters));
        $A.createComponent(targetComponent, targetParameters,
           function(content, status) {
               if (status === "SUCCESS") {
                   console.log('createTarget component create OK');
                   component.set('v.body',content);
               } else {
                   console.error('createTarget component create KO');
                   helper.displayError(component,
                      'Initialization failure: '
                      + status );
               }
           }
        );                
        console.log('createTarget: END');
    },
    displayError : function(component,message) {
        console.log('displayError: START');
        
        $A.createComponent(
            "aura:html",
            {
                "tag": "div",
                "HTMLAttributes" :{"class": "slds-box slds-theme_default slds-text-color_error"},
                "body": message
            },
            function(errorCmp){
              console.log('displayError: error component built');
              //let body = component.get("v.body");
              //body.push(compo);
              component.set("v.body", errorCmp);
            }
        );
        console.log('displayError: END');
    }
})