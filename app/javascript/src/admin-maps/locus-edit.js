import { createMap, autofitMarkers, panToLocus } from "./map-init";

export function initLocusEdit(mapEl) {
  var latField = document.getElementById("locus_lat");
  var lngField = document.getElementById("locus_lon");
  var currentMarker = null;

  mapEl.style.height = "250px";

  function updateGeoFields(latLng) {
    latField.value = latLng.lat();
    lngField.value = latLng.lng();
  }

  function addMarker(map, latLng) {
    if (currentMarker) currentMarker.setMap(null);
    currentMarker = new google.maps.Marker({
      position: latLng,
      map: map,
      draggable: true
    });
    currentMarker.addListener("dragend", function (e) {
      updateGeoFields(e.latLng);
    });
  }

  var map = createMap(mapEl, { draggableCursor: "pointer" });

  map.addListener("click", function (e) {
    addMarker(map, e.latLng);
    updateGeoFields(e.latLng);
  });

  var lat = latField.value, lng = lngField.value;

  if (lat && lng) {
    addMarker(map, new google.maps.LatLng(lat, lng));
    autofitMarkers(map, [currentMarker], 13);
  } else {
    var parentSelect = document.querySelector("select[name='locus[parent_id]']");
    if (parentSelect.value) panToLocus(map, parentSelect.value);
  }

  document.querySelector("select[name='locus[parent_id]']").addEventListener("change", function () {
    if (this.value) panToLocus(map, this.value);
  });
}
