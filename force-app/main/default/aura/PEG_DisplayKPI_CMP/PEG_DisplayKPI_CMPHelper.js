({
/***
* @author P-E GROS
* @date   Mar. 2020
*
* Legal Notice
* This code is the property of Salesforce.com and is protected by U.S. and International
* copyright laws. Reproduction, distribution without written permission of Salesforce is
* strictly prohibited. In particular this code has been delivered by Salesforce.com for
* its Client’s internal purposes pursuant to specific terms and conditions, and cannot be
* re-used, reproduced or distributed for any other purposes.
***/
    KPI_MAP : {
    	"smiley" : {"min":{"icon":"utility:sentiment_negative","variant":"warning"},
                	"avg":{"icon":"utility:sentiment_neutral","variant":""},
                	"max":{"icon":"utility:emoji","variant":"success"}},
    	"arrows" : {"min":{"icon":"utility:arrowdown","variant":"warning"},
                	"avg":{"icon":"utility:forward","variant":"light"},
                	"max":{"icon":"utility:arrowup","variant":"success"}},
    	"rating" : {"min":{"icon":"utility:warning","variant":"warning"},
                	"avg":{"icon":"utility:info_alt","variant":"light"},
                	"max":{"icon":"utility:success","variant":"success"}},
    	"thumb" :  {"min":{"icon":"utility:dislike","variant":"warning"},
                	"avg":{"icon":"utility:info_alt","variant":"light"},
                	"max":{"icon":"utility:like","variant":"success"}},
    	"trend":   {"min":{"icon":"trend","variant":"down"},
                  	"avg":{"icon":"trend","variant":"neutral"},
                  	"max":{"icon":"trend","variant":"up"}},
        "strength":{"avg":{"icon":"strength"}}
	},
	performInit : function(component,helper) {
        console.log('performInit: START');
        
        let title = component.get("v.title");
        console.log('performInit: title fetched',title);
        if ((title) && (title.includes('$Label.'))) {
            console.log('performInit: fetching custom label value for ',title);
            title = $A.getReference(title) || title;
            console.log('performInit: custom label value fetched ',title);
            component.set("v.title",title);
        }
        
        let fieldList = [];
        let kpiField = component.get("v.kpiField");
        if ((kpiField) && (kpiField != "N/A")){
            fieldList.push(kpiField);
            console.log('performInit: kpiField added in fieldList',kpiField);
        }
        else {
            console.error('performInit: missing kpiField',kpiField);
        }
        
        let labelField = component.get("v.labelField");
        if ((labelField) && (labelField != "N/A")){
            fieldList.push(labelField);
            console.log('performInit: labelField added in fieldList',labelField);
        }
        else {
            console.warn('performInit: no labelField',labelField);
        }
        
        let displayData = {
            kpiValue : null,
            kpiFormat : null,
            kpiClass : null,
            icon : null,
            variant : null,
            labelValue : null,
            iconConfig : null
        };
        let mode = component.get("v.mode");
        console.log('performInit: mode fetched',mode);
        if (mode) {
            displayData.iconConfig = helper.KPI_MAP[mode];
            console.log('performInit: iconConfig set',displayData);            
        }
        else {
            console.error('performInit: missing mode');
        }
        component.set("v.displayData",displayData);
        
        component.set("v.fieldList",fieldList);
        
        // triggering LDS
        component.set("v.fieldList",fieldList);
        
        console.log('performInit: END');
    },
    updateData : function(component,helper,recordChanges) {
        console.log("updateData: START");

        let recordFields = component.get("v.recordFields");
        console.log("updateData: recordFields fetched",JSON.stringify(recordFields));  
        let fieldList = component.get("v.fieldList");
        console.log("updateData: fieldList fetched",JSON.stringify(fieldList));
        
        if (recordChanges) {
            console.log("updateData: processing Update event");
            for (let change in recordChanges) {
            	if (fieldList.includes(change)) {
                	console.log("updateData : updating field change",change);
                	recordFields[change] = recordChanges[change].value;
            	} else {
                    console.log("updateData : ignoring field change",change);
            	}
        	}
        	console.log("updateData: recordFields updated",JSON.stringify(recordFields));
			component.set("v.recordFields",recordFields);
        }
        else {
            console.log("updateData: processing Load event");
            component.set("v.isReady",true);
        }
        
        let kpiField 	= component.get("v.kpiField");
        console.log("updateData: kpiField fetched",kpiField);
        let labelField	= component.get("v.labelField");
        console.log("updateData: labelField fetched",labelField);
        let kpiFormat 	= component.get("v.kpiFormat");
        console.log("updateData: letkpiFormat fetched",kpiFormat);
        
        let displayData = component.get("v.displayData");
        console.log("updateData: displayData fetched",JSON.stringify(displayData));

        let minValue 	= component.get("v.minValue");
        console.log("updateData: minValue fetched",minValue);
        let maxValue	= component.get("v.maxValue");
        console.log("updateData: maxValue fetched",maxValue);
        let isInverse	= component.get("v.isInverse");
        console.log("updateData: isInverse fetched",isInverse);
        
        displayData.kpiValue   = (recordFields[kpiField] || 0) / (kpiFormat === 'percent' ? 100 : 1);
        displayData.labelValue = recordFields[labelField];
        
        if (displayData.iconConfig) {
            console.log('updateData: updating icon');
            if (displayData.iconConfig.avg.icon === 'strength') {
            	console.log('updateData: updating strength icon');
            	let strength =  Math.round((7.1 * (displayData.kpiValue - minValue) / (maxValue - minValue)) - 3.5);
            	if (strength > 3)  strength = 3;
            	if (strength < -3) strength = -3;
            	displayData.icon = "strength";
                displayData.variant = '' + (isInverse ? -strength : strength);
                //component.set("v.variant",isInverse ? '-'&strength : ''&strength);
            }
            else {
            	console.log('updateData: updating other icon');
                let tmpIconConfig = displayData.iconConfig.avg;
                if (displayData.kpiValue < minValue) tmpIconConfig = isInverse ? displayData.iconConfig.max : displayData.iconConfig.min;
        		if (displayData.kpiValue > maxValue) tmpIconConfig = isInverse ? displayData.iconConfig.min : displayData.iconConfig.max;
				displayData.icon = tmpIconConfig.icon;
                displayData.variant = tmpIconConfig.variant;
            }
        }
        else {
            console.log('updateData: no icon to update (ring display)');
            displayData.kpiRatio = Math.round(100 * (displayData.kpiValue - minValue) / (maxValue - minValue)); 
            if (displayData.kpiRatio < 0)	displayData.kpiRatio =  0;
            if (displayData.kpiRatio > 100) displayData.kpiRatio =  100;

            displayData.variant = "active-step";
            if (displayData.kpiRatio <= 30) displayData.variant = isInverse ? "base-autocomplete" : "warning";
            if (displayData.kpiRatio <= 10) displayData.variant = isInverse ? "base-autocomplete" : "expired";
            if (displayData.kpiRatio >= 70) displayData.variant = isInverse ? "warning" : "base-autocomplete";
            if (displayData.kpiRatio >= 90) displayData.variant = isInverse ? "expired" : "base-autocomplete";
        }

        console.log("updateData: displayData updated",JSON.stringify(displayData));
		component.set("v.displayData",displayData);
                
        console.log("updateData END");
	}
})