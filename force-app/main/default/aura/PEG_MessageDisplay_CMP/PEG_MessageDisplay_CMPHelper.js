({
	CONFIGURATION : {
        "strong": {
            "info": {
                "iconName": "info_alt",
                "iconVariant": "inverse",
                "theme": "slds-theme_info",
                "textVariant":"slds-text-color_inverse"
            },
            "warning": {
                "iconName": "warning",
                "iconVariant": "warning",
                "theme": "slds-theme_warning",
                "textVariant":"slds-text-color_inverse"
            },
            "error": {
                "iconName": "error",
                "iconVariant": "inverse",
                "theme": "slds-theme_error",
                "textVariant":"slds-text-color_inverse"
            },
            "success": {
                "iconName": "success",
                "iconVariant": "inverse",
                "theme": "slds-theme_success",
                "textVariant":"slds-text-color_inverse"
            }
        },
        "light": {
            "info": {
                "iconName": "info_alt",
                "iconVariant": "",
                "theme": "slds-theme_default",
                "textVariant":"slds-text-color_default"
            },
            "warning": {
                "iconName": "warning",
                "iconVariant": "warning",
                "theme": "slds-theme_default",
                "textVariant":"slds-text-color_error"
            },
            "error": {
                "iconName": "error",
                "iconVariant": "error",
                "theme": "slds-theme_default",
                "textVariant":"slds-text-color_error"
            },
            "success": {
                "iconName": "success",
                "iconVariant": "success",
                "theme": "slds-theme_default",
                "textVariant":"slds-text-color_success"
            }
        }
    },
    setConfiguration : function (component,helper) {
        console.log('setConfiguration: START');

         //let newVariant = event.getParam("value");
        let newVariant = component.get("v.variant");
        console.log('setConfiguration: newVariant fetched',newVariant);
        let theme = component.get("v.theme");
        console.log('setConfiguration: theme fetched',theme);
        
        if ((helper.CONFIGURATION[theme]) && (helper.CONFIGURATION[theme][newVariant])) {
            component.set("v.configuration",helper.CONFIGURATION[theme][newVariant]);
            console.log('setConfiguration: configuration updated',helper.CONFIGURATION[theme][newVariant]);
        }
        else {
           console.warn('setConfiguration: variant unsupported ',newVariant);
        }
        
        console.log('setConfiguration: END');       
    }, 
    setErrorMessage  : function (component,helper) {
        console.log('setErrorMessage: START');

        let error = component.get("v.error");
        console.log('setErrorMessage: error fetched',error);
        
        let errorMessage = '';
        if (error) {
            errorMessage = helper.parseError(helper,error);
            console.log('setErrorMessage: new error message generated ',errorMessage); 
        }
        else {
            console.log('setErrorMessage: no error message to set');             
        }
        component.set("v.errorMessage",errorMessage);
        
        console.log('setErrorMessage: END');
    },
    parseError : function (helper,error) {
        //console.log("parseError START with", JSON.stringify(error));
        let errorMessage = '';
        
        if (! error) {
            //console.log("parseError END no error");
            return '';
        }
        if (typeof error != 'object') {
            //console.log("parseError END no object");
            return '';
        }
        
        if (error.constructor === [].constructor) {
            console.log("parseError : processing error list");
            error.forEach(function(errorItem){
                //console.log("parseError : processing error item",errorItem);
                errorMessage += helper.parseError(helper,errorItem) + '\n';
            });
        }
        else {
            console.log("parseError : processing error object");
            if (error["message"]) {
                //console.log("parseError : message field found");
                errorMessage += error["message"] + '\n';
            }
            for (var fieldItem in error) {
                //console.log("parseError : processing fieldItem",fieldItem);
                if ((error[fieldItem]) && ((error[fieldItem]).constructor === [].constructor)) {
                    console.log("parseError : propagating to list fieldItem");
                    errorMessage += helper.parseError(helper,error[fieldItem]);
                }
            }
            errorMessage = errorMessage.slice(0,-1);
        }
        
        //console.log("parseError END with", errorMessage);
        return errorMessage;
    }
})