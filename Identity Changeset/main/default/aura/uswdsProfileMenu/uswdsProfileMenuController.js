({
  doInit: function (component, event, helper) {
    var userId = $A.get("$SObjectType.CurrentUser.Id");
    var userName = $A.get("$SObjectType.CurrentUser.UserName");
    if (userId) {
      component.set("v.loggedIn", true);
      component.set("v.user", userName);
    }
  },
  handleMenuSelect: function (component, event, helper) {
    console.log("handling menu select");
    var selectedMenuItemValue = event.getParam("value");
    if (selectedMenuItemValue) {
      component.getSuper().navigate(selectedMenuItemValue);
    }
  }
});