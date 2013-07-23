$(function () {

  var spForm = $('form.edit_species'),
      bringUp = $("<span>", {html: "&#8682;", class: "bringUp"}),
      variantInputs = $("form:not('.edit_species') div.input input"),
      finalReview = false;

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
    if (finalReview)
      document.location = $("a#nextSp").attr("href");
    else
      reborder();
  });

  spForm.on("ajax:error", function (e, data) {
    alert("Error saving species");
    finalReview = false;
  });

  $("#markReviewed").on("click", function () {
    $("input#species_reviewed").val("1");
    finalReview = true;
    spForm.submit();
  });

});
