import { createMap, autofitMarkers, setDefaultView, csrfToken, GRAY_ICON, RED_ICON, createMarkerStore } from "./map-init";

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

  var infoWindow = new google.maps.InfoWindow();
  var store = createMarkerStore();

  function addMarker(map, opts) {
    var marker = new google.maps.Marker({
      position: opts.latLng,
      map: map,
      draggable: opts.draggable || false,
      icon: opts.icon || GRAY_ICON,
      title: opts.title
    });

    store.add(marker, opts.tag, opts.data);

    if (opts.onClick) marker.addListener("click", function () { opts.onClick(marker, opts.data); });
    return marker;
  }

  function bindImageToMarker(marker, data) {
    var payload = new URLSearchParams();
    payload.append(mediaType + "[spot_id]", data.id);

    fetch(patchUrl, {
      method: "POST",
      headers: { "X-CSRF-Token": csrfToken() },
      body: payload
    }).then(function () {
      if (selectedSpot) store.highlight(selectedSpot, GRAY_ICON);
      selectedSpot = data.id;
      store.highlight(selectedSpot, RED_ICON);
    });
  }

  // Spot form
  var spotFormTemplate = document.querySelector(".spot_form_container");
  if (spotFormTemplate) spotFormTemplate.style.display = "none";

  function cloneSpotForm(overrides) {
    var clone = spotFormTemplate.cloneNode(true);
    clone.style.display = "";

    var setVal = function (id, val) {
      var el = clone.querySelector("#" + id);
      if (el && val != null) el.value = val;
    };

    setVal("spot_lat", overrides.lat);
    setVal("spot_lng", overrides.lng);
    setVal("spot_zoom", overrides.zoom);
    setVal("spot_observation_id", overrides.observation_id);

    if (overrides.exactness != null) {
      var radio = clone.querySelector("#spot_exactness_" + overrides.exactness);
      if (radio) radio.checked = true;
    }

    return clone;
  }

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
    infoWindow.close();

    infoWindow.setContent(cloneSpotForm({
      lat: e.latLng.lat(),
      lng: e.latLng.lng(),
      zoom: map.getZoom(),
      exactness: 1,
      observation_id: firstObserv
    }));
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
  if (store.count() > 0) {
    autofitMarkers(map, store.markers(), maxZoom);
  } else if (locusLatLng) {
    map.setCenter(locusLatLng);
    map.setZoom(13);
  } else {
    setDefaultView(map);
  }

  // Highlight selected spot
  if (selectedSpot) {
    store.highlight(selectedSpot, RED_ICON);
  }
}
