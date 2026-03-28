import { createMap, autofitMarkers, setDefaultView } from "./map-init";

export function initMediaMappable(mapEl) {
  var mapContainer = document.querySelector(".mapContainer");
  var patchUrl = mapContainer.dataset.patchUrl,
      mediaType = mapContainer.dataset.mediaType,
      maxZoom = parseInt(mapContainer.dataset.maxZoom) || 15,
      selectedSpot = mapContainer.dataset.selectedSpot,
      locusCoords = JSON.parse(mapContainer.dataset.locusCoords || "{}"),
      locusLatLng = null;

  if (locusCoords.lat && locusCoords.lon) {
    locusLatLng = new google.maps.LatLng(locusCoords.lat, locusCoords.lon);
  }

  var marksData = JSON.parse(mapContainer.dataset.marks || "[]");
  var firstObserv = document.querySelector(".obs-list li input");
  firstObserv = firstObserv ? firstObserv.value : null;

  var GRAY_ICON = "https://maps.google.com/mapfiles/marker_white.png",
      RED_ICON = "https://maps.google.com/mapfiles/marker.png";

  var infoWindow = new google.maps.InfoWindow();
  var allMarkers = [];
  var markersByTag = {};
  var origZIndex = new WeakMap();

  function addMarker(map, opts) {
    var marker = new google.maps.Marker({
      position: opts.latLng,
      map: map,
      draggable: opts.draggable || false,
      icon: opts.icon || GRAY_ICON,
      title: opts.title
    });
    var tag = opts.tag;
    var data = opts.data;

    if (tag != null) {
      if (!markersByTag[tag]) markersByTag[tag] = [];
      markersByTag[tag].push(marker);
    }
    allMarkers.push({ marker: marker, tag: tag, data: data });

    if (opts.onClick) marker.addListener("click", function () { opts.onClick(marker, data); });
    return marker;
  }

  function csrfToken() {
    var meta = document.querySelector("meta[name='csrf-token']");
    return meta ? meta.content : "";
  }

  function bindImageToMarker(marker, data) {
    var payload = new URLSearchParams();
    payload.append(mediaType + "[spot_id]", data.id);

    fetch(patchUrl, {
      method: "POST",
      headers: { "X-CSRF-Token": csrfToken() },
      body: payload
    }).then(function () {
      var prev = markersByTag[selectedSpot];
      if (prev) {
        prev.forEach(function (m) {
          m.setIcon(GRAY_ICON);
          var oz = origZIndex.get(m);
          if (oz != null) m.setZIndex(oz);
        });
      }

      selectedSpot = data.id;

      marker.setIcon(RED_ICON);
      origZIndex.set(marker, marker.getZIndex());
      marker.setZIndex(google.maps.Marker.MAX_ZINDEX);
    });
  }

  // Spot form
  var spotFormContainer = document.querySelector(".spot_form_container");
  var spotFormHTML = spotFormContainer ? spotFormContainer.innerHTML : "";
  if (spotFormContainer) spotFormContainer.remove();

  // Layout
  function adjustSizes() {
    var clientHeight = window.innerHeight,
        clientWidth = window.innerWidth,
        header = document.getElementById("header"),
        sidePanel = document.querySelector(".map-side-panel");

    var upper = header ? header.offsetHeight : 0;
    var leftmost = sidePanel ? sidePanel.offsetWidth : 0;

    if (sidePanel) sidePanel.style.height = (clientHeight - upper - 2) + "px";
    mapContainer.style.height = (clientHeight - upper) + "px";
    mapContainer.style.width = (clientWidth - leftmost) + "px";
    mapContainer.style.top = upper + "px";
    mapContainer.style.left = leftmost + "px";
  }

  adjustSizes();
  window.addEventListener("resize", adjustSizes);

  var map = createMap(mapEl, { draggableCursor: "pointer" });

  map.addListener("click", function (e) {
    var formClone = spotFormHTML;
    infoWindow.close();

    formClone = formClone.replace(/id="spot_lat"[^>]*/, '$& value="' + e.latLng.lat() + '"');
    formClone = formClone.replace(/id="spot_lng"[^>]*/, '$& value="' + e.latLng.lng() + '"');
    formClone = formClone.replace(/id="spot_zoom"[^>]*/, '$& value="' + map.getZoom() + '"');
    formClone = formClone.replace(/id="spot_exactness_1"/, '$& checked');
    formClone = formClone.replace(/id="spot_observation_id"[^>]*/, '$& value="' + firstObserv + '"');

    infoWindow.setContent(formClone);
    infoWindow.setPosition(e.latLng);
    infoWindow.open(map);
  });

  // Ajax handlers for spot form
  document.addEventListener("ajax:success", function (e) {
    if (!e.target.matches("#new_spot")) return;
    var data = e.detail[0];

    infoWindow.close();

    var newMarker = addMarker(map, {
      latLng: { lat: data.lat, lng: data.lng },
      tag: data.id,
      data: { id: data.id },
      onClick: function (marker, mdata) {
        infoWindow.close();
        bindImageToMarker(marker, mdata);
      }
    });

    bindImageToMarker(newMarker, { id: data.id });
  });

  document.addEventListener("ajax:error", function (e) {
    if (e.target.matches("#new_spot")) alert("Error submitting form");
  });

  // Create markers from data
  marksData.forEach(function (el) {
    addMarker(map, {
      latLng: { lat: el.lat, lng: el.lng },
      tag: el.id,
      data: { id: el.id },
      onClick: function (marker, data) {
        infoWindow.close();
        bindImageToMarker(marker, data);
      }
    });
  });

  // Fit / center
  var justMarkers = allMarkers.map(function (e) { return e.marker; });
  if (justMarkers.length > 0) {
    autofitMarkers(map, justMarkers, maxZoom);
  } else if (locusLatLng) {
    map.setCenter(locusLatLng);
    map.setZoom(13);
  } else {
    setDefaultView(map);
  }

  // Highlight selected spot
  if (selectedSpot) {
    var selected = markersByTag[selectedSpot];
    if (selected) {
      selected.forEach(function (m) {
        m.setIcon(RED_ICON);
        origZIndex.set(m, m.getZIndex());
        m.setZIndex(google.maps.Marker.MAX_ZINDEX);
      });
    }
  }
}
