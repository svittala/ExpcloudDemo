({
    TABS_TO_CLOSE : {},
    TABS_TO_FOCUS : {},
    processInit : function(component) {
        console.log('processInit: START');
        let wkspUtil = component.find("wkspUtil");
        //console.log('processInit: wkspUtil fetched',wkspUtil);
        wkspUtil.isConsoleNavigation()
        .then(function(consoleMode) {
            component.set("v.isConsole",consoleMode);
            console.log('processInit: END / console mode set ',consoleMode);
        }).catch(function(error){
            console.error('processInit: END / isConsoleNavigation error ',JSON.stringify(error));  
        });         
        console.log('processInit: temporary end');	
	},
    processTabOpen: function(component, event, helper) {
        console.log('processTabOpen: START');
        
        let isConsole = component.get("v.isConsole");
        console.log('processTabOpen: isConsole fetched ',isConsole);
        let sourceId = event.getParam('sourceId');
        console.log('processTabOpen: sourceId extracted ',sourceId);
        let targetId = event.getParam('targetId');
        console.log('processTabOpen: targetId extracted ',targetId);
        
        if (isConsole) {
            // ### CONSOLE MODE ###
            console.log('processTabOpen: operating in console mode');
            /*
            if (sourceId) {
        		console.log('processTabOpen: regitering tab to close ',sourceId);
            	helper.TABS_TO_CLOSE[sourceId] = true;
        	}
            */
            let wkspUtil = component.find("wkspUtil");
        	//console.log('processInit: wkspUtil fetched',wkspUtil);
        	wkspUtil.openTab({
                recordId: targetId,
                focus: true,
                overrideNavRules: false
            }).then(function(newTabId){
                console.log('processTabOpen: new tab opened ',newTabId);
                helper.TABS_TO_FOCUS[newTabId] = true;
                console.log('processTabOpen: TABS_TO_FOCUS updated ',JSON.stringify(helper.TABS_TO_FOCUS));
                if (sourceId) {
                    console.log('processTabOpen: closing old tab ',sourceId);
                    wkspUtil.closeTab({tabId: sourceId})
            		.then(function(status){
                		console.log('processTabOpen: END / previous tab closed ',status);
            		}).catch(function(error){
            			console.error('processTabOpen: END / closeTab error ',JSON.stringify(error));  
        			});
                }
                else {
                    console.log('processTabOpen: END / no old tab to close ');
                }
            }).catch(function(error){
            	console.error('processTabOpen: END / openTab error ',JSON.stringify(error));  
        	});
        	console.log('processTabOpen: temporary end');
        }
        else {
            // ### STANDARD MODE ###
            console.log('processTabOpen: operating in standard mode');
            let navService = component.find("navService");
        	//console.log('processTabOpen: navService fetched',navService);
            let pageRef = {
                "type": "standard__recordPage",
                "attributes": {
                    "recordId": targetId,
                    "actionName": "view"
                }
            };
            console.log('processTabOpen: target pageRef prepared ', pageRef);
            navService.navigate(pageRef);
            console.log('processTabOpen: END');
        }
    },
    processTabFocus : function(component, event, helper) {
        console.log('processTabFocus: START');
        console.log('processTabFocus: event params ', JSON.stringify(event.getParams()));
        let previousTabId = event.getParam('previousTabId');
        console.log('processTabFocus: previousTabId extracted ',previousTabId);
        
        //console.log('processTabFocus: TABS_TO_CLOSE fetched ',JSON.stringify(helper.TABS_TO_CLOSE));
        console.log('processTabFocus: TABS_TO_FOCUS fetched ',JSON.stringify(helper.TABS_TO_FOCUS));
        
        /*
        if (helper.TABS_TO_CLOSE[previousTabId]) {
        	console.log('processTabFocus: previousTabId to close');
            delete helper.TABS_TO_CLOSE[previousTabId];
        	console.log('processTabFocus: TABS_TO_CLOSE updated ',JSON.stringify(helper.TABS_TO_CLOSE));
            let wkspUtil = component.find("wkspUtil");
        	//console.log('processInit: wkspUtil fetched',wkspUtil);
        	wkspUtil.closeTab({tabId: previousTabId})
            .then(function(status){
                console.log('processTabFocus: END / previous tab closed ',status);
            }).catch(function(error){
            	console.error('processTabFocus: closeTab error ',JSON.stringify(error));  
        	});
        }
        */
        if (helper.TABS_TO_FOCUS[previousTabId]) {
        	console.log('processTabFocus: previousTabId to refocus');
            delete helper.TABS_TO_FOCUS[previousTabId];
        	console.log('processTabFocus: TABS_TO_FOCUS updated ',JSON.stringify(helper.TABS_TO_FOCUS));
            let wkspUtil = component.find("wkspUtil");
        	//console.log('processInit: wkspUtil fetched',wkspUtil);
        	wkspUtil.focusTab({tabId: previousTabId})
            .then(function(status){
                console.log('processTabFocus: END / previous tab focused ',status);
            }).catch(function(error){
            	console.error('processTabFocus: END / focusTab error ',JSON.stringify(error));  
        	});
        }
        console.log('processTabFocus: END');	
	}
})