$(function () {

  $(document).tooltip({
    items: ".lifer-locus-icon",
    content: function () {
      return $(this).data("title");
    },
    position: {
      my: "center bottom",
      at: "center top"
    }
  });

  $(".lifer-locus-icon").prop("title", "");

});
