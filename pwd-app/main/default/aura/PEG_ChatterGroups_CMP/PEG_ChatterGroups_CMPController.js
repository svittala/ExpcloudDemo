({
    doInit : function(component, event, helper) {
        console.log('doInit START');
        helper.initialize(component,helper);
        console.log('doInit END');
    },
    selectChange : function(component, event, helper) {
        console.log('selectChange START');
        helper.updateFeed(component,event);
        console.log('selectChange END');
    },
    openGroup : function(component, event, helper) {
        console.log('openGroup START');
        helper.navigateToGroup(component);
        console.log('openGroup END');
    }
})