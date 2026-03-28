import { createMap, autofitMarkers, setDefaultView, panToLocus, csrfToken, GRAY_ICON, RED_ICON, createMarkerStore } from "./map-init";

export function initMapEdit(mapEl) {
  var searchForm = document.querySelector("form.search");
  var obsList = document.querySelector("ul.obs-list");
  var card_kml = mapEl.dataset.cardKml;

  var map = null;
  var infoWindow = new google.maps.InfoWindow();
  var store = createMarkerStore();
  var observCollection = {};
  var spotsStore = {};
  var defaultPublicity = true;
  var theLastMarker = null;

  var spotFormTemplate = document.querySelector(".spot_form_container");
  if (spotFormTemplate) spotFormTemplate.style.display = "none";

  // --- Spot form content ---

  function cloneSpotForm(overrides) {
    var clone = spotFormTemplate.cloneNode(true);
    clone.style.display = "";

    var setVal = function (id, val) {
      var el = clone.querySelector("#" + id);
      if (el && val != null) el.value = val;
    };

    setVal("spot_id", overrides.spot_id || "");
    setVal("spot_lat", overrides.lat);
    setVal("spot_lng", overrides.lng);
    setVal("spot_zoom", overrides.zoom);
    setVal("spot_observation_id", overrides.observation_id);
    setVal("spot_memo", overrides.memo);

    if (overrides.exactness != null) {
      var radio = clone.querySelector("#spot_exactness_" + overrides.exactness);
      if (radio) radio.checked = true;
    }

    var publicBox = clone.querySelector("#spot_public");
    if (publicBox) publicBox.checked = !!overrides.isPublic;

    if (overrides.spot_id) {
      var link = document.createElement("a");
      link.href = "/spots/" + overrides.spot_id;
      link.className = "destroy";
      link.dataset.confirm = "Spot will be REMOVED!";
      link.dataset.method = "delete";
      link.rel = "nofollow";
      link.dataset.remote = "true";
      link.textContent = "Destroy";
      clone.querySelector(".buttons").appendChild(link);
    }

    return clone;
  }

  // --- Marker creation ---

  function onMarkerClick(marker, opts) {
    var selectedObs = document.querySelector("li.selected_obs");
    var spot_id = opts.data.id;
    var spotData = spotsStore[spot_id];

    theLastMarker = marker;
    infoWindow.close();

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
    }

    infoWindow.setContent(cloneSpotForm(overrides));
    infoWindow.open({ map: map, anchor: marker });
  }

  function onMarkerDragstart(opts) {
    infoWindow.close();
    var selected = document.querySelector("li.selected_obs");
    var spotData = spotsStore[opts.data.id];
    if ((!selected || selected.dataset.obsId != spotData.observation_id) && observCollection[spotData.observation_id]) {
      observCollection[spotData.observation_id].click();
    }
  }

  function onMarkerDragend(marker, opts) {
    var spotData = spotsStore[opts.data.id];
    var params = new URLSearchParams();
    params.append("spot[id]", opts.data.id);
    params.append("spot[lat]", marker.getPosition().lat());
    params.append("spot[lng]", marker.getPosition().lng());
    params.append("spot[zoom]", Math.max(spotData.zoom, map.getZoom()));

    fetch("/spots", {
      method: "POST",
      headers: { "X-CSRF-Token": csrfToken() },
      body: params
    });
  }

  function createObsMarker(opts) {
    var marker = new google.maps.Marker({
      position: opts.latLng,
      map: map,
      draggable: true,
      icon: opts.icon || GRAY_ICON,
      title: opts.title
    });

    marker.addListener("click", function () { onMarkerClick(marker, opts); });
    marker.addListener("dragstart", function () { onMarkerDragstart(opts); });
    marker.addListener("dragend", function () { onMarkerDragend(marker, opts); });

    store.add(marker, opts.tag, opts.data);
    return marker;
  }

  // --- Search and observations ---

  function buildObservations(data) {
    observCollection = {};
    spotsStore = {};
    store.clear();
    infoWindow.close();

    if (!data.length) return;

    data.forEach(function (obs) {
      var el = obsList.querySelector("li[data-obs-id='" + obs.id + "']");
      if (!el) return;

      el.classList.toggle("is_mapped", parseInt(el.dataset.obsCount) > 0);
      var hoverText = el.querySelector("div") ? el.querySelector("div").textContent : "";
      observCollection[obs.id] = el;

      obs.spots.forEach(function (spot) {
        spotsStore[spot.id] = spot;
        createObsMarker({
          latLng: { lat: spot.lat, lng: spot.lng },
          tag: spot.observation_id,
          data: { id: spot.id },
          title: hoverText
        });
      });
    });

    if (store.count() > 0) {
      autofitMarkers(map, store.markers());
    } else {
      panToLocusOrDefault();
    }
  }

  function panToLocusOrDefault() {
    var locusSelect = searchForm.querySelector("select[name='q[locus_id]']");
    (locusSelect && locusSelect.value
      ? panToLocus(map, locusSelect.value)
      : Promise.resolve(false)
    ).then(function (ok) {
      if (!ok) setDefaultView(map);
    });
  }

  // --- Obs list selection ---

  function onObsClick(e) {
    var li = e.target.closest("li");
    if (!li) return;

    infoWindow.close();

    var currentObs = document.querySelector(".selected_obs");
    if (currentObs) {
      store.highlight(currentObs.dataset.obsId, GRAY_ICON);
      currentObs.classList.remove("selected_obs");
    }

    li.classList.add("selected_obs");
    store.highlight(li.dataset.obsId, RED_ICON);
  }

  // --- Spot AJAX handlers ---

  function onSpotCreated(e) {
    if (!e.target.matches("#new_spot")) return;
    var data = e.detail[0];
    var selectedObs = document.querySelector("li.selected_obs");

    var spotIdField = document.querySelector("#new_spot #spot_id");
    if (spotIdField && spotIdField.value === "") {
      createObsMarker({
        latLng: { lat: data.lat, lng: data.lng },
        tag: selectedObs ? selectedObs.dataset.obsId : null,
        data: { id: data.id },
        title: selectedObs ? selectedObs.querySelector("div").textContent : ""
      });
      if (selectedObs) store.highlight(selectedObs.dataset.obsId, RED_ICON);
    }

    if (selectedObs) {
      selectedObs.classList.add("is_mapped");
      selectedObs.dataset.obsCount = parseInt(selectedObs.dataset.obsCount || 0) + 1;
    }

    spotsStore[data.id] = data;
    infoWindow.close();
  }

  function onSpotDestroyed(e) {
    if (!e.target.matches("#new_spot .destroy")) return;
    if (theLastMarker) theLastMarker.setMap(null);
    infoWindow.close();

    var selectedObs = document.querySelector("li.selected_obs");
    if (selectedObs) {
      var count = parseInt(selectedObs.dataset.obsCount || 0) - 1;
      selectedObs.dataset.obsCount = count;
      selectedObs.classList.toggle("is_mapped", count > 0);
    }
    e.stopPropagation();
  }

  function onSpotError(e) {
    if (e.target.matches("#new_spot")) alert("Error submitting form");
  }

  // --- Layout ---

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

  // --- KML ---

  function setupKML(panelDiv) {
    var kmls = [];

    function loadKML(kml_url) {
      if (!kml_url) return;
      kmls.push(new google.maps.KmlLayer({ url: kml_url, clickable: false, map: map }));
    }

    if (card_kml) loadKML(card_kml);

    panelDiv.querySelector(".load_kml").addEventListener("click", function () {
      loadKML(prompt("Enter KML url:"));
    });

    var cardKmlBtn = panelDiv.querySelector(".card_kml");
    if (cardKmlBtn) {
      cardKmlBtn.addEventListener("click", function () { loadKML(card_kml); });
    }

    panelDiv.querySelector(".clear_kml").addEventListener("click", function () {
      kmls.forEach(function (k) { k.setMap(null); });
      kmls = [];
    });
  }

  // --- Init ---

  adjustSizes();
  window.addEventListener("resize", adjustSizes);

  // Map
  map = createMap(mapEl, { draggableCursor: "pointer" });
  setDefaultView(map);

  // Panel
  var panelDiv = document.createElement("div");
  panelDiv.className = "map-panel";
  panelDiv.innerHTML = "<span class='pseudolink load_kml'>Load KML</span> &nbsp; " +
      "<span class='pseudolink clear_kml'>clear KML</span>" +
      (card_kml ? " &nbsp; <span class='pseudolink card_kml'><b>Card KML</b></span>" : "");
  map.controls[google.maps.ControlPosition.TOP_LEFT].push(panelDiv);
  setupKML(panelDiv);

  // Map click
  map.addListener("click", function (e) {
    var selectedObs = document.querySelector("li.selected_obs");
    infoWindow.close();

    if (!selectedObs) {
      infoWindow.setContent("<p>No observation selected</p>");
    } else {
      infoWindow.setContent(cloneSpotForm({
        lat: e.latLng.lat(),
        lng: e.latLng.lng(),
        zoom: map.getZoom(),
        exactness: 1,
        observation_id: selectedObs.dataset.obsId,
        isPublic: defaultPublicity
      }));
    }
    infoWindow.setPosition(e.latLng);
    infoWindow.open(map);
  });

  // Event listeners
  obsList.addEventListener("click", onObsClick);
  document.addEventListener("change", function (e) {
    if (e.target.id === "spot_public") defaultPublicity = e.target.checked;
  });
  document.addEventListener("ajax:success", onSpotCreated);
  document.addEventListener("ajax:success", onSpotDestroyed);
  document.addEventListener("ajax:error", onSpotError);

  // Search
  searchForm.addEventListener("ajax:beforeSend", function () { obsList.innerHTML = ""; });
  searchForm.addEventListener("ajax:success", function (e) {
    var data = e.detail[0];
    obsList.innerHTML = data.html;
    buildObservations(data.json);
  });
  searchForm.requestSubmit();
}
