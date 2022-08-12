({
  sectionClick: function (component, event, helper) {
    event.stopPropagation();
    var flowFinished = component.get("v.flowFinished");
    var section = event.getParam("sectionName");
    var flowName = event.getParam("flowName");
    component.set("v.clickedSection", section);
    component.set("v.clickedFlowName", flowName);
    if (!flowFinished) {
      helper.showConfirmModal(component);
    } else {
      component.set("v.currentSection", section);
      component.find("progressBar")
        .refresh();
      helper.startFlow(component, flowName);
    }
  },
  statusChange: function (component, event, helper) {
    console.log('statusChange', event.getParam('status'));
    if (event.getParam('status') === "FINISHED") {
      component.set("v.flowFinished", true);
    }
  },
  yesClick: function (component, event, helper) {
    helper.hideConfirmModal(component);
    component.set("v.currentSection", component.get("v.clickedSection"));
    component.find("progressBar")
      .refresh();
    helper.startFlow(component, component.get("v.clickedFlowName"));
  },
  noClick: function (component, event, helper) {
    helper.hideConfirmModal(component);
  }
})