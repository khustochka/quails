// Attach/detach cards on post form page
import "../shared/cards-search";

document.addEventListener("DOMContentLoaded", function() {

  // Show loading state on attach/detach
  document.addEventListener("ajax:beforeSend", function(e) {
    if (e.target.matches(".card_post_op")) {
      var card = e.target.closest(".observ_card");
      if (card) card.classList.add("loading");
    }
  });

  // Reload search results after attach/detach
  document.addEventListener("ajax:success", function(e) {
    if (e.target.matches(".card_post_op")) {
      var form = document.querySelector("[data-cards-search]");
      if (form) form.requestSubmit();
    }
  });
});
