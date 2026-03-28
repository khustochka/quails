import { setOptions, importLibrary } from "@googlemaps/js-api-loader";
import { MarkerClusterer, SuperClusterAlgorithm } from "@googlemaps/markerclusterer";

document.addEventListener("DOMContentLoaded", function () {
  var mapEl = document.getElementById("googleMap");
  if (!mapEl || !("mapEnabled" in mapEl.dataset)) return;

  var galleryWindow = document.querySelector(".gallery_window");
  var galleryContainer = document.querySelector(".gallery_container");
  var stripUrl = galleryWindow.dataset.stripUrl;
  var activeClusterEl = null;

  var bounds = {
    ukraine: { south: 44.386, west: 22.137, north: 52.380, east: 40.229 },
    north_america: { south: 29.2, west: -113, north: 50.5, east: -71.06 },
    world: { south: 29.2, west: -99, north: 52.380, east: 40.229 }
  };

  function outerHeight(el) {
    if (!el || el.offsetParent === null) return 0;
    var style = getComputedStyle(el);
    return el.offsetHeight + parseInt(style.marginTop) + parseInt(style.marginBottom);
  }

  function adjustSizes(map) {
    var clientHeight = window.innerHeight,
        clientWidth = window.innerWidth,
        header = document.getElementById("header"),
        mapPanel = document.querySelector(".map-panel"),
        footer = document.querySelector("div.footer"),
        container = document.querySelector("div.mapContainer");

    var upper = outerHeight(header)
        + (mapPanel && getComputedStyle(mapPanel).position === "static" ? outerHeight(mapPanel) : 0);
    var lower = (footer && footer.offsetParent !== null) ? footer.offsetHeight : 0;

    container.style.height = (clientHeight - upper - lower) + "px";
    container.style.width = clientWidth + "px";
    container.style.top = upper + "px";

    if (galleryWindow.style.display !== "none") {
      galleryWindow.style.bottom = lower + "px";
    }

    if (map) google.maps.event.trigger(map, "resize");
  }

  function csrfToken() {
    var meta = document.querySelector("meta[name='csrf-token']");
    return meta ? meta.content : "";
  }

  function clusterSize(count) {
    if (count >= 100) return "large";
    if (count >= 10) return "medium";
    return "small";
  }

  function createClusterElement(count) {
    var div = document.createElement("div");
    div.className = "marker-cluster marker-cluster-" + clusterSize(count);
    div.innerHTML = "<span>" + count + "</span>";
    return div;
  }

  function clusterRenderer(cluster, stats, map) {
    var count = 0;
    cluster.markers.forEach(function (m) {
      count += (m._mediaIds ? m._mediaIds.length : 1);
    });

    var el = createClusterElement(count);

    return new google.maps.marker.AdvancedMarkerElement({
      position: cluster.position,
      content: el,
      zIndex: 1000 + count
    });
  }

  function showPhotos(cluster, map) {
    var mediaIds = [];
    cluster.markers.forEach(function (m) {
      var ids = m._mediaIds;
      if (ids) mediaIds = mediaIds.concat(ids);
    });

    var footer = document.querySelector("div.footer");
    var lower = (footer && footer.offsetParent !== null) ? footer.offsetHeight : 0;
    galleryWindow.style.bottom = lower + "px";
    galleryWindow.style.display = "block";
    galleryContainer.innerHTML = "";
    galleryContainer.scrollLeft = 0;
    galleryContainer.classList.add("loading");

    if (activeClusterEl) activeClusterEl.classList.remove("active-cluster");
    var markerContent = cluster.marker && cluster.marker.content;
    if (markerContent) {
      markerContent.classList.add("active-cluster");
      activeClusterEl = markerContent;
    }

    fetch(stripUrl, {
      method: "POST",
      headers: {
        "Content-Type": "application/json; charset=utf-8",
        "X-CSRF-Token": csrfToken()
      },
      body: JSON.stringify(mediaIds)
    })
      .then(function (r) { return r.ok ? r.text() : Promise.reject(); })
      .then(function (html) {
        galleryContainer.classList.remove("loading");
        galleryContainer.innerHTML = html;
      })
      .catch(function () {
        galleryContainer.classList.remove("loading");
        galleryContainer.innerHTML = "<h2>Error :(</h2>";
      });
  }

  // Init

  var meta = document.querySelector("meta[name='google-maps-api-key']");
  if (!meta) return;

  setOptions({ key: meta.content });

  Promise.all([importLibrary("maps"), importLibrary("marker")]).then(function () {
    var map = new google.maps.Map(mapEl, {
      mapTypeId: "hybrid",
      streetViewControl: false,
      zoomControl: true,
      gestureHandling: "greedy",
      mapId: "public-map"
    });

    adjustSizes(map);
    window.addEventListener("resize", function () { adjustSizes(map); });

    // Close gallery
    function closeGallery() {
      if (galleryWindow.style.display === "none") return;
      if (activeClusterEl) activeClusterEl.classList.remove("active-cluster");
      activeClusterEl = null;
      galleryWindow.style.display = "none";
    }

    document.querySelector("span.close").addEventListener("click", closeGallery);
    document.addEventListener("keydown", function (e) {
      if (e.key === "Escape") {
        closeGallery();
        document.activeElement.blur();
      }
    });

    // Region panning
    var hash = window.location.hash.substring(1) || "world";
    if (bounds[hash]) map.fitBounds(bounds[hash]);

    document.querySelectorAll(".pan").forEach(function (link) {
      link.addEventListener("click", function (e) {
        e.preventDefault();
        var region = this.hash.substring(1);
        if (bounds[region]) map.fitBounds(bounds[region]);
        window.history.replaceState(null, "", this.hash);
      });
    });

    // Fetch media and create markers
    fetch("/map/media")
      .then(function (r) { return r.json(); })
      .then(function (rdata) {
        var markers = [];

        for (var latLng in rdata) {
          var parts = latLng.split(",");
          var ids = rdata[latLng];
          var el = createClusterElement(ids.length);
          var marker = new google.maps.marker.AdvancedMarkerElement({
            position: { lat: parseFloat(parts[0]), lng: parseFloat(parts[1]) },
            content: el
          });
          marker._mediaIds = ids;
          marker.addListener("gmp-click", function () {
            showPhotos({ markers: [this], marker: this }, map);
          });
          markers.push(marker);
        }

        new MarkerClusterer({
          map: map,
          markers: markers,
          algorithm: new SuperClusterAlgorithm({ radius: 70 }),
          renderer: { render: clusterRenderer },
          onClusterClick: function (event, cluster) {
            showPhotos(cluster, map);
          }
        });
      });
  });
});
