({
/***
Legal Notice</h4>
This code is the property of Salesforce.com and is protected by U.S. and International
copyright laws. Reproduction, distribution without written permission of Salesforce is
strictly prohibited. In particular this code has been delivered by Salesforce.com for
its Client’s internal purposes pursuant to specific terms and conditions, and cannot be
re-used, reproduced or distributed for any other purposes.
Author: P-E GROS / April 2020
***/
    SDK_CONTEXT: {
        apiVersion: "48"
    },
    DASHBOARDS: {},
    DATASETS: {},
    FILTERS: {},
    MAPPINGS: {},
	doInit : function(component, event, helper) {
		console.log('doInit: START');
        
        var title = component.get("v.title");
        if ((title) && (title.includes('$Label.'))) {
            console.log('doInit: fetching custom Label value for title ',title);
            title = $A.getReference(title) || title;
            console.log('doInit: title value fetched',title);
            component.set("v.title",title);
        }
        
        var actionLabel = component.get("v.actionLabel");
        if ((actionLabel) && (actionLabel.includes('$Label.'))) {
            console.log('doInit: fetching custom Label value for action ',actionLabel);
            actionLabel = $A.getReference(actionLabel) || actionLabel;
            console.log('doInit: action label value fetched',actionLabel);
            component.set("v.actionLabel",actionLabel);
        }
  
        /*let analyticsDB = component.find("analyticsDB");
        console.log('doInit: analyticsDB found',analyticsDB);
        
        let config = {};
        analyticsDB.getState(
            config,
            $A.getCallback(function(data) {
                console.log('doInit: DB state received',JSON.stringify(data));
                console.log('doInit: DB config updated',JSON.stringify(config));
            })
        );*/
        console.log('doInit: END');	
	},
    finalizeInit: function(component, event, helper) {
		console.log('finalizeInit: START');
        console.log('finalizeInit: event params ', JSON.stringify(event.getParams()));
        
        let analyticsDB = component.find("analyticsDB");
        console.log('finalizeInit: analyticsDB found',analyticsDB);
        
        let config = {};
        analyticsDB.getState(
            config,
            $A.getCallback(function(stateData) {
                console.log('finalizeInit: DB state received',JSON.stringify(stateData));
                
                component.set("v.dashboardId",stateData.id);
                var analyticsSDK = component.find("analyticsSDK");
        		console.log('finalizeInit: analyticsSDK found',analyticsSDK);

                if (!((helper.DASHBOARDS)[stateData.id])) {
                    console.log('finalizeInit: fetching dashboard desc for DB Id ',stateData.id);
                	helper.fetchDashboardDesc(stateData.id,stateData.payload.state,analyticsSDK,component,helper);
                    console.log('finalizeInit: END dashboard desc fetch requested ');
                }
                else {
                    console.log('finalizeInit: dashboard desc already available for DB Id ',stateData.id);
                    
                    let datasetName = component.get("v.datasetName") || ((helper.DASHBOARDS)[stateData.id]).datasets[0].name;
                    let datasetId = '';
                    ((helper.DASHBOARDS)[stateData.id]).datasets.forEach(function(dsItem) {
                    	//console.log('finalizeInit: processing DS ',JSON.stringify(dsItem));
                        if (dsItem.name === datasetName) datasetId = dsItem.id;
                    });
                    component.set("v.datasetName",datasetName);
                    console.log('finalizeInit: target DS name set ', datasetName);
                    component.set("v.datasetId",datasetId);
                    console.log('finalizeInit: target DS Id set ', datasetId);
                    
                    if (helper.MAPPINGS[stateData.id + '.' + datasetId]) {
                        console.log('finalizeInit: END all is ready ');
                        component.set("v.initDone",true);
                    }
                    else {
                        console.log('finalizeInit: END requesting mapping finalisation ');
                        helper.finaliseDescs(component,helper);
                    }
                }
            })
        );
        console.log('finalizeInit: fetching DB state');	
	},
    fetchDashboardDesc : function(dbId,dbState,analyticsSDK,component,helper) {
		console.log('fetchDashboardDesc: START');
    
    	analyticsSDK.invokeMethod(
    		helper.SDK_CONTEXT,
            "describeDashboard",
            {"dashboardId": dbId},
            $A.getCallback(function(dbErr, dbData) {
              	if (dbErr !== null) {
                    console.error("fetchDashboardDesc: END SDK DB describe error received ", JSON.stringify(dbErr));
                }
                else {
                    console.log('fetchDashboardDesc: SDK DB data received ',JSON.stringify(dbData));
                    (helper.DASHBOARDS)[dbId] = dbData;
                    (helper.DASHBOARDS)[dbId].initState = dbState;
                    console.log('fetchDashboardDesc: DB desc registered');//,JSON.stringify(helper.DASHBOARDS));
                     
                    let ds2fetch = 0;
                    let datasetName = component.get("v.datasetName") || dbData.datasets[0].name;
                    let datasetId = '';
                    dbData.datasets.forEach(function(dsItem) {
                        if (dsItem.name === datasetName) datasetId = dsItem.id;
                        if (!((helper.DATASETS)[dsItem.id])) {
                    		console.log('fetchDashboardDesc: fetching dataset desc for DS Id ',dsItem.id);
                			ds2fetch += 1;
                            helper.fetchDatasetDesc(dsItem.id,analyticsSDK,component,helper);
                    		console.log('fetchDashboardDesc: dataset desc fetch requested ');
                		}
                		else {
                    		console.log('fetchDashboardDesc: dataset desc already available for DS Id ',dsItem.id);
                		}
                    });
                    console.log('fetchDashboardDesc: fetching desc for DS ', ds2fetch);
                    
                    component.set("v.datasetName",datasetName);
                    console.log('fetchDashboardDesc: target DS name set ', datasetName);
                    component.set("v.datasetId",datasetId);
                    console.log('fetchDashboardDesc: target DS Id set ', datasetId);
                    
                    if (ds2fetch == 0)  {
                        console.log('fetchDashboardDesc: requesting desc finalisation');
                        helper.finaliseDescs(component,helper);
                    	console.log('fetchDashboardDesc: END all DS desc ready ');
                    }
                    else {
                        console.log('fetchDashboardDesc: some DS desc to fetch ',ds2fetch);
                        component.set("v.ds2fetch",ds2fetch);
                    }
                }
            }));

		console.log('fetchDashboardDesc: Dashboard description requested');    
	},
    fetchDatasetDesc : function(dsId,analyticsSDK,component,helper) {
		console.log('fetchDatasetDesc: START');
        
        analyticsSDK.invokeMethod(
            helper.SDK_CONTEXT,
            "describeDataset",
            {"datasetId": dsId},
            $A.getCallback(function(dsErr, dsData) {
                if (dsErr !== null) {
                    console.error("fetchDatasetDesc: END KO / SDK describe DS error received ", JSON.stringify(dsErr));
              	}
                else {
                    console.log('fetchDatasetDesc: SDK DS data received ',JSON.stringify(dsData));
					(helper.DATASETS)[dsId] = dsData;
                    console.log('fetchDatasetDesc: DS desc registered',JSON.stringify(this.DATASETS));
                    
                    // fetching also dataset fields
                    analyticsSDK.invokeMethod(
                        helper.SDK_CONTEXT,
                        "getDatasetFields",
                        {'datasetId':dsData.id, "versionId": dsData.currentVersionId},
                        $A.getCallback(function(dsFieldErr, dsFieldData) {
                            if (dsFieldErr !== null) {
                                console.error("fetchDatasetDesc: END KO / SDK describe DS Field error received ", JSON.stringify(dsFieldErr));
              				}
                            else {
                                console.log('fetchDatasetDesc: SDK DS Field data received ',JSON.stringify(dsFieldData));
                            	(helper.DATASETS)[dsId].fields = dsFieldData;
                    			console.log('fetchDatasetDesc: DS Field describe results registered',JSON.stringify(helper.DATASETS));
                                        
                                let ds2fetch = component.get("v.ds2fetch") - 1;
                                component.set("v.ds2fetch",ds2fetch);
                    			console.log('fetchDatasetDesc: ds2fetch updated',ds2fetch);
                                
                                if (ds2fetch == 0) {
                    				console.log('fetchDatasetDesc: requesting desc finalisation');
                                    helper.finaliseDescs(component,helper);
                    				console.log('fetchDatasetDesc: END all DS desc fetched');
                                }
                                else {
                    				console.log('fetchDatasetDesc: END DS desc fetched');                                    
                                }
                            }
                        }));
					console.log('fetchDatasetDesc: DS fields description fetch requested');
                }
            }));
        
        console.log('fetchDatasetDesc: DS desc fetch requested');
    },
    finaliseDescs : function(component,helper) {
        console.log('finaliseDescs: START');
        
        let dashboardId = component.get("v.dashboardId");
        console.log('finaliseDescs: dashboardId fetched', dashboardId);
        let datasetId	= component.get("v.datasetId");
        console.log('finaliseDescs: datasetId fetched', datasetId);
        let datasetName	= component.get("v.datasetName");
        console.log('finaliseDescs: datasetName fetched', datasetName);
        
        let dbDesc = helper.DASHBOARDS[dashboardId];
        console.log('finaliseDescs: dashboard desc fetched');//, JSON.stringify(dbDesc));
        let dsDesc = helper.DATASETS[datasetId];
        console.log('finaliseDescs: target dataset desc fetched');//, JSON.stringify(dsDesc));

        // Analysing field connections among datasets within dashboard
        let linkMapping = helper.initLinks(dbDesc,datasetName);
        console.log('finaliseDescs: linkMapping ready');

        // Processing main filters
        let filterMapping = helper.initFilters(dbDesc,datasetName,dsDesc,linkMapping,helper);
        console.log('finaliseDescs: filterMapping ready');
        
        // Processing step filters
        let stepMapping = helper.initSteps(dbDesc,datasetName,dsDesc,linkMapping,helper);
        console.log('finaliseDescs: stepMapping ready');  
        
        // Registering mapping
        helper.MAPPINGS[dashboardId + '.' + datasetId] = {
            links :		linkMapping,
            filters :	filterMapping,
            steps :		stepMapping 
        };
        console.log('finaliseDescs: global mapping updated', JSON.stringify(helper.MAPPINGS));
        
        component.set("v.initDone",true);
        console.log('finaliseDescs: END');
    },
    initLinks : function(dbDesc,datasetName) {
        console.log('initLinks: START');
        
        let links = dbDesc.state.dataSourceLinks || [];
        console.log('initLinks: dashboard links fetched');//, JSON.stringify(links));
        let linkMapping = {};
        links.forEach(function(linkItem){
        	console.log('initLinks: processing linkItem', JSON.stringify(linkItem));
            let source;
            let targets = [];
            linkItem.fields.forEach(function(fieldItem) {
        		//console.log('initLinks: processing fieldItem', JSON.stringify(fieldItem));
				if (fieldItem.dataSourceName === datasetName) source = fieldItem.fieldName;
                else targets.push(fieldItem.dataSourceName + '---' + fieldItem.fieldName);
            });
            targets.forEach(function(targetItem){
        		//console.log('initLinks: processing targetItem', targetItem);  
                linkMapping[targetItem] = source;
            });
        });
        
        console.log('initLinks: END mapping done ',JSON.stringify(linkMapping));
		return linkMapping;
    },
    initFilters : function(dbDesc,datasetName,dsDesc,linkMapping,helper) {
        console.log('initFilters: START');

        let filters = dbDesc.state.filters || [];
        console.log('initFilters: dashboard filters fetched');//, JSON.stringify(filters));
        let initFilters = dbDesc.initState.datasets || [];
        console.log('initFilters: dashboard initFilters fetched');//, JSON.stringify(initFilters));
       
        let filterMapping = {};
        filters.forEach(function(filterItem){
        	console.log('initFilters: processing filterItem', JSON.stringify(filterItem));
            
            let fieldName = null;
            let fieldAbsName = filterItem.dataset.name + '---' + filterItem.fields[0];
            if (filterItem.dataset.name === datasetName) {
                console.log('initFilters: processing filterItem on main DS');
                fieldName = filterItem.fields[0];
            }
            else {
                console.log('initFilters: processing filterItem on other DS');
            	fieldName = linkMapping[fieldAbsName];
            }

            if (fieldName) {
        		console.log('finaliseDescs: keeping filter', fieldName);
                
            	let dateField = dsDesc.fields.dates.find(elt => fieldName === elt.alias);
            	if (dateField) {
        			console.log('finaliseDescs: registering date filter', JSON.stringify(dateField));
                    filterMapping[fieldAbsName] = {
                        field: fieldName,
                        type: "date",
                        operator: filterItem.operator,
                        fields : dateField.fields,
                        source: fieldAbsName
                    }
            	}
                else {
        			console.log('finaliseDescs: registering standard filter');
                    filterMapping[fieldAbsName] = {
                        field: fieldName,
                        type: "standard",
                        operator: filterItem.operator,
                        source: fieldAbsName
                    }
                }
            }
            else {
        		console.warn('finaliseDescs: filterItem ignored');
            } 
        });
        
        console.log('initFilters: END mapping done',JSON.stringify(filterMapping));
        return filterMapping;
    },
    initSteps : function(dbDesc,datasetName,dsDesc,linkMapping,helper) {
        console.log('initSteps: START');
            
        let steps = dbDesc.state.steps || {};
        console.log('initSteps: dashboard steps fetched', Object.keys(steps));//, JSON.stringify(steps));
        let initSteps = dbDesc.initState.steps || {};
        console.log('initSteps: dashboard initSteps fetched', Object.keys(initSteps));//, JSON.stringify(initSteps));
        
        let stepMapping = {};
        Object.keys(steps).forEach(function(stepItemName){
        	console.log('initSteps: processing stepItem',stepItemName);
            let itemDesc = steps[stepItemName];
            console.log('initSteps: stepItem value ',JSON.stringify(itemDesc.datasets));
            let itemDS = helper.DATASETS[itemDesc.datasets[0].id];//itemDesc.datasets[0];
            console.log('initSteps: stepItem DS name fetched ',itemDS.name);
            
            let itemInitDesc = initSteps[stepItemName];
            if (itemInitDesc) {
            	console.log('initSteps: stepItem init value ',JSON.stringify(itemInitDesc));

                stepMapping[stepItemName] = {};
                itemInitDesc.metadata.groups.forEach(function(fieldItem){
        			console.log('initSteps: processing fieldItem',fieldItem);
                                        
                    if (fieldItem.includes('~~~')){
                    	console.log('initSteps: processing compound date field');
                        
                        let mapping = helper.mapCompoundField(fieldItem, itemDS, dsDesc, linkMapping);
                        if (mapping) {
                            console.log('initSteps: registering compound date field',fieldItem);
                        	stepMapping[stepItemName][fieldItem] = mapping;
                        }
                        else {
                            console.warn('initSteps: compound date field ignored',fieldItem);                            
                        }
                    }
                    else {
                    	console.log('initSteps: processing standard field');
                        
                        let mapping = helper.mapStandardField(fieldItem, itemDS, dsDesc, linkMapping);
                        if (mapping) {
                            console.log('initSteps: registering standard field',fieldItem);
                        	stepMapping[stepItemName][fieldItem] = mapping;
                        }
                        else {
                            console.warn('initSteps: standard field ignored',fieldItem);                            
                        }
                    }
                    
                });
            }
            else {
            	console.warn('initSteps: missing itemInitDesc (step not used)',stepItemName);
            }
        });
        
        console.log('initSteps: END mapping done ', JSON.stringify(stepMapping));
        return stepMapping;
    },
    mapCompoundField : function(srcFieldName, srcDS, mainDS, linkMapping) {
        console.log('mapCompoundField: START');
                        
        let srcFieldParts = srcFieldName.split('~~~');
        console.log('mapCompoundField: date field parts extracted ',srcFieldParts);
        let srcDateField = srcDS.fields.dates.find(elt => {
                return Object.values(elt.fields).includes(srcFieldParts[0]);});
        
        if (srcDateField) {
            console.log('mapCompoundField: date field found',srcDateField.alias);
  
        	if (srcDS.name === mainDS.name) {
                let mapping = {
                    field: srcDateField.alias,
                    fields : srcFieldParts,
                    type: "compound",
                    operator: "=="
                };
            	console.log('mapCompoundField: END returning compound date field on main DS', JSON.stringify(mapping));
            	return mapping;
            }
            else {
            	console.log('mapCompoundField: handling compound date field on other DS');
                // more complex approach : map the date field alias to main DS and 
                // map each individual date sub-field used
                
				let mainDateFieldName = linkMapping[srcDS.name + '---' + srcDateField.alias];
        		console.log('mapCompoundField: field name mapped ', JSON.stringify(mainDateFieldName));
                                
                if (mainDateFieldName) {
                    let mainDateField = mainDS.fields.dates.find(elt => mainDateFieldName === elt.alias);
        			console.log('mapCompoundField: field desc fetched on main DS', JSON.stringify(mainDateField));
                                    
                    let mainFieldParts = [];
                    srcFieldParts.forEach(function(fp) {
                        console.log('mapCompoundField: processing field part', fp);
                        let idx = (Object.values(srcDateField.fields)).findIndex(elt => fp === elt);
        				console.log('initSteps: idx found', idx);
                        let fn = (Object.keys(srcDateField.fields))[idx];
        				console.log('initSteps: key determined ', fn);
        				console.log('initSteps: main value ', mainDateField.fields[fn]);
                        mainFieldParts.push(mainDateField.fields[fn]);
                    });
                    console.log('mapCompoundField: mainFieldParts prepared',JSON.stringify(mainFieldParts));
                    
                    let mapping = {
                    	field: mainDateFieldName,
                    	fields : mainFieldParts,
                    	type: "compound",
                    	operator: "==",
                        source: srcDS.name + '---' + srcDateField.alias
                	};
            		console.log('mapCompoundField: END returning compound date field on other DS', JSON.stringify(mapping));
            		return mapping;
                }
                else {
                    console.warn('mapCompoundField: END compound date field not mapped on other DS',srcDateField.alias);
                    return null;
                }
            }
        }
        else {
            console.warn('mapCompoundField: compound date field not found on src DS',fieldParts[0]); 
            return null;
        }
    },
    mapStandardField : function(srcFieldName, srcDS, mainDS, linkMapping) {
        console.log('mapStandardField: START');
        
        if (srcDS.name === mainDS.name) {
            console.log('mapStandardField: processing field on main DS');
            
        	let dateField = mainDS.fields.dates.find(elt => srcFieldName === elt.alias);
            if (dateField) {
            	let mapping = {
                    field: srcFieldName,
                    fields : dateField.fields,
                    type: "date",
                    operator: ">=<="
                };
            	console.log('mapStandardField: END returning date field on main DS', JSON.stringify(mapping));
            	return mapping;
            }
            else {
                let mapping = {
                    field: srcFieldName,
                    type: "standard",
                    operator: "in"
                };
            	console.log('mapStandardField: END returning standard field on main DS', JSON.stringify(mapping));
            	return mapping;
            }            
        }
        else {
            console.log('mapStandardField: processing field on other DS');
            
            let mainFieldName = linkMapping[srcDS.name + '---' + srcFieldName];
            if (mainFieldName) {
        		console.log('mapStandardField: field name mapped', mainFieldName);
                
                let mainDateField = mainDS.fields.dates.find(elt => mainFieldName === elt.alias);
                if (mainDateField) {
        			console.log('mapStandardField: handling date field', mainDateField.alias);
                    let mapping = {
                    	field: mainDateField.alias,
                    	fields : mainDateField.fields,
                    	type: "date",
                    	operator: ">=<=",
                        source: srcDS.name + '---' + srcFieldName
                	};
            		console.log('mapStandardField: END returning date field from other DS', JSON.stringify(mapping));
            		return mapping;
                }
                else {
        			console.log('mapStandardField: handling measure/dimension field');
                    let mapping = {
                    	field: mainFieldName,
                    	type: "standard",
                    	operator: "in",
                        source: srcDS.name + '---' + srcFieldName
                	};
            		console.log('mapStandardField: END returning standard field from other DS', JSON.stringify(mapping));
            		return mapping;
                }
            }
            else {
                console.warn('mapStandardField: END field not mapped on other DS',srcFieldName);
                return null;
            }
        }
            
        /*let srcDateField = srcDS.fields.dates.find(elt => srcFieldName === elt.alias);
        if (srcDateField) {
            console.log('mapStandardField: processing date field');
            if (srcDS.name === mainDS.name) {
                let mapping = {
                    field: srcDateField.alias,
                    fields : srcDateField.fields,
                    type: "date",
                    operator: ">=<="
                };
            	console.log('mapStandardField: END returning date field on main DS', JSON.stringify(mapping));
            	return mapping;
            }
            else {
                let mainFieldName = linkMapping[srcDS.name + '---' + srcField];
        		console.log('mapStandardField: field name mapped', mainFieldName);
                                
                if (mainFieldName) {
                    let mainDateField = mainDS.fields.dates.find(elt => mainDateFieldName === elt.alias);
        			console.log('mapStandardField: END field desc fetched on main DS', JSON.stringify(mainDateField));
                }
                else {
                    console.warn('mapStandardField: END compound date field not mapped on other DS',srcDateField.alias);
                    return null;
                }
            }
        }
        else {
            console.log('mapStandardField: processing measure/dimension field');
            
        }
        
    	let mainFieldName = linkMapping[itemDS.name + '---' + fieldItem];
        				console.log('initSteps: field name mapped', mainFieldName);
                    
                    	if ((mappedField) || (itemDS.name === datasetName)) {
        					console.log('initSteps: keeping step field', fieldAbsName);
                			let mainField = mappedField || fieldItem;
                            
                            //let mappedField = dsDesc.fields.dates.find(elt => mappedFieldName === elt.alias);
        					//		console.log('initSteps: mapping fetched', JSON.stringify(mappedField));
                        
                        	stepMapping[stepItem][fieldItem] = {
                            	field: mainField,
                        		type: "standard",
                        		operator: "in"
                        	}
                    	}
                    	else {
        					console.warn('initSteps: ignoring step field', fieldAbsName);
                    	}
                    }*/
	},
    doAdd2Campaign : function(component, event, helper) {
		console.log('doAdd2Campaign: START');
        
        component.set("v.isRunning",true);
        component.set("v.runStep","1");
        
        let analyticsDB = component.find("analyticsDB");
        console.log('doAdd2Campaign: analyticsDB found',analyticsDB);
        
        let config = {};
        analyticsDB.getState(
            config,
            $A.getCallback(function(stateData) {
                console.log('doAdd2Campaign: state received',JSON.stringify(stateData));

                let dashboardId = component.get("v.dashboardId");
        		console.log('doAdd2Campaign: dashboardId fetched', dashboardId);
        		let datasetId	= component.get("v.datasetId");
        		console.log('doAdd2Campaign: datasetId fetched', datasetId);
                let mapping = helper.MAPPINGS[dashboardId + '.' + datasetId];
        		console.log('doAdd2Campaign: mapping fetched', mapping);
                
        		/*let dsDesc = component.get("v.dsDesc");
        		console.log('doAdd2Campaign: dsDesc fetched',JSON.stringify(dsDesc));
                let dbDesc = component.get("v.dbDesc");
        		console.log('doAdd2Campaign: dbDesc fetched',JSON.stringify(dbDesc));
                let dsFieldDesc = component.get("v.dsFieldDesc");
        		console.log('doAdd2Campaign: dsFieldDesc fetched',JSON.stringify(dsFieldDesc));*/
                let mainDS = helper.DATASETS[datasetId];
        		console.log('doAdd2Campaign: mainDS fetched',JSON.stringify(mainDS));
                let idFieldName = component.get("v.idFieldName");                
        		console.log('doAdd2Campaign: idFieldName fetched',idFieldName);
        		let useGroup = component.get("v.useGroup");
				console.log('doAdd2Campaign: useGroup fetched ',useGroup); 
                
                let saqlQuery = helper.buildSAQL(stateData,mainDS,idFieldName,mapping,useGroup,helper);
                //let saqlQuery = helper.buildSAQL(stateData,dbDesc,dsDesc,dsFieldDesc,idFieldName,helper);
                component.set("v.saqlQuery",saqlQuery);
        		console.log('doAdd2Campaign: saqlQuery init ',saqlQuery);

        		let analyticsSDK = component.find("analyticsSDK");
        		console.log('doAdd2Campaign: analyticsSDK found',analyticsSDK);                
        		analyticsSDK.invokeMethod(
            		this.SDK_CONTEXT,
            		"executeQuery",
                    {"query": saqlQuery},
            		$A.getCallback(function(saqlErr, saqlData) {
                        component.set("v.runStep","2");
              			if (saqlErr !== null) {
                            //component.set("v.isRunning",false);
                            component.set("v.actionError", JSON.stringify(saqlErr));
                    		console.error("doAdd2Campaign: END SDK SAQL error received ", JSON.stringify(saqlErr));
              			}
                        else {
                    		console.log('doAdd2Campaign: SDK SAQL data received ',saqlData);
               				component.set("v.saqlResults",saqlData);
                            
                            let saqlJson = JSON.parse(saqlData);
                    		console.log('doAdd2Campaign: SDK SAQL data parsed ',saqlJson);  
                            if (saqlJson) component.set("v.saqlResults",saqlJson);
                            
                           	let saqlIdList = Array.from(helper.getSaqlIdSet(saqlJson,idFieldName));
                    		console.log('doAdd2Campaign: target ID list initialized from SAQL ',saqlIdList);
                            component.set("v.saqlIdList",saqlIdList);
                            
                            let recordId = component.get("v.recordId");
                    		console.log('doAdd2Campaign: campaign Id fetched ',recordId);
                            let memberType = component.get("v.memberType");
                    		console.log('doAdd2Campaign: member type fetched ',memberType);
                            
                            let soqlQuery = helper.buildSOQL(saqlIdList, memberType, recordId);
                    		console.log('doAdd2Campaign: soqlQuery init ',soqlQuery);
                            component.set("v.soqlQuery",soqlQuery);
                           
                            component.find('soqlUtil').runQuery(
                       			soqlQuery,
                               	true, // bypassFLS
                               	true, // bypassSharing
                               	"PEG_Add2Campaign",  // queryType
                               	false, // isStorable
                               	false, // isBackground
                       			function(queryResult,queryError) {
                          			console.log('doAdd2Campaign: result from SOQL query');
                                    component.set("v.runStep","3");
                                    
                          			if (queryResult) {
                              			console.log('doAdd2Campaign: queryResult received',queryResult);
                                        
                                        let soqlIdList = Array.from(helper.getSoqlIdSet(queryResult,saqlIdList,memberType));
                                        console.log('doAdd2Campaign: END target ID list filtered from SOQL ',soqlIdList);
                           				component.set("v.soqlIdList", soqlIdList);
                                    }
                                    else {
                                        //component.set("v.isRunning",false);
                                        component.set("v.actionError", JSON.stringify(queryError));
                                        console.log('doAdd2Campaign: END queryError received',queryError);
                                    }
                                });
                    		console.log('doAdd2Campaign: soql query sent');
              			}
            		})
        		);
        		console.log('doAdd2Campaign: executting SAQL query');                
     		})
        );
        console.log('doAdd2Campaign: fetching ');	
	},
    buildSAQL : function(dbState,mainDS,mainIdField,mapping,useGroup,helper) {
        console.log('buildSAQL: START');
        
        let query = 'q = load \"' + mainDS.id + '/' + mainDS.currentVersionId + '\";';
        console.log('buildSAQL: query root init',query);
        
        let filters = dbState.payload.state.datasets;
		console.log('buildSAQL: dashboard global filters fetched',JSON.stringify(filters));
		for (let filterItem in filters) {
			console.log('buildSAQL: processing filter ',JSON.stringify(filterItem));
			query += helper.getFilterSAQL(filterItem,filters[filterItem],mapping.filters,helper);
        }
		console.log('buildSAQL: global filter query filters added ',query);
        
        let steps = dbState.payload.state.steps;
		console.log('buildSAQL: query steps fetched',JSON.stringify(steps));            
		for (let stepItem in steps) {
			console.log('buildSAQL: processing step ',JSON.stringify(stepItem));
			query += helper.getStepSAQL(stepItem,steps[stepItem],mapping.steps,helper);
        }
		console.log('buildSAQL: steps query filters added ',query);    
        
        if (useGroup) {
            console.log('buildSAQL: adding group by statement');
			query	+= 'q = group q by \'' + mainIdField + '\';'
            		 + 'q = foreach q generate \'' + mainIdField + '\' as \''
            		 + mainIdField + '\', count() as \'count\';';
        }
        else {
            console.log('buildSAQL: END query finalized',query);
			query	+= 'q = foreach q generate \'' + mainIdField + '\';';
        }
        //query	+= 'q = foreach q generate \'' + mainIdField + '\';'
        
        query += 'q = limit q 10000;';
        console.log('buildSAQL: END query finalized',query);
        return query;
    },
    getStepSAQL : function(stepName,stepState,stepMapping,helper) {
        console.log('getStepSAQL: START for ',stepName);
        
        let stepMap = stepMapping[stepName];
        if (!stepMap) {
        	console.warn('getStepSAQL: END no step mapping for ',stepName);
          	return '';
        }
        console.log('getStepSAQL: step mapping fetched ',JSON.stringify(stepMap));
        
        if (stepState.values.length == 0) {
            console.warn('getStepSAQL: END no step filter values set for ',stepName);
          	return '';
        }
        
        if (stepState.metadata.groups.length == 1) {
            console.log('getStepSAQL: processing single filter');
            
            let singleStepMap = stepMap[stepState.metadata.groups[0]];
            console.log('getStepSAQL: single mapping fetched ', JSON.stringify(singleStepMap));
            
            switch(singleStepMap.type) {
  				case "date":
    				console.log('getStepSAQL: END for single standalone date filter ');
                    return helper.getDateFilter(singleStepMap.fields,stepState.values);
  				case "compound":
    				console.log('getStepSAQL: END for single compound date filter ');
                    return helper.getCompoundFilter(singleStepMap.fields,stepState.values);
  				default:
    				console.log('getStepSAQL: END for single standard filter ');
                    return helper.getStandardFilter(singleStepMap.field,stepState.values);                    
			}
        }
        else {
            console.log('getStepSAQL: END with multiple filters');
            return helper.getMultipleFilter(stepMap, stepState.metadata.groups, stepState.values);
        }        
    },
    getFilterSAQL : function(filterName,filterState,filterMapping,helper) {
        console.log('getFilterSAQL: START with ',filterName);
        
        let filterQuery = '';
        filterState.forEach(function(filterItem) {
        	console.log('getFilterSAQL: processing filter ',JSON.stringify(filterItem));
            let filterItemMap = filterMapping[filterName + '---' + filterItem.fields[0]];
        	if (filterItemMap) {
                if (filterItemMap.type === "date") {
                    if (filterItem.filter.values.length > 0) {
        				console.log('getFilterSAQL: adding date filter ',filterItemMap.field);
                    	filterQuery += helper.getDateFilter(filterItemMap.fields,filterItem.filter.values);
                    }
                    else {
        				console.log('getFilterSAQL: date filter not set');                        
                    }
                }
                else {
                    console.log('getFilterSAQL: adding standard filter',filterItemMap.field);
                    switch (filterItem.filter.operator) {
                        case "in":
                        case "not in":
                            if (filterItem.filter.values.length > 0) {
                    			console.log('getFilterSAQL: adding (not) in filter');
                            	filterQuery += 'q = filter q by \'' + filterItemMap.field + '\' '
            								+ filterItem.filter.operator 
                                    	    + ' [\"' + filterItem.filter.values.join('\", \"') + '\"];';
                            }
                            else {
                                console.log('getFilterSAQL: (not) in filter not set');
                            }
                            break;
                        case ">=<=":
                            if (filterItem.filter.values.length > 0) {
                            	console.log('getFilterSAQL: adding between filter');
                            	filterQuery += 'q = filter q by \'' + filterItemMap.field + '\' >= '
            								+ filterItem.filter.values[0]
                                        	+ ' && \'' + filterItemMap.field + '\' <= '
                                        	+ filterItem.filter.values[1] + ';';
                            }
                            else {
                                console.log('getFilterSAQL: between filter not set');
                            }
                            break;
                        case ">":
                        case ">=":
                        case "<":
                        case "<=":
 						case "==":
                        case "!=":
                            if (filterItem.filter.values.length > 0) {
                            	console.log('getFilterSAQL: adding single compare filter');
								filterQuery += 'q = filter q by \'' + filterItemMap.field + '\' '
            								+ filterItem.filter.operator + ' '
                                        	+ filterItem.filter.values[0] + ';';
                            }
                            else {
                            	console.log('getFilterSAQL: single compare filter not set');                                
                            }
                            break;
                        case "matches":
                            if (filterItem.filter.values.length > 0) {
                            	console.log('getFilterSAQL: adding match filter');
								filterQuery += 'q = filter q by \'' + filterItemMap.field + '\' '
            								+ filterItem.filter.operator + ' "'
                                        	+ filterItem.filter.values[0] + '";';
                            }
                            else {
                            	console.log('getFilterSAQL: match filter not set');                                
                            }
                            break;
                        case "is null":
                        case "is not null":
                            console.log('getFilterSAQL: adding is (not) null filter');
							filterQuery += 'q = filter q by \'' + filterItemMap.field + '\' '
            							+ filterItem.filter.operator + ';';
                            break;
                        default:
                            console.warn('getFilterSAQL: unsupported filter operator',filterItem.filter.operator);
                    }
                }
            }
            else {
        		console.warn('getStepSAQL: ignoring unmapped field ',filterItem.fields[0]);
            }
        });
        
        console.log('getFilterSAQL: END with ', filterQuery);
        return filterQuery;
    },
    getDateFilter : function(dateFields,filterValues) {
        console.log('getDateFilter: START');
        
        let filterQuery = 'q = filter q by date(\''
        					+ dateFields.year
        					+ '\', \'' + dateFields.month
        					+ '\', \'' + dateFields.day
        					+ '\') in [';
        console.log('getDateFilter: filterQuery initialized ',filterQuery);
                        
        let fromDate = filterValues[0][0];
        console.log('getDateFilter: fromDate ',fromDate);
        console.log('getDateFilter: fromDate type ',typeof fromDate);
        let toDate = filterValues[0][1];
        console.log('getDateFilter: toDate ',toDate);
        console.log('getDateFilter: toDate type ',typeof toDate);
                        
        if (typeof fromDate === 'number') {
            console.log('getDateFilter: processing epoch dates ');
            
            let fromDateDate = new Date(fromDate );
            console.log('getDateFilter: converted fromDate ',fromDateDate);
            let toDateDate = new Date(toDate );
            console.log('getDateFilter: converted toDateDate ',toDateDate);
                        	
			filterQuery += 'dateRange(['
            			+ fromDateDate.getFullYear() + ','
            			+ (fromDateDate.getMonth()+1) + ','
            			+ fromDateDate.getDate() + '],['
            			+ toDateDate.getFullYear() + ','
            			+ (toDateDate.getMonth()+1) + ','
            			+ toDateDate.getDate() + '])];';
        }
        else {
            console.log('buildSAQL: processing relative dates ');
            
            if (fromDate[1] == 0)			filterQuery += '"current ' + fromDate[0] + '".."'
            	else if (fromDate[1] == 1)	filterQuery += '"' + fromDate[1] + " " + fromDate[0] + ' ahead".."'
				else if (fromDate[1] == -1)	filterQuery += '"' + -fromDate[1] + " " + fromDate[0] + ' ago".."'
				else if (fromDate[1] > 1) 	filterQuery += '"' + fromDate[1] + " " + fromDate[0] + 's ahead".."'
				else filterQuery += '"' + -fromDate[1] + " " + fromDate[0] + 's ago".."';
                        
			if (toDate[1] == 0)				filterQuery += "current " + toDate[0] + '"];'
				else if (toDate[1] == 1)	filterQuery += toDate[1] + " " + toDate[0] + ' ahead"];'
				else if (toDate[1] == -1)	filterQuery += -toDate[1] + " " + toDate[0] + ' ago"];'
                else if (toDate[1] > 1)		filterQuery += toDate[1] + " " + toDate[0] + 's ahead"];'
				else filterQuery += -toDate[1] + " " + toDate[0] + 's ago"];';
		}
        
        console.log('getDateFilter: END with ',filterQuery);
    	return filterQuery;
    },
    getCompoundFilter : function(dateFields,filterValues) {
    	console.log('getCompoundFilter: START');
                        
        let criteriaParts = [];
        filterValues.forEach(function(valIter) {
            console.log('getCompoundFilter: processing date value ',valIter);
                            
            let valueParts = valIter.split('~~~');
            console.log('getCompoundFilter: date values parts extracted ',valueParts);
                            
            let criteriaSubParts = [];
            dateFields.forEach(function(fieldIter,index) {
                criteriaSubParts.push('\'' + fieldIter + '\' == \"' +  valueParts[index] + '\"');
            });
            criteriaParts.push('( ' + criteriaSubParts.join(' && ') + ' )');
        });
    
        let filterQuery = 'q = filter q by ( ' + criteriaParts.join(' || ') + ' );';
    	console.log('getCompoundFilter: END with ',filterQuery);
        return filterQuery;
    },
    getStandardFilter : function(field,filterValues) {
    	console.log('getStandardFilter: START for ',field);
                
        let filterQuery = '';
		if (filterValues.length == 1) {
            console.log('getStandardFilter: processing single == statement ');
            filterQuery = 'q = filter q by \'' + field
            			+  '\' == \"' + filterValues[0] + '\";';
        }
        else {
            console.log('getStandardFilter: processing IN statement ');
            filterQuery	= 'q = filter q by \'' + field
            			+  '\' in [\"' + filterValues.join('\", \"') + '\"];';
        }        
        
    	console.log('getStandardFilter: END with ',filterQuery);
        return filterQuery;
    },
    getMultipleFilter : function(stepMap,filterFields,filterValues) {
        console.log('getMultipleFilter: START');

    	let criteriaParts = [];
        filterValues.forEach(function(valIter) {
            console.log('getMultipleFilter: processing value ',valIter);

            let criteriaSubParts = [];
            filterFields.forEach(function(fieldIter,index) {
            	console.log('getMultipleFilter: processing field ',fieldIter);
                
                let fieldMap = stepMap[fieldIter];
            	if (fieldMap) {
            		console.log('getMultipleFilter: mapped field ',fieldMap);
                    
                	switch(fieldMap.type) {
  						case "date":
            				console.log('getMultipleFilter: ignoring date field ',fieldIter);
                            break;
                        case "compound":
            				console.log('getMultipleFilter: handling compound date field ',fieldIter);
                            let valueParts = valIter[index].split('~~~');
                            fieldMap.fields.forEach(function(fieldSubIter,subIndex) {
                                criteriaSubParts.push('\'' + fieldSubIter + '\' == \"' +  valueParts[subIndex] + '\"');
                            });
                            break;
                        default :
            				console.log('getMultipleFilter: handling standard field ',fieldIter);
                            criteriaSubParts.push('\'' + fieldMap.field + '\' == \"' +  valIter[index] + '\"');
                    }
                }
                else {
            		console.log('getMultipleFilter: ignoring unmapped field ',fieldIter);                    
                }
            });

            console.log('getMultipleFilter: all fields processed');
            criteriaParts.push('( ' + criteriaSubParts.join(' && ') + ' )');
        });
        
        let filterQuery = 'q = filter q by ( ' + criteriaParts.join(' || ') + ' );';
    	console.log('getMultipleFilter: END with ',filterQuery);
        return filterQuery;   
	},
    getSaqlIdSet : function(saqlResults,idFieldName) {
        console.log('getSaqlIdSet: START with result list size ', saqlResults.results.records.length);                          
                            
        let idSet = new Set();
        saqlResults.results.records.forEach(function(idIter) {
            //console.log('getSaqlIdSet: processing ID ',idIter);
            idSet.add(idIter[idFieldName]);
        });
        console.log('getSaqlIdSet: ID set init ',JSON.stringify(idSet));

        console.log('getSaqlIdSet: END with set size ',idSet.size);
        return idSet;
    },
    buildSOQL : function(targetIDList, memberType, campaignId) {
        console.log('buildSOQL: START');
        
        let soqlQuery = 'SELECT LeadOrContactId FROM CampaignMember WHERE CampaignId = \''
        	+ campaignId + '\' and LeadOrContactId in (\''
        	+ targetIDList.join('\', \'') + '\')';
        
        console.log('buildSOQL: END with query ',soqlQuery);
        return soqlQuery;
    },
    getSoqlIdSet : function(soqlResults,idList,memberType) {
        console.log('getSoqlIdSet: START with ID list size ', idList.length);                         
          
        let idSet = new Set(idList);
        console.log('getSoqlIdSet: idSet init',idSet);
        if (memberType == 'Contact') {
        	soqlResults.forEach(function(cmIter){
            	idSet.delete(cmIter.LeadOrContactId);
        	});
        }
        else {
            soqlResults.forEach(function(cmIter){
            	idSet.delete(cmIter.LeadOrContactId);
        	});
        }
        console.log('getSoqlIdSet: ID set init ',JSON.stringify(idSet));
        
        console.log('getSoqlIdSet: END with ID set size ',idSet.size);
        return idSet;
    },
    doAction : function(component,event,helper) {
        console.log('doAction: START');
        
        component.set("v.runStep","4");
        
        let soqlIdList = component.get("v.soqlIdList");
        console.log('doAction: soql Id List fetched ',soqlIdList);
        let memberType = component.get("v.memberType");
        console.log('doAction: member type fetched ',memberType);
        let recordId = component.get("v.recordId");
        console.log('doAction: recordId fetched ',recordId);
        
        if ((!soqlIdList) && (soqlIdList.length == 0)) {
        	console.warn('doAction: END no target IDs to add as campaign members!');    
            return;
        }
        
        let newCmList = [];
        if (memberType == 'Contact') {
        	soqlIdList.forEach(function(newCmIter) {
            	console.log('doAction: registering CM for ',newCmIter);
            	newCmList.push({
                	'ContactId' : newCmIter,
                	'CampaignId': recordId,
                	//'Status': "Sent",
                	'sobjectType': "CampaignMember"
            	});
        	});
        }
        else {
            soqlIdList.forEach(function(newCmIter) {
            	console.log('doAction: registering CM for ',newCmIter);
            	newCmList.push({
                	'LeadId' : newCmIter,
                	'CampaignId': recordId,
                	//'Status': "Sent",
                	'sobjectType': "CampaignMember"
            	});
        	});
        }
        console.log('doAction: new Members init',JSON.stringify(newCmList));

        component.find('soqlUtil').runDML(
            'insert',
            newCmList,
            function(dmlResult,dmlError) {
                console.log('doAction: result from DML');
                if (dmlResult) {
                    component.set("v.actionError",null);
                    component.set("v.isRunning",false);
                    console.log('doAction: END dmlResult received',dmlResult);
                }
                else {
                    component.set("v.actionError",JSON.stringify(dmlError));
                    console.log('doAction: END dmlError received',dmlError);
                }
            });
        console.log('doAction: DML sent');        
    }
})