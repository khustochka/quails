// Cards search form — shared by post-form and observation-move
document.addEventListener("DOMContentLoaded", function() {
  var searchForm = document.querySelector("[data-cards-search]");
  if (searchForm) searchForm.addEventListener("ajax:success", function(e) {
    document.querySelector("[data-cards-search-results]").innerHTML = e.detail[0].body.innerHTML;
  });
});
