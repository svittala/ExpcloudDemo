({
	doInit : function(component, event, helper) {
        console.log('doInit: START');
         
        let contextMgr = component.find("contextMgr");
        //component.set('v.isLeftOpen',false);
        
        //log('doInit: window location',window.location);
        //console.log('doInit: window location href',window.location.href);
        //let urlParts = (window.location.href).split('/');
        //console.log('doInit: window urlParts extracted',urlParts);
        //let sObjectName = (window.location.href).match(/.*[or]\/(.)*\/.*/g);
        //console.log('doInit: window sObjectName extracted',urlParts[5]);
        //component.set("v.objName",urlParts[5]);*/
        
        let context = contextMgr.getValue();
        console.log('doInit PLA context fetched',JSON.stringify(context));
        
        if (context.template) {
            component.set('v.isLeftOpen',context.template.isLeftOpen);
            component.set('v.isRightOpen',context.template.isRightOpen);
            console.log('doInit isXXXX set');
        }
        
        console.log('doInit: END');
	},
    handleOpenClose : function(component, event, helper){
        console.log('handleOpenClose: START');
        
        console.log('handleOpenClose: event.getSource()',event.getSource());
        var selectedSection = event.getSource().getLocalId();
        console.log('handleOpenClose: selectedSection',selectedSection);
        
        var newState = !component.get('v.' + selectedSection);
        console.log('handleOpenClose: newState',newState);
        component.set('v.' + selectedSection, newState);
        
        /*let middle = component.get("v.middle");
        console.log('handleOpenClose: middle',middle);
        console.log('handleOpenClose: middle keys',middle.ownKeys(null));
        */
        console.log('handleOpenClose: END');
	}
})