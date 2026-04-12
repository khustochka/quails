import { createMap, autofitMarkers } from "./map-init";
import consumer from "../../channels/consumer";

var MARKER_DEFAULT = "#1a73e8";
var MARKER_HIGHLIGHT = "#1a73e8";

export function initEbirdAlerts(mapEl) {
  var locations = JSON.parse(mapEl.dataset.locations || "[]");
  var map = createMap(mapEl);
  var infoWindow = new google.maps.InfoWindow();

  // marker per location
  var markers = [];
  // map from species_code -> array of marker indices
  var speciesMarkers = {};

  locations.forEach(function (loc, i) {
    var codeSet = new Set();
    loc.observations.forEach(function (obs) {
      if (obs.species_code) codeSet.add(obs.species_code);
    });
    var speciesCodes = Array.from(codeSet);

    var label = String(speciesCodes.length);

    var marker = new google.maps.Marker({
      position: { lat: loc.lat, lng: loc.lng },
      map: map,
      title: loc.name,
      label: {
        text: label,
        color: "white",
        fontSize: "11px",
        fontWeight: "bold"
      },
      icon: circleIcon(MARKER_DEFAULT)
    });

    markers.push({ marker: marker, loc: loc, speciesCodes: speciesCodes });

    speciesCodes.forEach(function (code) {
      if (!speciesMarkers[code]) speciesMarkers[code] = [];
      speciesMarkers[code].push(i);
    });

    marker.addListener("click", function () {
      infoWindow.setContent(buildInfoContent(loc));
      infoWindow.open(map, marker);
    });
  });

  autofitMarkers(map, markers.map(function (m) { return m.marker; }));

  // Side panel species click — highlight markers containing that species
  var speciesItems = document.querySelectorAll(".alerts-species-list li");
  var activeCode = null;

  var sheetSpeciesEl = document.querySelector(".alerts-sheet-species");

  function setSheetSpecies(name) {
    if (!sheetSpeciesEl) return;
    sheetSpeciesEl.textContent = name || "";
  }

  speciesItems.forEach(function (li) {
    li.addEventListener("click", function () {
      var code = li.dataset.speciesCode;

      // deselect
      if (activeCode === code) {
        activeCode = null;
        speciesItems.forEach(function (el) { el.classList.remove("is-active"); });
        setSheetSpecies(null);
        markers.forEach(function (m) {
          m.marker.setMap(map);
          m.marker.setIcon(circleIcon(MARKER_DEFAULT));
        });
        return;
      }

      activeCode = code;
      speciesItems.forEach(function (el) { el.classList.remove("is-active"); });
      li.classList.add("is-active");
      var name = li.querySelector(".alerts-species-name");
      setSheetSpecies(name ? name.textContent : code);

      var bottomSheet = document.querySelector(".alerts-bottom-sheet");
      if (bottomSheet) bottomSheet.classList.remove("is-expanded");

      var highlighted = speciesMarkers[code] || [];
      markers.forEach(function (m, i) {
        if (highlighted.indexOf(i) !== -1) {
          m.marker.setMap(map);
          m.marker.setIcon(circleIcon(MARKER_HIGHLIGHT));
        } else {
          m.marker.setMap(null);
        }
      });

    });
  });
}

function circleIcon(color) {
  return {
    path: google.maps.SymbolPath.CIRCLE,
    fillOpacity: 1,
    fillColor: color,
    strokeColor: "white",
    strokeWeight: 1.5,
    scale: 14
  };
}

function buildInfoContent(loc) {
  var lines = [
    "<div class=\"alerts-popup\">",
    "<strong>" + escHtml(loc.name) + "</strong>",
    "<ul>"
  ];

  // group by species_code to deduplicate, collect checklist links
  var bySpecies = {};
  loc.observations.forEach(function (obs) {
    var key = obs.species_code || obs.species_name;
    if (!bySpecies[key]) {
      bySpecies[key] = { name: obs.species_name, sci: obs.species_sci, checklists: [] };
    }
    if (obs.checklist_id) {
      bySpecies[key].checklists.push({ id: obs.checklist_id, date: obs.date, count: obs.count });
    }
  });

  Object.values(bySpecies).forEach(function (sp) {
    var clLinks = sp.checklists.map(function (cl) {
      return "<a href=\"https://ebird.org/checklist/" + escHtml(cl.id) + "\" target=\"_blank\" rel=\"noopener\">" +
        escHtml(cl.date || cl.id) + (cl.count ? " (" + cl.count + ")" : "") + "</a>";
    }).join(", ");
    lines.push(
      "<li><span class=\"alerts-popup-species\">" + escHtml(sp.name) + "</span>" +
      " <em>" + escHtml(sp.sci) + "</em>" +
      (clLinks ? " — " + clLinks : "") +
      "</li>"
    );
  });

  lines.push("</ul></div>");
  return lines.join("");
}

function escHtml(str) {
  return String(str || "")
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;");
}

document.addEventListener("DOMContentLoaded", function () {
  // Bottom sheet (mobile)
  var sheet = document.querySelector(".alerts-bottom-sheet");
  if (sheet) {
    var handle = sheet.querySelector(".alerts-bottom-sheet-handle");
    handle.addEventListener("click", function () {
      sheet.classList.toggle("is-expanded");
    });
  }

  document.querySelector(".alerts-list").addEventListener('click', e => {
    const card = e.target.closest('li[data-link');
    if (!card) return;

    // If user clicked a real link, do nothing
    if (e.target.closest('a')) return;

    window.location = card.dataset.link;
  });

  document.querySelectorAll(".alerts-refresh-btn").forEach(function (link) {
    link.addEventListener("ajax:success", function () {
      var linkSid = link.dataset.sid;
      link.classList.add("is-loading");

      var sub = consumer.subscriptions.create({ channel: "EBirdAlertsChannel" }, {
        received: function (data) {
          if (data && data.sid && data.sid !== linkSid) return;
          sub.unsubscribe();
          if (link.closest("li.is-active")) {
            window.location.reload();
          } else {
            window.location.href = window.location.pathname + "?sid=" + encodeURIComponent(linkSid);
          }
        }
      });
    });
  });
});
