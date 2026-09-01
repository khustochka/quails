import { setOptions, importLibrary } from "@googlemaps/js-api-loader";

// Google Maps bootstrapping, shared by the visitor and admin map bundles.

var mapsPromise = null;

// Cached: several admin maps can call this on one page load.
export function loadGoogleMaps() {
  if (mapsPromise) return mapsPromise;

  var meta = document.querySelector("meta[name='google-maps-api-key']");
  if (!meta) {
    return Promise.reject(new Error("Missing meta[name='google-maps-api-key']"));
  }

  setOptions({ 
    key: meta.content,
    region: "CA"
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

export function createMap(element, extraOptions) {
  return new google.maps.Map(element, Object.assign({}, MAP_DEFAULTS, extraOptions || {}));
}

export function isMapEnabled() {
  return !!document.querySelector("#googleMap[data-map-enabled]");
}
