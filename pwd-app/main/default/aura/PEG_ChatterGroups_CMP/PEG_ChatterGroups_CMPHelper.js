({
/***
* @author P-E GROS
* @date   Nov. 2019
*
* Legal Notice
* This code is the property of Salesforce.com and is protected by U.S. and International
* copyright laws. Reproduction, distribution without written permission of Salesforce is
* strictly prohibited. In particular this code has been delivered by Salesforce.com for
* its Client’s internal purposes pursuant to specific terms and conditions, and cannot be
* re-used, reproduced or distributed for any other purposes.
***/
    
    initialize : function(component,helper) {
        console.log('initialize START');

        let title = component.get("v.title");
        console.log('initialize: title fetched',title);
        if ((title) && (title.includes('$Label.'))) {
            console.log('initialize: fetching custom label value for ',title);
            title = $A.getReference(title) || title;
            console.log('initialize: custom label value fetched ',title);
            component.set("v.title",title);
        }
        
        let configStr = component.get("v.configStr");
        console.log('initialize: configStr fetched ', configStr);
        if (configStr)  {
            component.find('mergeUtil').merge(
	            configStr,
            	null,
            	function(mergeResult,mergeError) {
                	console.log('initialize: result from merge');
                	if (mergeResult) {
                   		console.log('initialize: mergeResult received',mergeResult);
                        
                        let nameList = JSON.parse(mergeResult);
                        console.log('initialize: nameList parsed ', nameList);
                        if (nameList == null) nameList = [];
         
                        let queryString = "select Id,Name from CollaborationGroup WITH_SECURITY_ENFORCED  where Name in ('"
                            + nameList.join("','")
                            + "') order by Name";
            			console.log('initialize: queryString built ', queryString);
                        
                  		component.find('soqlUtil').runQuery(
                       		queryString,
                            false,
                            false,
                            null,
                       		true,
                       		false,
                       		function(queryResult,queryError) {
                           		console.log('initialize: result from query');
                           		if (queryResult) {
                               		console.log('initialize: queryResult received', JSON.stringify(queryResult));
                    				console.log('initialize: group list length ',   queryResult.length);
                                    
                    				if (queryResult.length > 0) {
                        				console.log('initialize: launching group list init ');
                                        
                        				let selectGroup = queryResult.find(function(element) {
                            				return element.Name === nameList[0];
                        				});
                        				if (!selectGroup) selectGroup = queryResult[0];
                        				component.set("v.selectGroup", selectGroup);
                        				console.log('initialize: selectGroup set ', JSON.stringify(selectGroup));
                                        
                        				component.set("v.groupList", queryResult);
                       					console.log('initialize: group list set');
                                        
                        				helper.updateFeed(component);                        
                        				console.log('initialize: END OK ');
                                    }
                                    else {
                                        console.error('initialize: END empty group list received ');
                                    }
                                }
                                else {
                                    console.error('initialize: group list fetching failed ', JSON.stringify(queryError));
                                }
                            }
                        );
            			console.log('initialize: query sent');
                    }
                    else {
                        console.error('initialize: merge error',JSON.stringify(mergeError));
                    }
                }
            );
            console.log('initialize: merge requested');
        }
        else {
            console.warn('initialize: END KO missing configStr');
        }

        console.log('initialize END');
    },
    updateFeed : function(component, event) {
        console.log('updateFeed START');

        let selectGroup = component.get("v.selectGroup");
        console.log("updateFeed: current selectGroup fetched ", JSON.stringify(selectGroup));
        if (event) {
            console.log("updateFeed: event params ", JSON.stringify(event.getParams()));
            selectGroup = event.getParam("value");
            console.log("updateFeed: selectGroup overriden from event", selectGroup);
            component.set("v.selectGroup",selectGroup);
        }

        let showPublisher = component.get("v.showPublisher");
        if (showPublisher) {
            console.log("updateFeed: updating publisher");
            $A.createComponent(
                "forceChatter:publisher", {
                    "context": "RECORD",
                    "recordId": selectGroup.Id
                },
                function(publisher, status, errorMessage){
                    let publisherDiv = component.find("publisherDiv");
                    if (status === "SUCCESS") { 
                        console.log("updateFeed: adding publisher in div");
                        publisherDiv.set("v.body",publisher);
                        console.log("updateFeed: publisher added in div");
                    }
                    else {
                        console.warn("updateFeed: publisher creation failed ",errorMessage);
                        publisherDiv.set("v.body",null);
                    }
                }
            ); 
        }
        else {
            console.log("updateFeed: no publisher to add");
        }
           
        let feedDesign = component.get("v.feedDesign");
        console.log("updateFeed: feedDesign fetched", feedDesign);
        $A.createComponent(
            "forceChatter:feed", {
                "type"      : "Record", // Record
                "feedDesign": feedDesign,
                "subjectId" : selectGroup.Id
            },
            function(feed, status, errorMessage) {
                let feedDiv = component.find("feedDiv");
                if (status === "SUCCESS") { 
                    console.log("updateFeed: adding feed in div");
                    feedDiv.set("v.body",feed);
                    console.log("updateFeed: feed added in div");
                }
                else {
                    console.warn("updateFeed: feed creation failed ",errorMessage);
                    feedDiv.set("v.body",null);
                }
            }
        );
        console.log('updateFeed END');
    },
    navigateToGroup : function(component) {
        console.log('navigateToGroup START');

        let selectGroup = component.get("v.selectGroup");
        if (selectGroup) {
            console.log('navigateToGroup: selectGroup fetched',selectGroup);
            let navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({"recordId": selectGroup.Id});
            navEvt.fire();
            console.log('navigateToGroup END --> navigation triggered');
        }
        else{
            console.log('navigateToGroup END --> no navigation triggered');
        }
    }
})