// Drag-and-drop ordering for public locations
import Sortable from "../utils/sortable";

document.addEventListener("DOMContentLoaded", function() {
  var publicList = document.querySelector("[data-loci-public]");
  if (!publicList) return;

  var otherList = document.querySelector("[data-loci-sortable]:not([data-loci-public])");

  new Sortable(publicList, {
    connectWith: otherList,
    onUpdate: function() {
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
  });
});
