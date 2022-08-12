({
	CONFIGURATION : {
            "base": {
                "iconName": "announcement",
                "iconVariant": "",
                "theme": "slds-theme_default",
                "textVariant":"slds-text-color_default"
            },
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
    setConfiguration : function (component,helper) {
        console.log('setConfiguration: START');

         //let newVariant = event.getParam("value");
        let variant = component.get("v.variant");
        console.log('setConfiguration: variant fetched',variant);
        
        if (helper.CONFIGURATION[variant]) {
            component.set("v.configuration",helper.CONFIGURATION[variant]);
            console.log('setConfiguration: configuration updated',helper.CONFIGURATION[variant]);
        }
        else {
           console.warn('setConfiguration: variant unsupported ',variant);
        }
        
        console.log('setConfiguration: END');       
    }, 
    setTitle  : function (component,helper) {
        console.log('setTitle: START');

        let title = component.get("v.title");
        console.log('setTitle: title fetched',title);
        
        if ((title) && (title.includes('$Label.'))) {
            console.log('setTitle: fetching custom label value for ',title);
            title = $A.getReference(title) || title;
            console.log('setTitle: custom label value fetched ',title);
            component.set("v.title",title);
        }
        
        console.log('setTitle: END');
    }, 
    setMessage  : function (component,helper) {
        console.log('setMessage: START');

        let message = component.get("v.message");
        console.log('setMessage: message fetched',message);
        
        if ((message) && (message.includes('$Label.'))) {
            console.log('setMessage: fetching custom label value for ',message);
            message = $A.getReference(message) || message;
            console.log('setMessage: custom label value fetched ',message);
            component.set("v.message",message);
        }
        
        console.log('setMessage: END');
    }
})