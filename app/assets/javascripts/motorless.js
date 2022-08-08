//= require suggest_over_combo

$(function() {
  $("a.mark_motorless").on("ajax:success", function() {
    $(this).replaceWith($("<b>Motorless</b>"));
  });
});
