({
	init: function (component, event, helper) {
        
        console.log("doInit START");
        
        let title = component.get("v.title");
        if ((title) && (title.includes('$Label.'))) {
            console.log('doInit: fetching title value for',title);
            title = $A.getReference(title) || title;
            console.log('doInit: title value fetched',title);
            component.set("v.title",title);
        }
        
        let tableActionStr = component.get("v.tableActionStr");
        console.log('doInit: tableActionStr retrieved',tableActionStr);      
        if (tableActionStr) {
           let tableActionJson = JSON.parse(tableActionStr);
           component.set("v.tableActionJson",tableActionJson);
           console.log('doInit: tableActionJson initialized',tableActionJson);
        } else {
           console.warn('doInit: tableActionJson not initialized');
        } 
  
        helper.fetchMapMarkers(component);
        helper.fetchOtherLocations(component);
        console.log("doInit END");
    },
    handleClick: function (component, event, helper) {
        console.log('handleclick', JSON.stringify(event.getParams()));   
    },
    refreshMap: function (component, event, helper) {
        console.log('refreshMap START');
        
        component.set("v.mapMarkers",[]);
        helper.fetchMapMarkers(component);
        helper.fetchOtherLocations(component);
        
        console.log('refreshMap END');
    },
    handleTableAction: function(component, event, helper) {
        console.log('handleTableAction: START');
        
        let selectedAction = event.getParams();
        console.log('handleTableAction: selectedAction from event',JSON.stringify(selectedAction));
        
        let selectedItem = component.get("v.selectedItem") || component.get("v.recordId");
        console.log('handleTableAction: selectedItem fetched',JSON.stringify(selectedItem));
        
        component.find('mergeUtil1').trigger(
            selectedAction.message.event,
            {"Id":selectedItem},
            null);
        
        console.log('handleTableAction: START');
    },
    handleSelect : function(component, event, helper) {
        console.log('handleSelect: START');
        
        let eventParams = event.getParams();
        console.log('handleSelect: event params ',JSON.stringify(eventParams));
        component.set("v.selectedRecordId", eventParams.selectedMarkerValue);
        console.log('handleSelect: END');
    },
    onPressKeyBoard : function(component, event, helper){
        
        console.log('onPressKeyBoard: START');

        //console.log('onPressKeyBoard: event', JSON.stringify(event.getParams()));
        
        let isEnterKey = event.keyCode === 13;
        console.log('onPressKeyBoard: keyCode',event.keyCode);
        if (isEnterKey) {
            console.log('onPressKeyBoard : filterList search string fetched',component.get('v.searchText'));
          helper.filterTheRecords(component);
        }
        console.log('onPressKeyBoard: END');
    },
    handleFilterOnClick : function(component, event, helper){
         
        helper.filterTheRecords(component);
    },
    navigateToRecord : function(component, event, helper){
        window.open('/' + component.get("v.selectedRecordId") ,'_blank');
        component.set("v.selectedRecordId", '');
    }
})