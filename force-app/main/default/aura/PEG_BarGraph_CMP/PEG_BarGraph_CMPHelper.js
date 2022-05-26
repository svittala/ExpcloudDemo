({
	displayGraph : function (component,results) {
        console.log('displayGraph: START');
        
        let dimension = component.get("v.dimension");
        console.log('displayGraph: main dimension fetched',dimension);
        let subDimension = component.get("v.subDimension");
        console.log('displayGraph: subDimension fetched',subDimension);
        let measure = component.get("v.measure");
        console.log('displayGraph: measure fetched',measure);
        let measure2 = component.get("v.measure2");
        console.log('displayGraph: measure2 fetched',measure2);
        let data = component.get("v.data");
        console.log('displayGraph: data fetched',JSON.stringify(data));
        
         
        let colorList = component.find('jsonUtil').getColors((data[dimension]).length);
        console.log('displayGraph: colorList initialized',colorList);
            
        
        let chartData = {};
        
        if (subDimension) {
            console.log('displayGraph: setting chartData with subDimension');
            let sdValues = new Set();
            let sdName;
            (data[subDimension]).forEach(function(row){
               sdName = row || 'Undefined';
               console.log('loadData: processing sdName',sdName);
               sdValues.add(sdName);
            });
            console.log('loadData: sdValues extracted',sdValues);
            sdValues = Array.from(sdValues);
            console.log('loadData: sdValues set converted',sdValues);
            
            let dValues = {};
            let dName;
            (data[dimension]).forEach(function(row){
                dName = row || 'Undefined';
                console.log('loadData: processing dName',dName);
                if (! dValues[dName]){                    
                    dValues[dName] = (sdValues.slice(0)).fill(0);
                    console.log('loadData: adding new dataset',dValues[dName]);
                }
            });
            console.log('loadData: dValues extracted',dValues);       
            
            let sdIndex, dimName;
            (data[measure]).forEach(function(row, iter){
                console.log('loadData: processing measure',row, iter);
                sdIndex = sdValues.indexOf((data[subDimension])[iter] || 'Undefined');
                console.log('loadData: sub-dimension index determined',sdIndex);
                dimName = (data[dimension])[iter] || 'Undefined';
                console.log('loadData: dimName value determined',dimName);
                (dValues[dimName])[sdIndex] = row;
                console.log('loadData: dValues updated',dValues);
            });
            console.log('loadData: dValues init',dValues);
                      
            chartData = {
              'labels': sdValues,
              'datasets':[]
            };
            console.log('loadData: chartData init',chartData);
            let index =  0;
            for (let iterD in dValues) {
                console.log('loadData: pushing data for dValue',iterD,index);
                chartData.datasets.push({
                  'label' : iterD,
                  'data'  : dValues[iterD],
                  'backgroundColor': colorList[index],
                  'borderColor': "white",
                  'fill': true,
                  'pointBackgroundColor': "#FFFFFF",
                  'pointBorderWidth': 0,
                  'pointHoverRadius': 5,
                  'pointRadius': 3,
                  'bezierCurve': true,
                  'pointHitRadius': 10
                });
                index++;
            };
            
            if (measure2) {
                console.log('displayGraph: ignoring second measure');
            }
        } else {
          let barGraphData = '';
          let dataGenderList = data[dimension];
          let dataNumberList = data[measure];
          dataGenderList.forEach(function(item, index){
            barGraphData = barGraphData + item + dataNumberList[index] + ',';
          });
            console.log('displayGraph: setting chartData with no subDimension');
            component.set("v.barGraphData", barGraphData);
            chartData = {
              'labels': data[dimension],
              'datasets': [
              {
               'label' : measure,
               'data' : data[measure],
                //'backgroundColor': colorList,
               'backgroundColor': colorList[0],
               'borderColor': "white",
               'fill': true,
               'pointBackgroundColor': "#FFFFFF",
               'pointBorderWidth': 0,
               'pointHoverRadius': 5,
               'pointRadius': 3,
               'bezierCurve': true,
               'pointHitRadius': 10
              }]};
       
            if (measure2) {
              chartData.datasets.push(
              { 
               'label' : measure2,
               'data' : data[measure2],
                //'backgroundColor': colorList,
               'backgroundColor': colorList[1],
               'borderColor': "white",
               'fill': false,
               'pointBackgroundColor': "#FFFFFF",
               'pointBorderWidth': 0,
               'pointHoverRadius': 5,
               'pointRadius': 3,
               'bezierCurve': true,
               'pointHitRadius': 10
              });      
            }
        }
        console.log('displayGraph: chartData preset',chartData);
        
        let graphCanvas = component.find("GraphCanvas").getElement();
        console.log('displayGraph: Graph Canvas element fetched',graphCanvas);
        
        let graphType = component.get("v.graphType");
        console.log('displayGraph: graphType fetched',graphType);
        let legendPosition = component.get("v.legendPosition");
        console.log('displayGraph: legendPosition fetched',legendPosition);
        let title = component.get("v.title");
        console.log('displayGraph: title fetched',title);
        
        let displayChart;
        if (graphType == 'bar') {
            displayChart = new Chart( graphCanvas , {
               "type": graphType,
               "data": chartData,
               "options": {	
                   "responsive": true,
                   'legend': { 'display': false },
                   "animation" : {'animateScale': true, 'animateRotate': true },
                   "title": { "position": 'top', "display" : false, "text" : title },
                   'tooltips' : { 'position': 'average', 'mode': 'point', 'intersect': false },
                   'hover' : { 'mode' : 'point', 'intersect': false },
                   'scales': {
                      'xAxes': [{
                        'type'   : 'category', 'display': true,
                        'stacked': true,
                        'ticks'  : {'autoSkip': false } }],
                      'yAxes': [{
                        'type' : 'linear', 'display': true,
                        'stacked': true,
                        'ticks': {'beginAtZero' : true, 'min' : 0 } }]
                   }
               }
            });
        } else if (graphType == 'line') {
            displayChart = new Chart( graphCanvas , {
               "type": graphType,
               "data": chartData,
               "options": {	
                   "responsive": true,
                   'legend': { 'display': false },
                   "animation" : {'animateScale': true, 'animateRotate': true },
                   "title": { "position": 'top', "display" : false, "text" : title },
                   'tooltips' : { 'position': 'average', 'mode': 'point', 'intersect': false },
                   'hover' : { 'mode' : 'point', 'intersect': false },
                   'elements': {'line': { 'tension': 0 } },
                   'scales': {
                      'xAxes': [{
                        'type'   : 'category', 'display': true,
                        'stacked': true,
                        'ticks'  : {'autoSkip': false } }],
                      'yAxes': [{
                        'type' : 'linear', 'display': true,
                        'stacked': true,
                        'ticks': {'beginAtZero' : true, 'min' : 0 } }]
                   }
               }
            });
        }
        else {
           displayChart = new Chart( graphCanvas , {
              "type": graphType,
               "data": chartData,
               "options": {	
                   "responsive": true,
                   'legend': { 'display': false },
                   "animation" : {'animateScale': true, 'animateRotate': true },
                   "title": { "position": 'top', "display" : false, "text" : title },
                   'tooltips' : { 'position': 'average', 'mode': 'point', 'intersect': false },
                   'hover' : { 'mode' : 'point', 'intersect': false },
                   'scales': {
                      'yAxes': [{
                        'type' : 'category', 'display': true,
                        'stacked': true,
                        'ticks': {'autoSkip': false } }],
                      'xAxes': [{
                        'type' : 'linear', 'display': true,
                        'stacked': true,
                        'ticks': {'beginAtZero' : true, 'min' : 0 } }]
                   }
               }
            });
        }
        console.log('displayGraph chart instantiated',displayChart);
        
        console.log('displayGraph: END');
    }
})