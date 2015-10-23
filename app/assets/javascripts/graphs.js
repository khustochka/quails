//= require jquery.canvasjs.min


$(function () {
  function convertData(val) {
    // casting to a fake year because we want to show different years below one another
    return {x: new Date(2000, val[0][0] - 1, val[0][1]), y: parseInt(val[1])}
  }

  function buildChart() {
    var chart = new CanvasJS.Chart("chartContainer", {

      title: {
        text: "2014-2015 Species Progress"
      },
      axisY: {
        interval: 50
      },

      axisX: {
        valueFormatString: "MMM D"
      },
      toolTip: {
        shared: true
      },
      data: [
        {
          type: "stepLine",
          lineThickness: 1,
          name: "2014",
          dataPoints: $.map(data[0], convertData)
        },
        {
          type: "stepLine",
          lineThickness: 1,
          name: "2015",
          dataPoints: $.map(data[1], convertData)
        }
      ]
    });
    chart.render();
  }

  buildChart();
});
