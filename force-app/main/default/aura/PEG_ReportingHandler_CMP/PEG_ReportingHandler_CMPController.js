({
    doInit : function(component, event, helper) {
        console.log('doInit: START');
        
        let workspaceUtil = component.find("workspaceUtil");
        console.log('doInit: workspaceUtil',workspaceUtil);
         
        workspaceUtil.isConsoleNavigation().then(function(consoleMode) {
            console.log('doInit: console mode',consoleMode);
            component.set("v.isConsole",consoleMode);
        }).catch(function(error){
            console.error('doInit: workspaceUtil error',JSON.stringify(error));  
        }); 
        
        console.log('doInit: END');
    },
    handleMessage : function(component, event, helper) {
        console.log('handleMessage: START');
        
        //console.log('handleMessage: event',event);
        //console.log('handleMessage: event source',event.getSource());
        //console.log('handleMessage: event source global ID',event.getSource().getGlobalId());
        //console.log('handleMessage: event source name',event.getSource().getName());
        //let eventSourceId = event.getSource().getGlobalId();
        //console.log('handleMessage: eventSourceId fetched',eventSourceId);
        
        let channel = event.getParam('channel');
        console.log('handleMessage: event channel received',channel);
		
        let message = event.getParam('message');
        console.log('handleMessage: event message received',JSON.stringify(message));
        
        let isConsole = component.get("v.isConsole");
        console.log('handleMessage: isConsole fetched',isConsole);
        
        if (isConsole) {
            let workspaceUtil = component.find("workspaceUtil");
            console.log('handleMessage: workspaceUtil',workspaceUtil);
            
            workspaceUtil.getFocusedTabInfo().then(function(tabInfo){
               console.log('handleMessage: current tabInfo fetched',JSON.stringify(tabInfo));
            }).catch(function(error){
               console.error('handleMessage: workspaceUtil error',JSON.stringify(error));  
            }); 
        }
        
        switch (channel) {
            case 'PEG_OpenComponent' :
                console.log('handleMessage: navigating to component');
                let navService = component.find("navService");
                let pageReference = message;
                console.log('handleMessage: pageReference fetched',JSON.stringify(pageReference));
                //event.preventDefault();
                navService.navigate(pageReference,true);
                console.log('handleMessage: navigation triggered');
                break;
            case 'PEG_QuickAction' :
                console.log('handleMessage: opening Quick Action');
                
                let actionAPI = component.find("quickActionAPI");
                actionAPI.getAvailableActions().then(function(result1){
                    console.log('handleMessage: Quick Action actions available',
                                 JSON.stringify(result1));
                }).catch(function(e){
                    if(e.errors){
                        console.log('handleMessage: Quick Action List error',e.errors);
                    }
                });
                
                actionAPI.selectAction(message).then(function(result){
                    console.log('handleMessage: Quick Action opened',
                                JSON.stringify(result));
                }).catch(function(e){
                    if(e.errors){
                        console.log('handleMessage: Quick Action open error',e.errors);
                    }
                });
                break;
            case 'PEG_PopUp' :
                console.log('handleMessage opening PopUp');
                
                $A.createComponent(message.name, message.params,
                   function(content, status) {
                     if (status === "SUCCESS") {
                         console.log('handleMessage: component create OK');
                         var overlayLib = component.find("overlayLib");
                         overlayLib.showCustomModal({
                                  header: message.header,
                                  body: content, 
                                  showCloseButton: true,
                                  cssClass: content.class || 'slds-modal slds-fade-in-open slds-slide-down-cancel',
                                  closeCallback: function() {
                                      /*console.log('handleShowModal: showCustomModal closed');
                                      let callbackEvent = $A.get("e.ltng:sendMessage"); 
 									  callbackEvent.setParams({
                                        "message": {"sourceId":eventSourceId,
                                                    "callback":message.callback}, 
          								"channel": "PEG_Callback" 
    								  }); 
                                      console.log('handleShowModal: callbackEvent prepared',callbackEvent);
 									  callbackEvent.fire();
                                      
                                      console.log('handleShowModal: callbackEvent fired');*/
                                      $A.get('e.force:refreshView').fire();
                                      console.log('handleShowModal: refresh fired');
                                  }
                         });
                         console.log('handleShowModal: showCustomModal done');
                     } else {
                         console.log('handleShowModal: component create KO');
                     }
                });
                break;
            case 'PEG_ActionPlan' :
                console.log('handleMessage: opening ActionPlan');
                message.type = 'Object';
                
                let contextMgr = component.find("contextMgr");
                let context    = contextMgr.getValue();
                console.log('handleMessage: context fetched',JSON.stringify(context));
                context.selection = message.selection;
                contextMgr.setValue(context);
                console.log('handleMessage: context updated',JSON.stringify(context));

                helper.openObject(message,component);
                break;
            case 'PEG_Object' :
                console.log('handleMessage: opening Object');
                message.type = 'Object';
                helper.openObject(message,component);
                break;
            case 'PEG_Analytics' :
                console.log('handleMessage: opening Analytics Dashboard');
                message.type = 'Analytics';
                helper.openAnalytics(message,component);
                break;
            case 'PEG_Report' :
                console.log('handleMessage: opening standard Report');
                message.type = 'Report';
                helper.openReport(message,component);
                break;
            case 'PEG_Dashboard' :
                console.log('handleMessage: opening standard Dashboard');
                message.type = 'Dashboard';
                helper.openDashboard(message,component);
                break;
            default:
                console.log('handleMessage: ignored event');
        }
        
        console.log('handleMessage END');
	}
})