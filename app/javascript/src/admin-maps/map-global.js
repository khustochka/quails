import { createMap } from "./map-init";
import { MAP_ID, loadAdvancedMarkers } from "../maps/advanced-markers";
import { clusterMarkers } from "../maps/clusters";
import { createSpeciesBitmaps } from "./species-bitmap";

// Bubbles follow the public map (.marker-cluster): individual loci and clusters
// share one look, so a locus reads as a cluster of one. Diameter grows with the
// square root of the checklist count, keeping a home patch with hundreds of
// visits legible next to a one-off stop.
var MIN_SIZE = 24;
var MAX_SIZE = 46;

// The intensity ramp comes from MapHelper::INTENSITY_RAMP via a data attribute,
// so the legend rendered server-side and the markers always agree.

export function initMapGlobal(mapEl) {
  if (!("mapEnabled" in mapEl.dataset)) return;

  // Sizing is handled by the app2 layout's CSS (body.map-page flex + .mapContainer),
  // the same way the public map does it — no JS resize handling needed.

  // The cluster bubbles are AdvancedMarkerElements, which need the mapId.
  var map = createMap(mapEl, { mapId: MAP_ID });

  Promise.all([
    loadAdvancedMarkers(),
    fetch("/map/loci").then(function (r) { return r.json(); })
  ])
    .then(function (results) {
      var data = results[1];
      var loci = data.loci;
      if (!loci.length) return;

      var RAMP = mapEl.dataset.ramp.split(",");
      var bitmaps = createSpeciesBitmaps(data.speciesIndexSize);
      var maxCards = loci.reduce(function (m, l) { return Math.max(m, l.cards); }, 1);

      // Checklist counts are heavily skewed (a home patch can outweigh a one-off
      // stop by three orders of magnitude), so colour bands are quantiles rather
      // than a linear ramp, which would leave nearly every locus in the lowest
      // band. Size still scales with the raw count, so the busiest places stay
      // visibly bigger. Quantiles are taken over the *distinct* counts because
      // many loci share the same low count, which would otherwise repeat a
      // threshold and leave whole colours unused.
      var distinctCards = Array.from(new Set(loci.map(function (l) { return l.cards; })))
        .sort(function (a, b) { return a - b; });
      var thresholds = [];
      for (var i = 1; i < RAMP.length && i < distinctCards.length; i++) {
        thresholds.push(distinctCards[Math.floor(distinctCards.length * i / RAMP.length)]);
      }

      // Clamped because a cluster's summed count can exceed any single locus's,
      // which would otherwise push bubbles past MAX_SIZE.
      function size(cards) {
        var scale = Math.min(1, Math.sqrt(cards / maxCards));
        return Math.round(MIN_SIZE + (MAX_SIZE - MIN_SIZE) * scale);
      }

      function color(cards) {
        for (var i = 0; i < thresholds.length; i++) {
          if (cards < thresholds[i]) return RAMP[i];
        }
        return RAMP[RAMP.length - 1];
      }

      function bubble(species, cards) {
        var el = document.createElement("div");
        el.className = "birding-cluster";
        el.style.width = el.style.height = size(cards) + "px";
        el.style.backgroundColor = color(cards);
        el.textContent = species;
        el.title = summaryText(species, cards);
        return el;
      }

      // Localised templates, with %{species} / %{cards} placeholders.
      var summaryTemplate = mapEl.dataset.summaryLabel;
      var lifelistLabel = mapEl.dataset.lifelistLabel;
      var lifelistUrl = mapEl.dataset.lifelistUrl;

      function summaryText(species, cards) {
        return summaryTemplate
          .replace("%{species}", species)
          .replace("%{cards}", cards);
      }

      var info = new google.maps.InfoWindow();

      var markers = loci.map(function (locus) {
        var el = bubble(locus.species.length, locus.cards);
        el.title = locus.name + " — " + el.title;

        var marker = new google.maps.marker.AdvancedMarkerElement({
          position: { lat: locus.lat, lng: locus.lon },
          content: el,
          zIndex: locus.cards
        });

        marker._bits = bitmaps.build(locus.species);
        marker._cards = locus.cards;

        marker.addListener("gmp-click", function () {
          var content = document.createElement("div");
          content.className = "map-locus-info";

          var name = document.createElement("strong");
          name.textContent = locus.name;

          var summary = document.createElement("p");
          summary.textContent = summaryText(locus.species.length, locus.cards);

          var link = document.createElement("a");
          link.href = lifelistUrl + "?locus=" + encodeURIComponent(locus.slug);
          link.textContent = lifelistLabel;
          link.target = "_blank";
          link.rel = "noopener";

          content.append(name, summary, link);
          info.setContent(content);
          info.open({ map: map, anchor: marker });
        });

        return marker;
      });

      clusterMarkers(map, markers, {
        weigh: function (m) { return m._cards; },
        buildContent: function (cards, members) {
          var species = bitmaps.unionCount(members.map(function (m) { return m._bits; }));
          return bubble(species, cards);
        }
      });

      var bounds = new google.maps.LatLngBounds();
      markers.forEach(function (m) { bounds.extend(m.position); });
      map.fitBounds(bounds);
    });
}
