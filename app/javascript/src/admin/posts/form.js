// Attach/detach cards on post form page
import "../shared/cards-search";

function refreshAttachedList() {
  var wrapper = document.querySelector("[data-attached-list]");
  if (!wrapper) return;
  var url = wrapper.getAttribute("data-attached-url");
  if (!url) return;
  fetch(url, { headers: { Accept: "text/html" } })
    .then(function(r) { return r.text(); })
    .then(function(html) {
      var doc = new DOMParser().parseFromString(html, "text/html");
      var fresh = doc.querySelector("[data-attached-list]");
      if (fresh) wrapper.innerHTML = fresh.innerHTML;
    });
}

document.addEventListener("DOMContentLoaded", function() {

  // Show loading state on attach/detach
  document.addEventListener("ajax:beforeSend", function(e) {
    if (e.target.matches(".card_post_op")) {
      var card = e.target.closest(".observ_card");
      if (card) card.classList.add("loading");
    }
  });

  // Reload search results and attached list after attach/detach
  document.addEventListener("ajax:success", function(e) {
    if (e.target.matches(".card_post_op")) {
      var form = document.querySelector("[data-cards-search]");
      if (form) form.requestSubmit();
      refreshAttachedList();
    }
  });
});
