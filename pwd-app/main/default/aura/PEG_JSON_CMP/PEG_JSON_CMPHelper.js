({
	sortBy: function (field, reverse, primer) {
        var key = primer ?
            function(x) {return primer(x[field])} :
            function(x) {return x[field]};
        //checks if the two rows should switch places
        reverse = !reverse ? 1 : -1;
        return function (a, b) {
            return a = (key(a) || ''), b = (key(b) || ''), reverse * ((a > b) - (b > a));
        }
    },
    flattenJsonObject: function (jsonObject,jsonChildren,helper) {
        //console.log('flattenJsonObject: START', jsonObject);
        
        for (var fieldName in jsonObject) {
           //console.log('flattenJsonObject: analysing fieldName',fieldName);
            
           if (typeof jsonObject[fieldName] == 'object'){
               //console.log('flattenJsonObject: processing subObject', jsonObject[fieldName]);
               
               if ((jsonObject[fieldName]).constructor === [].constructor) {
                   console.log('flattenJsonObject: flattening list',fieldName);
                   //helper.flattenJsonList(jsonObject[fieldName],null,helper);
                   helper.flattenJsonList(jsonObject[fieldName],jsonChildren,helper);
                   console.log('flattenJsonObject: subList after flatten step 1', jsonObject[fieldName]);
                   
                   jsonObject[fieldName + '._length'] = jsonObject[fieldName].length;
                   console.log('flattenJsonObject: list _length added',jsonObject[fieldName].length);
                   
                   if ((jsonChildren) && (jsonChildren.includes(fieldName))) {
                      console.log('flattenJsonObject: replacing list field by _children',fieldName);
                      jsonObject['_children'] = jsonObject[fieldName];
                      delete jsonObject[fieldName];
                   } else {
                       console.log('flattenJsonObject: list field not in children',jsonChildren);
                   }
                   
               } else {
                   //console.log('flattenJsonObject: flattening subObject');
                   helper.flattenJsonObject(jsonObject[fieldName],null,helper);
                   //console.log('flattenJsonObject: subObject after flatten step 1', jsonObject[fieldName]);
               
                   for (var subFieldName in jsonObject[fieldName]) {
                    if (typeof jsonObject[fieldName][subFieldName] == 'object'){
                        //console.log('flattenJsonObject: removing object sub-field',subFieldName);
                        //if (subFieldName == '' ) recordItem._children = recordItem[gridFieldName];
                        //_children working
                        /*
                        if ((jsonChildren) && (jsonChildren.contains(subFieldName))) {
                            console.log('flattenJsonObject: replacing object sub-field by _children',subFieldName);
                            jsonObject[fieldName]['_children'] = jsonObject[fieldName][subFieldName];
                            delete jsonObject[fieldName][subFieldName];
                        }
                        */
                    } else {
                        //console.log('flattenJsonObject: moving non-object sub-field',subFieldName);
                        //console.log('flattenJsonObject: initializing field',fieldName + '.' + subFieldName);
                        jsonObject[fieldName + '.' + subFieldName] = jsonObject[fieldName][subFieldName];
                        delete jsonObject[fieldName][subFieldName];
                    }
                  }
                  delete jsonObject[fieldName];
                }
               
                //console.log('flattenJsonObject: subObject after flatten step 2',jsonObject[fieldName]);
            } else if (typeof jsonObject[fieldName] == 'boolean'){
                
                //console.log('flattenJsonObject: converting boolean field',fieldName);
                jsonObject[fieldName] = jsonObject[fieldName].toString();
            } else {
                //console.log('flattenJsonObject: ignoring standard field',fieldName);
            }
        }
        
        //console.log('flattenJsonObject: END', jsonObject);
        return;
    },
    flattenJsonList: function (jsonList,jsonChildren,helper) {
        //console.log('flattenJsonList: START',jsonList);
        jsonList.forEach(function(listItem){
            //console.log('flattenJsonList: analysing recordItem',listItem);
            helper.flattenJsonObject(listItem,jsonChildren,helper);
        });
        //console.log('flattenJsonList: END',jsonList);
        return jsonList;
    },
    transposeJson : function(jsonList){
        console.log('transposeJson START',jsonList);
        
        if (! jsonList) {
            console.error('transposeJson bad jsonList input',jsonList);
            return null;
        }
        
        let jsonTarget = {};
        let jsonFields = new Set();
        jsonList.forEach(function(row){
            Object.keys(row).forEach(function(field){
                jsonFields.add(field);
            });
        });
        console.log('transposeJson jsonFields extracted',jsonFields);
        
        jsonFields.forEach(function(fieldItem) {
            jsonTarget[fieldItem] = [];
        });
        console.log('transposeJson jsonTarget initialized',jsonTarget);
        
        jsonList.forEach(function(jsonItem) {
            //console.log('transposeJson processing jsonItem',jsonItem);
            
            jsonFields.forEach(function(fieldItem) {
                jsonTarget[fieldItem].push(jsonItem[fieldItem]);
            });
            //console.log('transposeJson jsonTarget updated',jsonTarget);
        });

        console.log('transposeJson END',jsonTarget);
        return jsonTarget;
    },
    REFERENCE_COLORS : {
        'account'     : 'rgb(127, 141, 225)',
        'address'     : 'rgb(75, 192, 118)',
        'session'     : 'rgb(248, 137, 96)',
        'action'      : 'rgb(88, 118, 163)',
        'announcement': 'rgb(98, 183, 237)',
        'branch'      : 'rgb(233, 105, 110)',
        'answer'      : 'rgb(242, 207, 91)',
        'grey'        : 'rgb(184, 195, 206)',      
        'apps'        : 'rgb(60, 151, 221)',
        'brand'       : 'rgb(126, 139, 228)',
        'calibration' : 'rgb(71, 207, 210)',
        'canvas'      : 'rgb(129, 153, 175)',
        'coaching'    : 'rgb(246, 117, 148)',
        'program'     : 'rgb(14, 181, 138)',
        'choice'      : 'rgb(84, 105, 141)',
        'client'      : 'rgb(0, 210, 190)',
        'cms'         : 'rgb(136, 198, 81)',       
        'contact'     : 'rgb(152, 149, 238)',
        'campaign'    : 'rgb(244, 151, 86)',
        'contract'    : 'rgb(110, 192, 110)',
        'currency'    : 'rgb(150, 148, 146)',
        'decision'    : 'rgb(255, 154, 60)',       
        'custom'      : 'rgb(129, 153, 175)',
        'datadotcom'  : 'rgb(21, 137, 238)',
        'dashboard'   : 'rgb(239, 110, 100)',
        'integration' : 'rgb(42, 115, 158)',
        'case'        : 'rgb(242, 207, 91)',
        'event'       : 'rgb(235, 112, 146)',
        'document'    : 'rgb(186, 172, 147)',
        'draft'       : 'rgb(108, 161, 233)',
        'email'       : 'rgb(149, 174, 197)',
        'entity'      : 'rgb(248, 137, 98)',
        'endorsement' : 'rgb(139, 154, 227)', 
        'filter'      : 'rgb(21, 57, 238)',
        'home'        : 'rgb(239, 126, 173)',
        'household'   : 'rgb(0, 175, 160)',
        'goals'       : 'rgb(86, 170, 223)',
        'knowledge'   : 'rgb(236, 148, 237)',
        'lead'        : 'rgb(248, 137, 98)',
        'individual'  : 'rgb(60, 151, 221)',
        'log_a_call'  : 'rgb(72, 195, 204)',
        'link'        : 'rgb(122, 154, 230)',
        'maintenance' : 'rgb(42, 115, 158)',
        'opportunity' : 'rgb(252, 185, 91)',
        'orders'      : 'rgb(118, 158, 217)',
        'outputs'     : 'rgb(67, 156, 186)',
        'partners'    : 'rgb(14, 181, 138)',
        'password'    : 'rgb(150, 148, 146)',
        'people'      : 'rgb(52, 190, 205)',
        'photo'       : 'rgb(215, 209, 209)',
        'portal'      : 'rgb(174, 199, 112)',
        'product'     : 'rgb(183, 129, 211)',
        'queue'       : 'rgb(84, 105, 141)',
        'quip'        : 'rgb(211, 69, 29)',
        'quotes'      : 'rgb(136, 198, 81)',
        'recent'      : 'rgb(108, 161, 233)',
        'relationship': 'rgb(60, 151, 221)',
        'report'      : 'rgb(46, 203, 190)',
        'reward'      : 'rgb(233, 105, 110)',
        'return_order': 'rgb(0, 150, 136)',
        'search'      : 'rgb(98, 183, 237)',
        'shipment'    : 'rgb(126, 139, 228)',
        'skill'       : 'rgb(250, 151, 92)',
        'sms'         : 'rgb(136, 198, 81)',
        'social'      : 'rgb(234, 116, 162)',
        'sossession'  : 'rgb(84, 105, 141)',
        'survey'      : 'rgb(49, 159, 214)',
        'task'        : 'rgb(75, 192, 118)',
        'today'       : 'rgb(239, 126, 173)',
        'topic'       : 'rgb(86, 170, 223)',
        'trailhead'   : 'rgb(75, 139, 68)',
        'work_order'  : 'rgb(80, 227, 194)'
    },
    getColors : function(number) {
        console.log('getColors: START for number',number);
        
	    while ((this.REFERENCE_COLORS).length < number) {
            console.log('getColors: extending reference list');
            Array.prototype.push.apply(this.REFERENCE_COLORS,
                                       this.REFERENCE_COLORS);    
       }
        
       //console.log('getColors: colors',Object.values(this.REFERENCE_COLORS));
       console.log('getColors: END');
       return (Object.values(this.REFERENCE_COLORS)).slice(0,number);  
	}
})