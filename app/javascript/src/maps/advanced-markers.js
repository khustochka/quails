import { importLibrary } from "@googlemaps/js-api-loader";

// Shared by the visitor and admin map bundles, so it lives outside both.
//
// google.maps.marker.AdvancedMarkerElement has two preconditions that are easy
// to satisfy only halfway: the "marker" library must be imported, and the map
// must be built with a mapId. Miss the first and the constructor is undefined;
// miss the second and Google logs "The map is initialized without a valid Map
// ID, which will prevent use of Advanced Markers" and nothing renders. They are
// exported together here so a map cannot pick up one without the other.
//
// This ID is NOT registered in Google Cloud Console. It exists only to satisfy
// the precondition above; Google falls back to a default-styled map. Registering
// it (or any ID) is what would make cloud-based map styling possible — until
// then, styling configured against this ID would silently do nothing. One ID is
// enough for every map: it is a styling handle, not a per-page credential.
export var MAP_ID = "quails-map";

export function loadAdvancedMarkers() {
  return importLibrary("marker");
}
