import { createMap, autofitMarkers } from "./map-init";

export function initMapGlobal(mapEl) {
  if (!("mapEnabled" in mapEl.dataset)) return;

  var map = null;

  function outerHeight(el) {
    if (!el || el.offsetParent === null) return 0;
    var style = getComputedStyle(el);
    return el.offsetHeight + parseInt(style.marginTop) + parseInt(style.marginBottom);
  }

  function adjustSizes() {
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

    if (map) google.maps.event.trigger(map, "resize");
  }

  adjustSizes();
  window.addEventListener("resize", adjustSizes);

  map = createMap(mapEl);

  fetch("/map/loci")
    .then(function (r) { return r.json(); })
    .then(function (rdata) {
      var markers = [];
      for (var latLng in rdata) {
        markers.push(new google.maps.Marker({
          position: { lat: rdata[latLng][0], lng: rdata[latLng][1] },
          map: map
        }));
      }
      autofitMarkers(map, markers);
    });
}
