//= require gmap3

$(function () {

  if (typeof google == 'object') {

    $(document).gmap3({
          defaults: {
            map: {
              //center: [48.2837, 31.62962],
              //zoom: 6,
              mapTypeId: google.maps.MapTypeId.HYBRID,
              // mapTypeControlOptions: {
              //   position: google.maps.ControlPosition.TOP_LEFT
              // },
              streetViewControl: false,
              gestureHandling: "greedy",
              // panControlOptions: {
              //   position: google.maps.ControlPosition.TOP_RIGHT
              // },
              // zoomControlOptions: {
              //   position: google.maps.ControlPosition.TOP_RIGHT
              // }
            }
          }
        }
    );
  }

  window.mapEnabled = $("#googleMap[data-map-enabled]").length > 0;
});
