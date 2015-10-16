//= require jquery.canvasjs.min


$(function () {
   function buildChart() {
      var chart = new CanvasJS.Chart("chartContainer2014", {

        title: {
            text:  "2014-2015 Species Progress"
        },
        axisY: {
            interval: 50
        },

        axisX: {
            valueFormatString: "MMM D"
        },
        toolTip:{
                          shared:true
                        },
        data: [
            {
                type: "stepLine",
                lineThickness: 1,
                name: "2014",
                dataPoints: $.map(data[0], function (val) {
                    return {x: new Date(parseInt(val[0]) * 1000), y: parseInt(val[1])}
                })
            },
             {
                  type: "stepLine",
                  lineThickness: 1,
                  name: "2015",
                  dataPoints: $.map(data[1], function (val) {
                      return {x: new Date(parseInt(val[0]) * 1000 - 31536000000), y: parseInt(val[1])}
                  })
              }
        ]
    });
    chart.render();
    }
    buildChart();
});
