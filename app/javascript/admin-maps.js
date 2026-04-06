import { loadGoogleMaps } from "./src/admin-maps/map-init";
import { initLocusEdit } from "./src/admin-maps/locus-edit";
import { initMapEdit } from "./src/admin-maps/map-edit";
import { initMapGlobal } from "./src/admin-maps/map-global";
import { initMediaMappable } from "./src/admin-maps/media-mappable";
import { initEbirdAlerts } from "./src/admin-maps/ebird-alerts";

var modes = {
  "locus-edit": initLocusEdit,
  "map-edit": initMapEdit,
  "map-global": initMapGlobal,
  "media-mappable": initMediaMappable,
  "ebird-alerts": initEbirdAlerts
};

document.addEventListener("DOMContentLoaded", function () {
  var mapEl = document.getElementById("googleMap");
  if (!mapEl) return;

  var init = modes[mapEl.dataset.mapMode];
  if (!init) return;

  if ("mapEnabled" in mapEl.dataset) {
    loadGoogleMaps().then(function () {
      init(mapEl);
    });
  } else {
    init(mapEl);
  }
});
