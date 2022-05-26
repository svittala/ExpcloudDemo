({
	loadKpis : function(component) {
        console.log('loadKpis: START');
        
        let kpiConfigStr = component.get("v.kpiConfigStr");
        console.log('loadKpis: kpiConfigStr fetched',kpiConfigStr);
        component.find('mergeUtil').merge(
            kpiConfigStr,
            null,
            function(mergeResult,mergeError) {
                console.log('loadKpis: result from merge');
                if (mergeResult) {
                   console.log('loadKpis: mergeResult received',mergeResult);
                   
                   let kpiConfigJson = JSON.parse(mergeResult);
                   component.set("v.kpiConfigJson",kpiConfigJson);
                   console.log('loadKpis: kpiConfigJson initialized',kpiConfigJson);
        
                   let kpiFetchCount = 0;
                   kpiConfigJson.forEach(function(kpiItem) {
                      kpiFetchCount = kpiFetchCount + kpiItem.kpis.length; 
                   });
                   console.log('loadKpis: kpiFetchCount computed',kpiFetchCount);
                   component.set("v.kpiFetchCount",kpiFetchCount);
            
                   kpiConfigJson.forEach(function(kpiItem) {
                       console.log('loadKpis: sending soql for kpiItem',kpiItem);
                       (kpiItem.kpis).forEach(function(kpiUnitItem) {
                             console.log('loadKpis: sending soql for kpiUnitItem',kpiUnitItem);
                             component.find('soqlUtil').runQuery(
                                 kpiUnitItem.query,
                                 component.get("v.bypassFLS"),
                                 component.get("v.bypassSharing"),
                                 component.get("v.queryType"),
                                 component.get("v.isStorable"),
                                 component.get("v.isBackground"),
                                 function(result,error) {
                                     console.log('loadKpis: result from SOQL query for item',kpiUnitItem);                           
                                     if (result) {
                                         console.log('loadKpis: KPI received', result[0].expr0);
                                         kpiUnitItem.value = result[0].expr0;
                                         kpiUnitItem.color = "standard";
                                         
                                         if (kpiUnitItem.inverse) {
                                            if ((kpiUnitItem.warning) && (kpiUnitItem.value < kpiUnitItem.warning)) kpiUnitItem.color = "warning";
                                            if ((kpiUnitItem.error)   && (kpiUnitItem.value < kpiUnitItem.error))   kpiUnitItem.color = "error"; 
                                            if ((kpiUnitItem.warning && kpiUnitItem.warning != 0) && (kpiUnitItem.value >= kpiUnitItem.warning)) kpiUnitItem.color = "success";
                                         } else {
                                            if ((kpiUnitItem.warning) && (kpiUnitItem.value > kpiUnitItem.warning)) kpiUnitItem.color = "warning";
                                            if ((kpiUnitItem.error)   && (kpiUnitItem.value > kpiUnitItem.error))   kpiUnitItem.color = "error";
                                         }
                                         component.set("v.kpiConfigJson",kpiConfigJson);
                                         component.set("v.kpiFetchCount", component.get("v.kpiFetchCount") - 1);
                                     } else {
                                         console.error('loadKpis: KPI SOQL query error',error);
                                         component.find('notifUtil').showNotice({
                                            "variant": "error",
                                            "header": "Error in KPI SOQL query !",
                                            "message": JSON.stringify(error) + ' for ' + kpiUnitItem.query
                                         });
                                     }
                                 }
                            );
                            console.log('loadKpis: kpiUnitItem processed', kpiUnitItem);
                       });
                       console.log('loadKpis: kpiItem processed',kpiItem);
                   });
                   console.log('loadKpis: kpiConfigJson processed',kpiConfigJson);
                } else {
                    console.error('loadKpis: KPI merge error',mergeError);
                    component.find('notifLib').showNotice({
                          "variant": "error",
                          "header": "Error in KPI SOQL query !",
                          "message": JSON.stringify(mergeError)
                    });
                }
                console.log('loadKpis: KPI merge done');
            }
        );
        console.log('loadKpis: END / all soql sent');
	},
    triggerAction : function(component,selectedAction,selectedRow) {
        console.log('triggerAction: START');
        let selectedActionStr = JSON.stringify(selectedAction);
        console.log('triggerAction: action stringified',selectedActionStr);
                    
        component.find('mergeUtil').trigger(
            selectedAction.event,
            selectedRow,
            function(result,error) {
                  console.log('triggerAction result from merge');
                  if (result) {
                      console.log('triggerAction: result parsed',JSON.stringify(result));
                  } else {
                      console.error('triggerAction: triggering merge error notification',JSON.stringify(error));
                      component.find('notifUtil').showNotice({
                         "variant": "error",
                         "header": "Error in merge !",
                         "message": JSON.stringify(error)
                      });
                  }
              }
        );
        console.log('triggerAction: END');
    }
    /*
        component.find('mergeUtil').merge(
            selectedActionStr,
            selectedRow,
            function(result,error) {
                  console.log('triggerAction result from merge');
                  if (result) {
                      let resultJson = JSON.parse(result);
                      console.log('triggerAction: result parsed',resultJson);

                      let eventToTrigger = $A.get(resultJson.event.name);
                      eventToTrigger.setParams(resultJson.event.params);
                      console.log('triggerAction: triggering event',eventToTrigger);
                      eventToTrigger.fire();
                  } else {
                      console.log('triggerAction: triggering merge error notification',JSON.stringify(error));
                      component.find('notifUtil').showNotice({
                         "variant": "error",
                         "header": "Error in merge !",
                         "message": JSON.stringify(error)
                      });
                  }
              }
        );
        console.log('triggerAction: END');
    }
    */
})