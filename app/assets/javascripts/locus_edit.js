//= require map_init

$(function () {

  function panToLocus(loc_id) {
    $.get('/loci/' + loc_id + '.json', function (data) {
      var lat = data['lat'], lon = data['lon'];
      if (lat != null && lon != null) {
        theMap.gmap3("get").setCenter(new google.maps.LatLng(lat, lon));
        theMap.gmap3("get").setZoom(13);
      }
    });
  }

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

  var theMap = $('#googleMap');

  theMap.height("250px");

  if (window.mapEnabled) {
    theMap.gmap3({
      map: {
        events: {
          click: function (map, event) {
            var latLng = event.latLng,
              marker = theMap.gmap3({get: "marker"});
            if (typeof (marker) != 'undefined') marker.setMap(null);
            addMarker(latLng);
            updateGeoFields(latLng);
          }
        }
      }
    });

    if (lat && lng) {
      addMarker(new google.maps.LatLng(lat, lng));
      theMap.gmap3({
        autofit: {maxZoom: 13}
      });
    } else {
      var parentLocId = document.querySelector("select[name='locus[parent_id]']").value;
      if (parentLocId) panToLocus(parentLocId);
    }

    document.querySelector("select[name='locus[parent_id]']").addEventListener("change", function () {
      var loc_id = this.value;
      if (loc_id.length > 0) panToLocus(loc_id);
    });
  }
});
