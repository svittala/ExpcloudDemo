({
    
    openAnalytics : function(message,component) {
        console.log('openAnalytics START');
        
        console.log('openAnalytics processing message',message);
        
		let analyticsSdk = component.find("analyticsSdk");
        console.log('openAnalytics analyticsSdk found',analyticsSdk);
       
        let context = {
            apiVersion: "42"
        };
        let methodName = "listDashboards";
        let methodParameters = {
            q: message.name,
            sort: "Name"
        };
        console.log('openAnalytics methodParameters',methodParameters);
        
        var helper = this;
        
        analyticsSdk.invokeMethod(context, methodName, methodParameters,
            $A.getCallback(function(err, data) {
              if (err !== null) {
                console.error("openAnalytics error: ", err);
              } else {
                console.log('openAnalytics data: ',data);
                let dashboard = JSON.parse(JSON.stringify(data));
                console.log('openAnalytics dashboard: ',dashboard);
                
                helper.openTargetUrl('Analytics',dashboard.dashboards[0],component);
              }
            }
         ));
        
        console.log('openAnalytics END');
	},
    openReport : function(message,component) {
        console.log('openReport START');     
        
        var helper = this;
        component.find('soqlUtil').runQuery(
            "SELECT Id, DeveloperName FROM Report WHERE DeveloperName = '"
            + message.name + "' WITH SECURITY_ENFORCED LIMIT 1",
            false,
            false,
            "",
            true,
            false,
            function(queryResult,queryError) {
                console.log('openReport: result from query');
                if (queryResult) {
                    console.log('openReport: queryResult received',queryResult);
                    message.id = queryResult[0].Id;
                    
                    helper.openTargetUrl('Report',message,component);
                } else {
                    console.error('openReport: triggering query error notification',JSON.stringify(queryError));
                    component.find('notifUtil').showNotice({
                       "variant": "error",
                       "header": "Error in query !",
                       "message": JSON.stringify(queryError)
                    });
                }
            });
                               
        console.log('openReport END'); 
    },
    openDashboard : function(message,component) {
        console.log('openDashboard START');
        
        var helper = this;
        component.find('soqlUtil').runQuery(
            "SELECT Id, DeveloperName FROM Dashboard WHERE DeveloperName = '"
            + message.name + "' WITH SECURITY_ENFORCED LIMIT 1",
            false,
            false,
            "",
            true,
            false,
            function(queryResult,queryError) {
                console.log('openDashboard: result from query');
                if (queryResult) {
                    console.log('openDashboard: queryResult received',queryResult);
                    queryResult[0].id = queryResult[0].Id;
                    
                    helper.openTargetUrl('Dashboard',queryResult[0],component);
                } else {
                    console.error('openDashboard: triggering query error notification',JSON.stringify(queryError));
                    component.find('notifUtil').showNotice({
                       "variant": "error",
                       "header": "Error in query !",
                       "message": JSON.stringify(queryError)
                    });
                }
            });
                               
        console.log('openDashboard END'); 
    },
    openTargetUrl : function(reportType,reportDetails,component){
        console.log('openTargetUrl START');
        
        console.log('openTargetUrl reportDetails',reportDetails);
        
        if ((reportType == 'Report') && (reportDetails.filters)) {
            console.log('openTargetUrl opening filtered report');
            
            let targetReportUrl = '/lightning/r/Report/' + reportDetails.id
                                + "/view?" ;
            //+ "?\u0026";
            
            let filterKeys = Object.keys(reportDetails.filters);
            console.log('navigateToReport: filterKeys init', filterKeys);
            
            filterKeys.forEach(function(keyItem){
                console.log('navigateToReport: keyItem', keyItem);
                console.log('navigateToReport: filter field',reportDetails.filters[keyItem]);
                targetReportUrl += keyItem + '='
                                + reportDetails.filters[keyItem] + '&';
                console.log('navigateToReport: targetReportUrl updated', targetReportUrl);
            });
            targetReportUrl = targetReportUrl.slice(0,-1);
            
            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
                "url": targetReportUrl
            });
            console.log('navigateToReport: firing urlEvent',urlEvent);
            urlEvent.fire();
            
        } else {
            console.log('openTargetUrl opening reporting object');
            let navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
              "recordId": reportDetails.id
            });
            console.log('openTargetUrl firing navEvt',navEvt);
            navEvt.fire();
        }
        
        console.log('navigateToReport: END');
    },
    openObject : function(message,component) {
        console.log('openObject START');        
            
        let navEvt = $A.get(message.name);
        console.log('openObject triggering event',message.name);
        navEvt.setParams(message.params);
        console.log('openObject setting event params',JSON.stringify(message.params));
        navEvt.fire();

        console.log('openObject END'); 
    },
    EventMap : {
        "PEG_OpenComponent": "openObject",
        "PEG_QuickAction":   "openObject",
        "PEG_PopUp": "openObject",
        "PEG_Object": "openObject",
        "PEG_Analytics": "openAnalytics",
        "PEG_Report": "openReport",
        "PEG_Dashboard": "openDashboard"
    }
})