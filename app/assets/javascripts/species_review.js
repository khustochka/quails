//= require jquery_ujs

$(function () {

  var bringUp = $("<span>", {html: "&#8682;", class: "bringUp"});
  $("form:not('.edit_species') div.input").append(bringUp);

  function reborder() {
    // should remove or add the red border
  }

  $(".bringUp").on("click", function() {
    var inp = $(this).prev('input');
    $("#" + inp.data("target")).val(inp.val());
    reborder();
  });

});
