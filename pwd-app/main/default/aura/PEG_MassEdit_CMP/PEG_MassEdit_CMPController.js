({
	doInit : function(component, event, helper) {
		console.log("doInit START");
        
        console.log("doInit records",component.get("v.records"));
        
        let recordList = JSON.parse(component.get("v.records"));
        if ((recordList) && (recordList.length > 0)) {
            component.set("v.targetValues", {"Id":recordList[0].RecordTypeId});
            console.log("doInit targetValues",
                        JSON.stringify(component.get("v.targetValues")));
        }
        component.set("v.recordList", recordList);
        //console.log("doInit recordList",recordList);
        
        let fields = component.get("v.fields");
        console.log("doInit fields retrieved",fields);
        
        let message = {
            "title"   : recordList.length + ' records to update.',
            "severity": "info",
            "content" : "Set any of the " + fields.length
                      + " fields to be updated on all these records." 
        }
        component.set("v.message",message);
        console.log("doInit message set ",message);
        
        console.log("doInit END");
	},
    handleLoad : function(component, event, helper) {
        console.log('handleLoad START');
        /*
        let params = event.getParams();
        console.log('handleLoad event params',JSON.stringify(params));
        
        let fields = component.get("v.fields");
        console.log("doInit fields",component.get("v.fields"));
        
        fields.forEach(function(item) {
            console.log("doInit resetting fields",item);
            let fieldVal = component.find('field-' + item);
            console.log("doInit fieldVal",JSON.stringify(fieldVal));
            //fieldVal = {};
        });
        */
        /*
        fields.forEach(function(item) {
            console.log("doInit resetting fields",item);
            let fieldVal = params.recordUi.record.fields[item];
            console.log("doInit fieldVal",JSON.stringify(fieldVal));
            fieldVal = {};
        });
        console.log("doInit event fields updated",JSON.stringify(params.recordUi.record.fields));

        console.log("doInit event",event);
        event.setParams(params);
        */        
        console.log('handleLoad END');
    },
    handleSubmit : function(component, event, helper) {
        console.log('handleSubmit START');
        
        let params = event.getParams(); 
        console.log('handleSubmit event params',JSON.stringify(params));
        
        let recordList = component.get("v.recordList");
        console.log('handleSubmit recordList fetched',JSON.stringify(recordList));
                                                                       
        let targetValues = component.get("v.targetValues");
        console.log('handleSubmit targetValues fetched',JSON.stringify(targetValues));

        event.preventDefault();
        //$A.get('e.force:refreshView').fire();
        /*
        let fields = component.get("v.fields");
        console.log("doInit fields",component.get("v.fields"));
        
        fields.forEach(function(item) {
            console.log("doInit resetting fields",item);
            let fieldVal = component.find('field-' + item).get("v.fieldName");
            console.log("doInit fieldVal",JSON.stringify(fieldVal));
            //fieldVal = {};
        });
        */
        helper.execMassUpdate(component,recordList, params.fields);
        //component.find("overlayLibrary").notifyClose();
        
        console.log('handleSubmit END');
    },
    handleFieldChange : function(component, event, helper) {
        console.log('handleFieldChange START');
        
        //let eventParams = event.getParams();
        //console.log('handleSubmit event params',JSON.stringify(eventParams));      
        
        //let eventSource = event.getSource();
        //console.log('handleSubmit event source',JSON.stringify(eventSource));      
        
        let fieldName = event.getSource().get("v.fieldName");
        console.log('handleFieldChange fieldName',fieldName);      
        
        let fieldValue = event.getParams().value;
        console.log('handleFieldChange fieldValue',fieldValue);
        
        let targetValues = component.get("v.targetValues");
        targetValues[fieldName] = fieldValue;
        component.set("v.targetValues",targetValues);
        console.log('handleFieldChange targetValues updated',targetValues);
        
        console.log('handleFieldChange END');
    },
    cancelOperation : function(component, event, helper) {
        console.log('cancelOperation START');
        
        console.log('cancelOperation: closing popup');
        event.preventDefault();
        
        component.find("overlayLibrary").notifyClose();
        
        // @TBD Does not work.... to be further investigated.
        // console.log('cancelOperation: refreshing view');
        // $A.get('e.force:refreshView').fire();
        
        console.log('cancelOperation END');
    }
})