import { createMap, autofitMarkers, panToLocus, setDefaultView } from "./map-init";

export function initMapEdit(mapEl) {
  var searchForm = document.querySelector("form.search");
  var card_kml = mapEl.dataset.cardKml;
  var observCollection = {};
  var spotsStore = {};
  var defaultPublicity = true;
  var theLastMarker = null;

  var GRAY_ICON = "https://maps.google.com/mapfiles/marker_white.png",
      RED_ICON = "https://maps.google.com/mapfiles/marker.png";

  var infoWindow = new google.maps.InfoWindow();
  var allMarkers = [];
  var markersByTag = {};
  var origZIndex = new WeakMap();

  function csrfToken() {
    var meta = document.querySelector("meta[name='csrf-token']");
    return meta ? meta.content : "";
  }

  function addMarkerToStore(marker, tag, data) {
    if (tag != null) {
      if (!markersByTag[tag]) markersByTag[tag] = [];
      markersByTag[tag].push(marker);
    }
    allMarkers.push({ marker: marker, tag: tag, data: data });
  }

  function clearMarkers() {
    allMarkers.forEach(function (e) { e.marker.setMap(null); });
    allMarkers = [];
    markersByTag = {};
    infoWindow.close();
  }

  function closeInfoWindows() {
    infoWindow.close();
  }

  // Spot form
  var spotFormContainer = document.querySelector(".spot_form_container");
  var spotFormHTML = spotFormContainer ? spotFormContainer.innerHTML : "";
  if (spotFormContainer) spotFormContainer.remove();

  function makeFormContent(overrides) {
    var html = spotFormHTML;
    if (overrides.spot_id) {
      html = html.replace(/id="spot_id"[^>]*value="[^"]*"/, 'id="spot_id" value="' + overrides.spot_id + '"');
    }
    if (overrides.lat != null) {
      html = html.replace(/id="spot_lat"[^>]*/, '$& value="' + overrides.lat + '"');
    }
    if (overrides.lng != null) {
      html = html.replace(/id="spot_lng"[^>]*/, '$& value="' + overrides.lng + '"');
    }
    if (overrides.zoom != null) {
      html = html.replace(/id="spot_zoom"[^>]*/, '$& value="' + overrides.zoom + '"');
    }
    if (overrides.observation_id) {
      html = html.replace(/id="spot_observation_id"[^>]*/, '$& value="' + overrides.observation_id + '"');
    }
    if (overrides.exactness) {
      html = html.replace(new RegExp('id="spot_exactness_' + overrides.exactness + '"'), '$& checked');
    }
    if (overrides.memo) {
      html = html.replace(/id="spot_memo"[^>]*/, '$& value="' + overrides.memo + '"');
    }
    if (overrides.isPublic) {
      html = html.replace(/id="spot_public"/, '$& checked="checked"');
    }
    if (overrides.destroyLink) {
      html = html.replace(/<\/div>\s*$/, overrides.destroyLink + "</div>");
    }
    return html;
  }

  function createDestroyLink(spot_id) {
    return "<a href='/spots/" + spot_id + "' " +
        "class='destroy' " +
        "data-confirm='Spot will be REMOVED!' " +
        "data-method='delete' " +
        "rel='nofollow' " +
        "data-remote='true'>Destroy</a>";
  }

  var map = null;

  function createObsMarker(opts) {
    var marker = new google.maps.Marker({
      position: opts.latLng,
      map: map,
      draggable: true,
      icon: opts.icon || GRAY_ICON,
      title: opts.title
    });

    marker.addListener("click", function () {
      var selectedObs = document.querySelector("li.selected_obs");
      var spot_id = opts.data.id;
      var spotData = spotsStore[spot_id];

      theLastMarker = marker;
      closeInfoWindows();

      if (!selectedObs && observCollection[spotData.observation_id]) {
        observCollection[spotData.observation_id].click();
        selectedObs = document.querySelector("li.selected_obs");
      }

      var overrides = {
        exactness: spotData.exactness,
        memo: spotData.memo,
        isPublic: spotData.public,
        lat: marker.getPosition().lat(),
        lng: marker.getPosition().lng(),
        zoom: spotData.zoom,
        observation_id: selectedObs ? selectedObs.dataset.obsId : ""
      };

      if (selectedObs && selectedObs.dataset.obsId == spotData.observation_id) {
        overrides.spot_id = spot_id;
        overrides.destroyLink = createDestroyLink(spot_id);
      }

      var content = makeFormContent(overrides);
      infoWindow.setContent(content);
      infoWindow.open({ map: map, anchor: marker });
    });

    marker.addListener("dragstart", function () {
      closeInfoWindows();
      var selected = document.querySelector("li.selected_obs");
      var spotData = spotsStore[opts.data.id];
      if ((!selected || selected.dataset.obsId != spotData.observation_id) && observCollection[spotData.observation_id]) {
        observCollection[spotData.observation_id].click();
      }
    });

    marker.addListener("dragend", function () {
      var spotData = spotsStore[opts.data.id];
      var params = new URLSearchParams();
      params.append("spot[id]", opts.data.id);
      params.append("spot[lat]", marker.getPosition().lat());
      params.append("spot[lng]", marker.getPosition().lng());
      params.append("spot[zoom]", Math.max(spotData.zoom, map.getZoom()));

      var action = spotFormContainer ? document.querySelector(".spot_form_container form") : null;
      var url = action ? action.getAttribute("action") : "/spots";

      fetch(url, {
        method: "POST",
        headers: { "X-CSRF-Token": csrfToken() },
        body: params
      });
    });

    addMarkerToStore(marker, opts.tag, opts.data);
    return marker;
  }

  // Layout
  function adjustSizes() {
    var clientHeight = window.innerHeight,
        clientWidth = window.innerWidth,
        header = document.getElementById("header"),
        sidePanel = document.querySelector(".map-side-panel"),
        container = document.querySelector("div.mapContainer");

    var upper = (header ? header.offsetHeight : 0) + searchForm.offsetHeight;
    var leftmost = sidePanel ? sidePanel.offsetWidth : 0;

    if (sidePanel) sidePanel.style.height = (clientHeight - upper - 2) + "px";
    container.style.height = (clientHeight - upper) + "px";
    container.style.width = (clientWidth - leftmost) + "px";
    container.style.top = upper + "px";
    container.style.left = leftmost + "px";

    if (map) {
      try { google.maps.event.trigger(map, "resize"); } catch (e) {}
    }
  }

  adjustSizes();
  window.addEventListener("resize", adjustSizes);

  // Search form
  var obsList = document.querySelector("ul.obs-list");

  searchForm.addEventListener("ajax:beforeSend", function () {
    obsList.innerHTML = "";
  });

  searchForm.addEventListener("ajax:success", function (e) {
    var data = e.detail[0];
    obsList.innerHTML = data.html;
    buildObservations(data.json);
  });

  function buildObservations(data) {
    observCollection = {};
    spotsStore = {};
    clearMarkers();

    if (!data.length) return;

    var markerEntries = [];

    data.forEach(function (obs) {
      var el = obsList.querySelector("li[data-obs-id='" + obs.id + "']");
      if (el) {
        el.classList.toggle("is_mapped", parseInt(el.dataset.obsCount) > 0);
        var hoverText = el.querySelector("div") ? el.querySelector("div").textContent : "";
        observCollection[obs.id] = el;

        obs.spots.forEach(function (spot) {
          spotsStore[spot.id] = spot;
          markerEntries.push({
            latLng: { lat: spot.lat, lng: spot.lng },
            tag: spot.observation_id,
            data: { id: spot.id },
            title: hoverText
          });
        });
      }
    });

    if (markerEntries.length > 0) {
      markerEntries.forEach(function (entry) {
        createObsMarker(entry);
      });
      autofitMarkers(map, allMarkers.map(function (e) { return e.marker; }));
    } else {
      var locusSelect = searchForm.querySelector("select[name='q[locus_id]']");
      (locusSelect && locusSelect.value
        ? panToLocus(map, locusSelect.value)
        : Promise.resolve(false)
      ).then(function (ok) {
        if (!ok) setDefaultView(map);
      });
    }
  }

  // Toggle selected observation
  obsList.addEventListener("click", function (e) {
    var li = e.target.closest("li");
    if (!li) return;

    closeInfoWindows();

    var currentObs = document.querySelector(".selected_obs");
    var currentTag = currentObs ? currentObs.dataset.obsId : null;
    if (currentTag && markersByTag[currentTag]) {
      markersByTag[currentTag].forEach(function (m) {
        m.setIcon(GRAY_ICON);
        var oz = origZIndex.get(m);
        if (oz != null) m.setZIndex(oz);
      });
    }

    if (currentObs) currentObs.classList.remove("selected_obs");
    li.classList.add("selected_obs");

    var newTag = li.dataset.obsId;
    if (newTag && markersByTag[newTag]) {
      markersByTag[newTag].forEach(function (m) {
        m.setIcon(RED_ICON);
        origZIndex.set(m, m.getZIndex());
        m.setZIndex(google.maps.Marker.MAX_ZINDEX);
      });
    }
  });

  // Panel
  var panelDiv = document.createElement("div");
  panelDiv.className = "map-panel";
  panelDiv.innerHTML = "<span class='pseudolink load_kml'>Load KML</span> &nbsp; " +
      "<span class='pseudolink clear_kml'>clear KML</span>" +
      (card_kml ? " &nbsp; <span class='pseudolink card_kml'><b>Card KML</b></span>" : "");

  map = createMap(mapEl, {
    draggableCursor: "pointer"
  });
  setDefaultView(map);

  map.controls[google.maps.ControlPosition.TOP_LEFT].push(panelDiv);

  map.addListener("click", function (e) {
    var selectedObs = document.querySelector("li.selected_obs");
    closeInfoWindows();

    if (!selectedObs) {
      infoWindow.setContent("<p>No observation selected</p>");
    } else {
      var content = makeFormContent({
        lat: e.latLng.lat(),
        lng: e.latLng.lng(),
        zoom: map.getZoom(),
        exactness: 1,
        observation_id: selectedObs.dataset.obsId,
        isPublic: defaultPublicity
      });
      infoWindow.setContent(content);
    }
    infoWindow.setPosition(e.latLng);
    infoWindow.open(map);
  });

  // Spot form ajax
  document.addEventListener("change", function (e) {
    if (e.target.id === "spot_public") {
      defaultPublicity = e.target.checked;
    }
  });

  document.addEventListener("ajax:success", function (e) {
    if (e.target.matches("#new_spot")) {
      var data = e.detail[0];
      var selectedObs = document.querySelector("li.selected_obs");

      var spotIdField = document.querySelector("#new_spot #spot_id");
      if (spotIdField && spotIdField.value === "") {
        var newMarker = createObsMarker({
          latLng: { lat: data.lat, lng: data.lng },
          tag: selectedObs ? selectedObs.dataset.obsId : null,
          data: { id: data.id },
          icon: RED_ICON,
          title: selectedObs ? selectedObs.querySelector("div").textContent : ""
        });
        newMarker.setZIndex(google.maps.Marker.MAX_ZINDEX);
      }

      if (selectedObs) {
        selectedObs.classList.add("is_mapped");
        selectedObs.dataset.obsCount = parseInt(selectedObs.dataset.obsCount || 0) + 1;
      }

      spotsStore[data.id] = data;
      infoWindow.close();
    }
  });

  document.addEventListener("ajax:error", function (e) {
    if (e.target.matches("#new_spot")) alert("Error submitting form");
  });

  // Destroy spot
  document.addEventListener("ajax:success", function (e) {
    if (e.target.matches("#new_spot .destroy")) {
      if (theLastMarker) theLastMarker.setMap(null);
      closeInfoWindows();

      var selectedObs = document.querySelector("li.selected_obs");
      if (selectedObs) {
        var count = parseInt(selectedObs.dataset.obsCount || 0) - 1;
        selectedObs.dataset.obsCount = count;
        selectedObs.classList.toggle("is_mapped", count > 0);
      }
      e.stopPropagation();
    }
  });

  // KML
  var kmls = [];

  function loadKML(kml_url) {
    if (!kml_url) return;
    var kml = new google.maps.KmlLayer({
      url: kml_url,
      clickable: false,
      map: map
    });
    kmls.push(kml);
  }

  if (card_kml) loadKML(card_kml);

  panelDiv.querySelector(".load_kml").addEventListener("click", function () {
    var kml_url = prompt("Enter KML url:");
    loadKML(kml_url);
  });

  var cardKmlBtn = panelDiv.querySelector(".card_kml");
  if (cardKmlBtn) {
    cardKmlBtn.addEventListener("click", function () { loadKML(card_kml); });
  }

  panelDiv.querySelector(".clear_kml").addEventListener("click", function () {
    kmls.forEach(function (k) { k.setMap(null); });
    kmls = [];
  });

  // Submit search form after map is ready
  searchForm.requestSubmit();
}
