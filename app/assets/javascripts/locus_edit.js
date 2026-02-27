//= require map_init

$(function () {

  function panToLocus(map, loc_id) {
    fetch('/loci/' + loc_id + '.json')
      .then(function (r) { return r.json(); })
      .then(function (data) {
        var lat = data['lat'], lon = data['lon'];
        if (lat != null && lon != null) {
          $(map).gmap3("get").setCenter(new google.maps.LatLng(lat, lon));
          $(map).gmap3("get").setZoom(13);
        }
      });
  }

  function updateGeoFields(latLng) {
    document.getElementById('locus_lat').value = latLng.lat();
    document.getElementById('locus_lon').value = latLng.lng();
  }

  function addMarker(map, latLng) {
    $(map).gmap3({
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


  var lat = document.getElementById('locus_lat').value,
    lng = document.getElementById('locus_lon').value,
    theMap = document.getElementById('googleMap');

  theMap.style.height = '250px';

  if (window.mapEnabled) {
    $(theMap).gmap3({
      map: {
        events: {
          click: function (map, event) {
            var latLng = event.latLng,
              marker = $(theMap).gmap3({ get: "marker" });
            if (typeof (marker) != 'undefined') marker.setMap(null);
            addMarker(map, latLng);
            updateGeoFields(latLng);
          }
        }
      }
    });

    if (lat && lng) {
      addMarker(theMap, new google.maps.LatLng(lat, lng));
      $(theMap).gmap3({
        autofit: { maxZoom: 13 }
      });
    } else {
      var parentLocId = document.querySelector("select[name='locus[parent_id]']").value;
      if (parentLocId) panToLocus(theMap, parentLocId);
    }

    document.querySelector("select[name='locus[parent_id]']").addEventListener("change", function () {
      var loc_id = this.value;
      if (loc_id.length > 0) panToLocus(theMap, loc_id);
    });
  }
});
