({
/***
Legal Notice
This code is the property of Salesforce.com and is protected by U.S. and International
copyright laws. Reproduction, distribution without written permission of Salesforce is
strictly prohibited. In particular this code has been delivered by Salesforce.com for
its Client’s internal purposes pursuant to specific terms and conditions, and cannot be
re-used, reproduced or distributed for any other purposes.
Author: P-E GROS / April 2020
***/
	doInit : function(component,event,helper) {
		console.log('doInit: START');
		
        // Loading Custom Label for Title
        var title = component.get("v.title");
        if ((title) && (title.includes('$Label.'))) {
            console.log('doInit: fetching custom Label value for title ',title);
            title = $A.getReference(title) || title;
            console.log('doInit: title value fetched',title);
            component.set("v.title",title);
        }

        // Loading Networks        
        helper.loadNetworks(component,helper);
        console.log('doInit: networks loading triggered');
        
        // Loading Topic Assignments       
        helper.loadAssignments(component,helper);
        console.log('doInit: topic assignments loading triggered');

        console.log('doInit: END');
	},
    loadNetworks : function(component,helper) {
        console.log('loadNetworks: START');

        component.find('soqlUtil').runQuery(
            "SELECT Name, UrlPathPrefix, Description, Status FROM Network",
            true, // bypassFLS
            true, // bypassSharing
            "PEG_TopicNetworks",  // queryType
            true, // isStorable
            false, // isBackground
            function(nwList,nwError) {
                console.log('loadNetworks: SOQL query done');
                if (nwList) {
                    console.log('loadNetworks: SOQL List received',nwList);
                    component.set("v.networkList",nwList);
                    helper.finalizeInit(component,helper);
                    console.log('loadNetworks: END');
                }
                else {
                    console.error('loadNetworks: END network SOQL Error received',nwError);
                    component.set("v.soqlError",JSON.stringify(nwError));
                    component.set("v.isReady",true);
                }
            });
        console.log('loadNetworks: networks loading triggered');
    },
    loadAssignments : function(component,helper) {
        console.log('loadAssignments: START');

        let recordId = component.get("v.recordId");
        console.log('loadAssignments: recordId fetched',recordId);
        
        component.find('soqlUtil').runQuery(
            "SELECT NetworkId, Topic.Name, Topic.Description FROM TopicAssignment where EntityId='"
            		+ recordId + "' AND NetworkId != null order by NetworkId",
            true, // bypassFLS
            true, // bypassSharing
            "PEG_TopicAssignments",  // queryType
            false, // isStorable
            false, // isBackground
            function(assignList,assignError) {
                console.log('loadAssignments: SOQL query done');
                if (assignList) {
                    console.log('loadAssignments: SOQL List received',assignList);
                    component.set("v.assignmentList",assignList);
                    helper.finalizeInit(component,helper);
                    console.log('loadAssignments: END');
                }
                else {
                    console.error('loadAssignments: END SOQL Error received',assignError);
                    component.set("v.soqlError",JSON.stringify(assignError));
                    component.set("v.isReady",true);
                }
            });
        console.log('loadAssignments: SOQL query sent');
    },
    finalizeInit : function(component,helper) {
        console.log('finalizeInit: START');
        
		let networkList = component.get("v.networkList");
        console.log('finalizeInit: network List fetched',networkList);
        
        let assignmentList = component.get("v.assignmentList");
        console.log('finalizeInit: assignment List fetched',assignmentList);
        
        let soqlError = component.get("v.soqlError");
        console.log('finalizeInit: SOQL Error fetched',soqlError);
        
        if (networkList && assignmentList) {
        	console.log('finalizeInit: finalizing assignment',assignmentList);
            
            let displayList = [];
        	let currentNW = null;
        	assignmentList.forEach(function(item){
            	console.log('finalizeInit: processing item',item);
           		//item.type  = 'icon';
            	//item.iconName = 'standard:topic';
            	item.alternativeText = 'Topic';
            	item.href = '';
                item.title = item.Topic.Description;
            	item.label = item.Topic.Name;
            	if ((currentNW == null) || (item.NetworkId != currentNW.Id)) {
                	console.log('finalizeInit : processing new Network',item.NetworkId);
                	currentNW = networkList.find( elt => elt.Id === item.NetworkId );
                	console.log('finalizeInit : currentNW found',currentNW);
                    
                    if (currentNW.Status == 'Live') {
                        currentNW.Icon = 'utility:success';
                        currentNW.Variant = 'Success';
                    }
                    else {
                        currentNW.Icon = 'utility:warning';
                        currentNW.Variant = 'Warning';
                    }
                	console.log('finalizeInit : currentNW updated',currentNW);
                	currentNW.topics = [];
                	currentNW.topics.push(item);
                	displayList.push(currentNW);
            	} else {
                	console.log('finalizeInit: processing existing Network',currentNW);
                	currentNW.topics.push(item);
            	}
        	});
        	console.log('finalizeInit: displayList initialized',displayList);
        	component.set("v.displayList",displayList);
            
            component.set("v.isReady",true);
        	console.log('finalizeInit: component ready / all data loaded');
        }
        else {
            if (soqlError) {
                component.set("v.isReady",true);
        		console.warn('finalizeInit: component ready / error raised');
            }
            else {
                console.log('finalizeInit: waiting for more data');
            }
        }
        
        console.log('finalizeInit: END');        
    },
    loadNetworkTopics : function(component,event,helper) {
        console.log('loadNetworkTopics: START');
        
        let selectedNw = component.find('networkSelect').get('v.value');
        console.log('loadNetworkTopics: selectedNw is', selectedNw);
                  
        if (selectedNw) {
        	console.log('loadNetworkTopics: launching topic SOQL fetch');
            component.set("v.isReady",false);
            component.set("v.soqlError",null);
            
			let recordId = component.get("v.recordId");
        	console.log('loadNetworkTopics: recordId fetched',recordId);
    
        	component.find('soqlUtil').runQuery(
            	"SELECT Name FROM Topic where NetworkId='"
    				+ selectedNw
            		+ "' AND ID not in (select TopicId from TopicAssignment where EntityId = '"
            		+ recordId
    				+ "') order by Name",
            	true, // bypassFLS
            	true, // bypassSharing
            	"PEG_Topics",  // queryType
            	false, // isStorable
            	false, // isBackground
            	function(topicList,topicError) {
                	console.log('loadNetworkTopics: assignment SOQL query done');
                	if (topicList) {
                    	console.log('loadNetworkTopics: END topic assignment SOQL List received',topicList);
                    	component.set("v.topicList",topicList);
                        component.set("v.isReady",true);
                	}
                	else {
                    	console.error('loadNetworkTopics: END topic assignment SOQL Error received',topicError);
                    	component.set("v.soqlError",JSON.stringify(topicError));
                    	component.set("v.isReady",true);
                	}
            	});
            console.log('loadNetworkTopics: loading network topics');
        }
        else {
            console.log('loadNetworkTopics: END no network selected');
        }
    },
    addTopic : function(component,event,helper) {
        console.log('addTopic: START');
        
        let selectedNw = component.find('networkSelect').get('v.value');
        console.log('loadNetworkTopics: selectedNw is', selectedNw);
        
        let selectedTopic = component.find('topicSelect').get('v.value');
        console.log('addTopic: selected Topic is', selectedTopic);
        
		if (selectedNw && selectedTopic) {
        	console.log('addTopic: launching topic assignment add');
            component.set("v.isReady",false);
            component.set("v.soqlError",null);
            
			let recordId = component.get("v.recordId");
        	console.log('addTopic: recordId fetched',recordId);
            
            let newAssignment = {
                'sobjectType': 'TopicAssignment',
                'NetworkId'  : selectedNw,
                'TopicId'    : selectedTopic,
                'EntityId'   : recordId
            };
        	console.log('addTopic: new Assignment init',newAssignment);
            
            component.find('soqlUtil').runDML(
            	'insert',
            	[newAssignment],
            	function(dmlResult,dmlError) {
                	console.log('addTopic: result from insert DML');
                	if (dmlResult) {
                    	console.log('addTopic: END dmlResult received',JSON.stringify(dmlResult));
                        //currentNW = networkList.find( elt => elt.Id === item.NetworkId );
                		//console.log('finalizeInit : currentNW updated',currentNW);
                		helper.loadAssignments(component,helper);
                		
                		/*let newAssignment = dmlResult[0];
        				console.log('addTopic: new assignment extracted',newAssignment);
                        
                		let assignmentList = component.get("v.assignmentList");
        				console.log('addTopic: assignment List fetched',assignmentList);
                        
                        let topicList = component.get("v.topicList");
        				console.log('addTopic: topic List fetched',topicList);
                        
                        let newTopic = topicList.find(elt => elt.Id === selectedTopic);
        				console.log('addTopic: new topic details fetched',newTopic);
                        
                        newAssignment.Topic = {
                            'Name':	newTopic.Name,
                            'Id':	newTopic.Id,
                            'Description':	newTopic.Description
                        }
        				console.log('addTopic: new assignment updated',newAssignment);
                        assignmentList.push(newAssignment);
        				console.log('addTopic: new assignment added',assignmentList);
                        component.set("v.assignmentList",assignmentList);
                        helper.finalizeInit(component,helper);
                        */
                        console.log('addTopic: END');
                	}
                	else {
                    	component.set("v.soqlError",JSON.stringify(dmlError));
                    	console.warn('addTopic: END dmlError received',dmlError);
                        component.set("v.isReady",true);
                	}
            	});
            console.log('addTopic: new Assignment insert requested');
        }
        else {
            console.warn('addTopic: END Network or Topic not selected');
        }
    },
    removeTopic : function(component,event,helper) {
        console.log('removeTopic: START');
        
        let isReadOnly = component.get("v.isReadOnly");
        console.log('finalizeInit: isReadOnly fetched',isReadOnly);
        if (isReadOnly) {
            console.log('removeTopic: END ignoring event in Read-Only mode');
            return;
        }
        component.set("v.isReady",false);
        component.set("v.soqlError",null);
        
        let assignmentId = event.getParam("item").Id;
        console.log('removeTopic: event item', event.getParam("item"));
        console.log('removeTopic: assignmentId fetched',assignmentId);
        
        let removedAssignment = {
            'sobjectType': 'TopicAssignment',
            'Id'         : assignmentId
        };
        console.log('removeTopic: removed Assignment init',removedAssignment);

        component.find('soqlUtil').runDML(
            'delete',
            [removedAssignment],
            function(dmlResult,dmlError) {
                console.log('removeTopic: result from DML');
                if (dmlResult) {
                    console.log('removeTopic: END dmlResult received',dmlResult);
                    helper.loadAssignments(component,helper);
                    console.log('removeTopic: END');
                    /*
                    let assignmentList = component.get("v.assignmentList");
        			console.log('removeTopic: assignment List fetched',assignmentList);
                    let currentAssignment = assignmentList.find( elt => elt.Id === assignmentId );
        			console.log('removeTopic: current assignment fetched',currentAssignment);
                    */
                }
                else {
                    component.set("v.soqlError",JSON.stringify(dmlError));
                    console.warn('removeTopic: END dmlError received',dmlError);
                }
                component.set("v.isReady",true);
            });
        console.log('removeTopic: assignment deletion requested');
    }
})