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
    europe: { south: 44, west: -7, north: 58, east: 37 },
    north_america: { south: 27.5, west: -125, north: 55, east: -71 },
    world: { south: 29.2, west: -99, north: 52.380, east: 40.229 }
  };

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

  var PAGE_SIZE = 30;
  var allMediaIds = [];
  var loadedCount = 0;
  var loadingMore = false;

  function updateSpinner() {
    var strip = galleryContainer.querySelector(".thumbs_strip");
    if (!strip) return;
    var existing = strip.querySelector(".strip-load-more");
    if (loadedCount < allMediaIds.length) {
      if (!existing) {
        var el = document.createElement("div");
        el.className = "strip-load-more";
        el.innerHTML = "";
        strip.appendChild(el);
      }
    } else if (existing) {
      existing.remove();
    }
  }

  // Send ALL IDs every request; server sorts chronologically and paginates via offset/limit.
  // IDs come from cluster markers grouped by location, so the client cannot sort by date.
  function fetchStrip(append) {
    if (allMediaIds.length === 0 || loadedCount >= allMediaIds.length) return Promise.resolve();
    loadingMore = true;

    var url = stripUrl + "?offset=" + loadedCount + "&limit=" + PAGE_SIZE;

    return fetch(url, {
      method: "POST",
      headers: {
        "Content-Type": "application/json; charset=utf-8",
        "X-CSRF-Token": csrfToken()
      },
      body: JSON.stringify(allMediaIds)
    })
      .then(function (r) { return r.ok ? r.text() : Promise.reject(); })
      .then(function (html) {
        galleryContainer.classList.remove("loading");
        if (append) {
          var strip = galleryContainer.querySelector(".thumbs_strip");
          if (strip) {
            var spinner = strip.querySelector(".strip-load-more");
            if (spinner) spinner.remove();
            var temp = document.createElement("div");
            temp.innerHTML = html;
            var newStrip = temp.querySelector(".thumbs_strip");
            if (newStrip) {
              while (newStrip.firstChild) {
                strip.appendChild(newStrip.firstChild);
              }
            }
          }
        } else {
          galleryContainer.innerHTML = html;
        }
        loadedCount += PAGE_SIZE;
        updateSpinner();
        loadingMore = false;
      })
      .catch(function () {
        galleryContainer.classList.remove("loading");
        if (!append) {
          galleryContainer.innerHTML =
            "<div class='gallery-error'>" +
              "<p>Failed to load images</p>" +
              "<button class='gallery-retry'>Retry</button>" +
            "</div>";
          galleryContainer.querySelector(".gallery-retry").addEventListener("click", function () {
            galleryContainer.innerHTML = "";
            galleryContainer.classList.add("loading");
            fetchStrip(false);
          });
        }
        loadingMore = false;
      });
  }

  function loadMore() {
    if (loadingMore || loadedCount >= allMediaIds.length) return;
    fetchStrip(true);
  }

  galleryContainer.addEventListener("scroll", function () {
    var scrollRight = galleryContainer.scrollWidth - galleryContainer.scrollLeft - galleryContainer.clientWidth;
    if (scrollRight < 600) loadMore();
  });

  function showPhotos(cluster, map) {
    allMediaIds = [];
    loadedCount = 0;
    loadingMore = false;

    cluster.markers.forEach(function (m) {
      var ids = m._mediaIds;
      if (ids) allMediaIds = allMediaIds.concat(ids);
    });

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

    fetchStrip(false);
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
