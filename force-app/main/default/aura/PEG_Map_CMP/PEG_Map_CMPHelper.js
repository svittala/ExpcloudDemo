({
	fetchMapMarkers: function(component) {
        console.log('fetchMapMarkers: START');     
        let mapMarkersStr = component.get("v.mapMarkersStr");
        console.log('fetchMapMarkers: mapMarkersStr retrieved',mapMarkersStr);
        
        if (mapMarkersStr) {
           component.find('mergeUtil1').merge(
              mapMarkersStr,
              null,
              function(mergeResult,mergeError) {
                console.log('fetchMapMarkers: result from merge');
                if (mergeResult) {
                   console.log('fetchMapMarkers: mergeResult received',mergeResult);
                   let mapResults = JSON.parse(mergeResult) || [];
                   let mapMarkers = component.get('v.mapMarkers') || [];
                   mapMarkers = mapMarkers.concat(mapResults);
                   component.set('v.mapMarkers', mapMarkers);
                   component.set('v.unFilteredMapMarkers',mapMarkers);
                   console.log('fetchMapMarkers: mapMarkers init',mapMarkers);
                }
                else {
                   console.error('fetchMapMarkers: triggering merge error notification',JSON.stringify(mergeError));
                   component.find('notifUtil').showNotice({
                      "variant": "error",
                      "header": "Error in merge for '" + component.get("v.title") + "'!",
                      "message": JSON.stringify(mergeError)
                   });
                }
              }
            );
        } else {
            console.warn('fetchMapMarkers: no merge to do');
        }
        console.log('fetchMapMarkers: END');
    },
    fetchOtherLocations : function(component) {
        console.log('fetchOtherLocations: START'); 
        
        let locationQuery = component.get("v.locationQuery");
        console.log('fetchOtherLocations: locationQuery retrieved',locationQuery);
        
        if (locationQuery) {
        component.find('mergeUtil2').merge(
            locationQuery,
            null,
            function(mergeResult,mergeError) {
                console.log('fetchOtherLocations: result from merge');
                if (mergeResult) {
                   console.log('fetchOtherLocations: mergeResult received',mergeResult);
                   
                   component.find('soqlUtil').runQuery(
                       mergeResult,
                       component.get("v.bypassFLS"),
                       component.get("v.bypassSharing"),
                       component.get("v.queryType"),
                       component.get("v.isStorable"),
                       component.get("v.isBackground"),
                       function(queryResult,queryError) {
                           console.log('fetchOtherLocations: result from query');
                           if (queryResult) {
                               console.log('fetchOtherLocations: queryResult received',queryResult);
                               
                               let locationConfig = JSON.parse(component.get("v.locationConfigStr"));
                               console.log('fetchOtherLocations: locationConfig retrieved',locationConfig);
                               
                               let mapMarkers = component.get('v.mapMarkers') || [];
                               console.log('fetchOtherLocations: mapMarkers fetched',mapMarkers);
                               //mapMarkers.push("hello");
                               
                               queryResult.forEach(function(item){
                                   console.log('fetchOtherLocations: processing item',item);
                                   console.log(locationConfig.location.Latitude);
                                   console.log(locationConfig.location.Longitude);
                                   console.log(item[locationConfig.location.Latitude.field]);
                                   console.log(item[locationConfig.location.Longitude.field]);
                                   let marker = {"location":{}};
                                   if (locationConfig.location.Latitude && locationConfig.location.Longitude) {
                                       marker.location.Latitude  = item[locationConfig.location.Latitude.field];
                                       console.log('fetchOtherLocations: processing city',marker);
                                       marker.location.Longitude    = item[locationConfig.location.Longitude.field];
                                   }
                                   marker.location.Street  = item[locationConfig.location.Street.field]
                                                           || locationConfig.location.Street.value;
                                   console.log('fetchOtherLocations: processing city',marker);
                                   marker.location.City    = item[locationConfig.location.City.field]
                                                           || locationConfig.location.City.value;
                                   console.log('fetchOtherLocations: processing city',marker);
                                   marker.location.Country =  item[locationConfig.location.Country.field]
                                                           || locationConfig.location.Country.value;
                                   console.log('fetchOtherLocations: processing country',marker);
                                   marker.icon             = item[locationConfig.icon.field]
                                                           || locationConfig.icon.value;
                                   console.log('fetchOtherLocations: processing icon',marker);
                                   marker.title            = item[locationConfig.title.field]
                                                           || locationConfig.title.value;
                                   console.log('fetchOtherLocations: processing title',marker);
                                   marker.description      = item[locationConfig.description.field]
                                                           || locationConfig.description.value;
                                   console.log('fetchOtherLocations: processing description',marker);
                                   marker.value			   = item[locationConfig.value.field]
                                                           || locationConfig.value.value;
                                   console.log('fetchOtherLocations: processing value',marker);
                                   
                                   console.log('fetchOtherLocations: adding marker',marker);
                                   mapMarkers.push(marker);
                               });
                               console.log('fetchOtherLocations: mapMarkers updated',mapMarkers);
                               
                               component.set('v.mapMarkers',mapMarkers);
                               component.set('v.unFilteredMapMarkers',mapMarkers);
                               console.log('fetchOtherLocations: mapMarkers saved');
                           } else {
                               console.error('fetchOtherLocations: triggering query error notification',JSON.stringify(queryError));
                               component.find('notifUtil').showNotice({
                                  "variant": "error",
                                  "header": "Error in query for '" + component.get("v.title") + "'!",
                                  "message": JSON.stringify(queryError)
                               });
                           }
                       }
                   );
                } else {
                   console.error('fetchOtherLocations: triggering merge error notification',JSON.stringify(error));
                   component.find('notifUtil').showNotice({
                      "variant": "error",
                      "header": "Error in merge for '" + component.get("v.title") + "'!",
                      "message": JSON.stringify(mergeError)
                   });
                }
            }
        );
        }
        
        console.log('fetchOtherLocations: END'); 
    },
    filterTheRecords : function(component){
        
        let unFiltereddata = component.get("v.unFilteredMapMarkers"),
            filteredValueList = [],
            searchText = component.get("v.searchText"),
            num = 0;
        Object.values(unFiltereddata).forEach(val => {
           
            if (val.title.toLowerCase().includes(searchText.toLowerCase()) || val.description.substring(val.description.lastIndexOf(':')+ 1).toLowerCase().includes(searchText.toLowerCase()) ){
            num ++ ;
            if (searchText.toLowerCase() == 'male' && !val.description.substring(val.description.lastIndexOf(':')+ 1).toLowerCase().includes(' male ') ){
            return;
        }
            filteredValueList.push(val);
        }}); 
       
        console.log('Number of Records Matching with the searchKey and the filtered Record List: ',num,JSON.stringify(filteredValueList));
        if (filteredValueList != undefined || filteredValueList.length > 0){
       		component.set('v.mapMarkers',filteredValueList);     
        }else{
            console.log('No search result found');
            alert('No search Result found');
        }
        filteredValueList =[];
    }
})