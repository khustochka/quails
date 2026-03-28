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

var DEFAULT_CENTER = { lat: 52, lng: -35 };
var DEFAULT_ZOOM = 2;

export function setDefaultView(map) {
  map.setCenter(DEFAULT_CENTER);
  map.setZoom(DEFAULT_ZOOM);
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

export var GRAY = "#999999";
export var RED = "#e53935";

export function markerIcon(color) {
  return {
    path: google.maps.SymbolPath.CIRCLE,
    fillOpacity: 1,
    fillColor: color,
    strokeColor: "white",
    strokeWeight: 1.5,
    scale: 7
  };
}

export function createMarkerStore() {
  var all = [];
  var byTag = {};
  var origZIndex = new WeakMap();

  return {
    add: function (marker, tag, data) {
      if (tag != null) {
        if (!byTag[tag]) byTag[tag] = [];
        byTag[tag].push(marker);
      }
      all.push({ marker: marker, tag: tag, data: data });
    },

    clear: function () {
      all.forEach(function (e) { e.marker.setMap(null); });
      all = [];
      byTag = {};
    },

    markers: function () {
      return all.map(function (e) { return e.marker; });
    },

    getByTag: function (tag) {
      return byTag[tag] || [];
    },

    count: function () {
      return all.length;
    },

    highlight: function (tag, color) {
      var markers = byTag[tag];
      if (!markers) return;
      markers.forEach(function (m) {
        m.setIcon(markerIcon(color));
        if (color === RED) {
          if (!origZIndex.has(m)) origZIndex.set(m, m.getZIndex() || 0);
          m.setZIndex(google.maps.Marker.MAX_ZINDEX);
        } else {
          var oz = origZIndex.get(m);
          m.setZIndex(oz != null ? oz : 0);
          origZIndex.delete(m);
        }
      });
    }
  };
}

export function csrfToken() {
  var meta = document.querySelector("meta[name='csrf-token']");
  return meta ? meta.content : "";
}

export function panToLocus(map, locId) {
  return fetch("/loci/" + locId + ".json")
    .then(function (r) { return r.ok ? r.json() : null; })
    .then(function (data) {
      if (data && data.lat != null && data.lon != null) {
        map.setCenter(new google.maps.LatLng(data.lat, data.lon));
        map.setZoom(13);
        return true;
      }
      return false;
    });
}
