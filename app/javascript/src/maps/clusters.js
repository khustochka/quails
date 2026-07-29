import { MarkerClusterer, SuperClusterAlgorithm } from "@googlemaps/markerclusterer";

// Marker clustering shared by the photo map and the global map. Both render
// their markers and clusters as the same labelled bubble, so a lone marker
// reads as a cluster of one; they differ only in how the bubble is sized and
// coloured, which is what `buildContent` supplies.

// `buildContent(total, markers)` returns the element for a cluster of `markers`;
// `weigh(marker)` maps a marker to its contribution to `total` (defaults to 1).
// `total` also drives z-order, so denser clusters sit above sparser ones.
export function clusterMarkers(map, markers, options) {
  var buildContent = options.buildContent;
  var weigh = options.weigh || function () { return 1; };

  function render(cluster) {
    var total = 0;
    cluster.markers.forEach(function (m) { total += weigh(m); });

    return new google.maps.marker.AdvancedMarkerElement({
      position: cluster.position,
      content: buildContent(total, cluster.markers),
      zIndex: 1000 + total
    });
  }

  return new MarkerClusterer({
    map: map,
    markers: markers,
    algorithm: new SuperClusterAlgorithm({ radius: options.radius || 70 }),
    renderer: { render: render },
    onClusterClick: options.onClusterClick
  });
}
