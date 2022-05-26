({
  startFlow: function (component, flowName) {
    console.log('flowName', flowName);
    $A.createComponent(
      "lightning:flow",
      {
        "aura:id": "flowData",
        "onstatuschange": component.getReference("c.statusChange")
      },
      function (cmpFlow, status, errorMessage) {
        //Add the new button to the body array
        if (status === "SUCCESS") {
          var flowContainer = component.find("flowContainer");
          var body = [];
          body.push(cmpFlow);
          flowContainer.set("v.body", body);
          var inputVariables = [
          {
            name: "recordId",
            type: "String",
            value: component.get("v.recordId")
          }];
          cmpFlow.startFlow(flowName, inputVariables);
          component.set("v.flowFinished", false);
        }
        else if (status === "INCOMPLETE") {
          console.error("No response from server or client is offline.")
          // Show offline error
        }
        else if (status === "ERROR") {
          console.error("Error: " + errorMessage);
          // Show error message
        }
      }
    );
  },
  showConfirmModal: function (component) {
    component.set("v.showModal", true);
  },
  hideConfirmModal: function (component) {
    component.set("v.showModal", false);
  }
})