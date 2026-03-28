import { setOptions, importLibrary } from "@googlemaps/js-api-loader";

var mapsPromise = null;

export function loadGoogleMaps() {
  if (mapsPromise) return mapsPromise;

  var meta = document.querySelector("meta[name='google-maps-api-key']");
  if (!meta) {
    return Promise.reject(new Error("Missing meta[name='google-maps-api-key']"));
  }

  setOptions({
    key: meta.content
  });

  mapsPromise = importLibrary("maps").then(function () {
    return google.maps;
  });

  return mapsPromise;
}

var MAP_DEFAULTS = {
  mapTypeId: "hybrid",
  streetViewControl: false,
  zoomControl: true,
  gestureHandling: "greedy"
};

export function isMapEnabled() {
  return !!document.querySelector("#googleMap[data-map-enabled]");
}

export function createMap(element, extraOptions) {
  var opts = Object.assign({}, MAP_DEFAULTS, extraOptions || {});
  return new google.maps.Map(element, opts);
}

export function autofitMarkers(map, markers, maxZoom) {
  if (!markers.length) return;
  var bounds = new google.maps.LatLngBounds();
  markers.forEach(function (m) { bounds.extend(m.getPosition()); });
  map.fitBounds(bounds);
  if (maxZoom) {
    google.maps.event.addListenerOnce(map, "idle", function () {
      if (map.getZoom() > maxZoom) map.setZoom(maxZoom);
    });
  }
}

export function panToLocus(map, locId) {
  fetch("/loci/" + locId + ".json")
    .then(function (r) { return r.json(); })
    .then(function (data) {
      if (data.lat != null && data.lon != null) {
        map.setCenter(new google.maps.LatLng(data.lat, data.lon));
        map.setZoom(13);
      }
    });
}
