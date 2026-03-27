// Drag-and-drop ordering for public locations
import Sortable from "../utils/sortable";

document.addEventListener("DOMContentLoaded", function() {
  var publicList = document.querySelector("[data-loci-public]");
  if (!publicList) return;

  var otherList = document.querySelector("[data-loci-sortable]:not([data-loci-public])");
  var filterInput = document.querySelector("[data-loci-filter]");
  var sortable = new Sortable(publicList, {
    connectWith: otherList,
    onUpdate: function() {
      ensureRemoveButtons();
      saveOrder();
    }
  });

  function saveOrder() {
    var order = Array.from(publicList.children).map(function(li) {
      return parseInt(li.dataset.locId, 10);
    });
    var token = document.querySelector("meta[name=csrf-token]").content;
    fetch("/loci/save_order", {
      method: "POST",
      headers: {
        "Content-Type": "application/json; charset=utf-8",
        "X-CSRF-Token": token
      },
      body: JSON.stringify({order: order})
    });
  }

  // Add × button to items in the public list that don't have one
  function ensureRemoveButtons() {
    Array.from(publicList.children).forEach(function(li) {
      if (!li.querySelector("[data-loci-remove]")) {
        var span = document.createElement("span");
        span.className = "remove";
        span.dataset.lociRemove = "true";
        span.textContent = "×";
        li.appendChild(span);
      }
    });
    // Remove × buttons from items in the other list
    otherList.querySelectorAll("[data-loci-remove]").forEach(function(el) {
      el.remove();
    });
  }

  // Click × to remove from public list
  publicList.addEventListener("click", function(e) {
    if (!e.target.matches("[data-loci-remove]")) return;
    var li = e.target.closest("li");
    e.target.remove();
    otherList.prepend(li);
    saveOrder();
  });

  // Server-side filter for the "other" list
  if (filterInput) {
    var searchTimeout = null;

    filterInput.addEventListener("input", function() {
      var term = filterInput.value;
      if (searchTimeout) clearTimeout(searchTimeout);
      searchTimeout = setTimeout(function() {
        fetch("/loci/public?term=" + encodeURIComponent(term))
          .then(function(r) { return r.json(); })
          .then(function(locs) {
            otherList.innerHTML = "";
            locs.forEach(function(loc) {
              var li = document.createElement("li");
              li.dataset.locId = loc.id;
              li.textContent = loc.name;
              li.draggable = true;
              otherList.appendChild(li);
            });
          });
      }, 300);
    });
  }
});
