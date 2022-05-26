({
	 invoke : function(component, event, helper) {
		var redirectURL = "https://uacdev2.apincloud.com/UACMain.aspx";
            //component.get("v.redirectURL");
        var redirect = $A.get("e.force:navigateToURL");
        redirect.setParams({
            "url": redirectURL
        });
        redirect.fire();
	}
})