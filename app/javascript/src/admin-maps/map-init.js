// Bootstrapping now lives in src/maps/setup.js, shared with the visitor map
// bundle; re-exported here so the admin maps keep one import site.
export { loadGoogleMaps, createMap, isMapEnabled } from "../maps/setup";

var DEFAULT_CENTER = { lat: 52, lng: -35 };
var DEFAULT_ZOOM = 2;

export function setDefaultView(map) {
  map.setCenter(DEFAULT_CENTER);
  map.setZoom(DEFAULT_ZOOM);
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
