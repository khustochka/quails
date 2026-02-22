import CanvasJS from '@canvasjs/charts';

document.addEventListener('DOMContentLoaded', function () {
  const container = document.getElementById('chartContainer');
  if (!container) return;

  const data = JSON.parse(container.dataset.series);

  function convertData(val) {
    return { x: new Date(2000, val[0][0] - 1, val[0][1]), y: parseInt(val[1]) };
  }

  const chart = new CanvasJS.Chart('chartContainer', {
    title: { text: 'Species Progress' },
    axisY: { interval: 50 },
    axisX: { valueFormatString: 'MMM D' },
    toolTip: { shared: true },
    data: Object.entries(data).map(([key, value]) => ({
      type: 'stepLine',
      lineThickness: 1,
      name: key,
      showInLegend: true,
      xValueFormatString: 'MMM D',
      dataPoints: value.map(convertData)
    }))
  });

  chart.render();
});
