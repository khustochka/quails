//= require suggest_over_combo
//= require map_init

$(function () {

  var theMap = $('#googleMap');

  theMap.height("250px");

  theMap.gmap3({
    map: {
      events: {
        click: function (map, event) {
          var latLng = event.latLng,
              marker = theMap.gmap3({get: "marker"});
          if (typeof(marker) != 'undefined') marker.setMap(null);
          addMarker(latLng);
          updateGeoFields(latLng);
        }
      }
    }
  });

  var lat = $("#locus_lat").val(),
      lng = $("#locus_lon").val();

  function updateGeoFields(latLng) {
    $("#locus_lat").val(latLng.lat());
    $("#locus_lon").val(latLng.lng());
  }

  function addMarker(latLng) {
    theMap.gmap3({
      marker: {
        latLng: latLng,
        options: {
          draggable: true
        },
        events: {
          dragend: function (marker, event, data) {
            updateGeoFields(event.latLng);
          }
        }
      }
    });
  }

  if (lat && lng) {
    addMarker(new google.maps.LatLng(lat, lng));
    theMap.gmap3({
      autofit: {maxZoom: 13}
    });
  }

});
