({
	doInit : function(component, event, helper) {
        console.log('doInit START');
        
        let title = component.get("v.title");
        if ((title) && (title.includes('$Label.'))) {
            console.log('doInit: fetching title value for',title);
            title = $A.getReference(title) || title;
            console.log('doInit: title value fetched',title);
            component.set("v.title",title);
        }
        
        let fieldStr = component.get("v.fieldStr");
        console.log('doInit fieldStr fetched', fieldStr);
        
        if (fieldStr) {
            let fieldJson = JSON.parse(fieldStr);
            component.set("v.fieldJson",fieldJson);
            console.log('doInit fieldJson set', fieldJson);
        } else {
            console.warn('doInit missing fieldStr attribute');
        }
        
        let useLDS = component.get("v.useLDS");
        if (useLDS) {
            console.log('doInit using LDS to fetch data');
        } else {
            console.log('doInit using SOQL to fetch data');
            helper.fetchData(component,helper);
        }
        console.log('doInit END');
	},
    refreshData : function(component, event, helper) {
        console.log('refreshData START');
        component.set("v.showTabs",false);
        helper.fetchData(component,helper);
        console.log('refreshData END');
    }
})