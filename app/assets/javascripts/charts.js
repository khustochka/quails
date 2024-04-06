//= require jquery.canvasjs.min


$(function () {
  var data = $("#chartContainer").data("series");

  function convertData(val) {
    // casting to a fake year because we want to show different years below one another
    return {x: new Date(2000, val[0][0] - 1, val[0][1]), y: parseInt(val[1])}
  }

  function buildChart() {
    var chart = new CanvasJS.Chart("chartContainer", {

      title: {
        text: "Species Progress"
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
      data: $.map(data, function (value, key) {
        return {
          type: "stepLine",
          lineThickness: 1,
          name: key,
          showInLegend: true,
          xValueFormatString: "MMM D",
          dataPoints: $.map(value, convertData)
        }
      })
    });
    chart.render();
  }

  buildChart(data);
});
