//= require jquery.canvasjs.min


$(function () {

    var chart = new CanvasJS.Chart("chartContainer", {

        title: {
            text: "2014 Species Progress"
        },
        axisY: {
            interval: 50
        },

        axisX: {
            valueFormatString: "MMM D"
        },

        data: [
            {
                type: "stepLine",
                lineThickness: 1,
                dataPoints: $.map(data, function (val) {
                    return {x: new Date(parseInt(val[0]) * 1000), y: parseInt(val[1])}
                })
            }
        ]
    });
    chart.render();

});
