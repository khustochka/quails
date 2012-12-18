//= require jquery_ujs

$(function () {

  var spForm = $('form.edit_species'),
      bringUp = $("<span>", {html: "&#8682;", class: "bringUp"}),
      variantInputs = $("form:not('.edit_species') div.input input");

  function reborder() {
    variantInputs.each(
        function () {
          var inp = $(this);
          if (inp.val() === $("#" + inp.data("target")).val())
            inp.removeClass("mismatch");
          else
            inp.addClass("mismatch");
        }
    );
  }

  reborder();
  variantInputs.after(bringUp);

  $(".bringUp").on("click", function () {
    var inp = $(this).prev("input");
    $("#" + inp.data("target")).val(inp.val());
    spForm.submit();
  });

  spForm.on("ajax:success", function (e, data) {
    reborder();
  });

  spForm.on("ajax:error", function (e, data) {
    alert("Error saving species");
  });

});
