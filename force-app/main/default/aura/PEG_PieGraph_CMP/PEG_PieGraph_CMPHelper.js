({
    displayGraph : function (component,results) {
        console.log('displayGraph: START');
        
        let dimension = component.get("v.dimension");
        console.log('displayGraph: dimension fetched',dimension);
        let measure = component.get("v.measure");
        console.log('displayGraph: measure fetched',measure);
        let data = component.get("v.data");
        console.log('displayGraph: data fetched',JSON.stringify(data));
        
        let colorList = component.find('jsonUtil').getColors((data[dimension]).length);
        console.log('displayGraph: colorList initialized',colorList);
            
        let chartData = {
            'labels': data[dimension],
            'datasets': [{
               'label': measure,
               'data' : data[measure],
               'backgroundColor': colorList,
               'borderColor': "white",
               'fill': false,
               'pointBackgroundColor': "#FFFFFF",
               'pointBorderWidth': 0,
               'pointHoverRadius': 5,
               'pointRadius': 3,
               'bezierCurve': true,
               'pointHitRadius': 10
           }]};
        console.log('displayGraph: chartData preset',chartData);
       
        let graphCanvas = component.find("GraphCanvas").getElement();
        console.log('displayGraph: Graph Canvas element fetched',graphCanvas);
        
        let graphType = component.get("v.graphType");
        console.log('displayGraph: graphType fetched',graphType);
        let legendPosition = component.get("v.legendPosition");
        console.log('displayGraph: legendPosition fetched',legendPosition);
        let title = component.get("v.title");
        console.log('displayGraph: title fetched',title);
        
        let displayChart = new Chart( graphCanvas , {
           "type": graphType,
           "cutoutPercentage":10,
           "data": chartData,
           "options": {	
               "legend": { "display": false },
               "responsive": true,
               //"maintainAspectRatio" : true, 
               "animation" : {'animateScale': true, 'animateRotate': true },
               "title": { "display" : false },
               'tooltips' : {
                    'position' : 'average',
                    'mode'     : 'point',
                    'intersect': false
                },
                'hover' : {
                    'mode'     : 'point',
                    'intersect': false
                }
            }
        });
        console.log('displayGraph: pieChart instantiated',displayChart);
        
        console.log('displayGraph: END');
    }
})