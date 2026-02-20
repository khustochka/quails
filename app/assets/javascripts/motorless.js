//= require suggest_over_combo

$(function() {
  document.querySelectorAll("a.mark_motorless").forEach(function(el) {
    el.addEventListener("ajax:success", function() {
      var b = document.createElement("b");
      b.textContent = "Motorless";
      el.replaceWith(b);
    });
  });
});
