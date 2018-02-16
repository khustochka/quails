$(function () {

  $(document).tooltip({
    items: ".llc",
    content: function () {
      return $(this).data("title");
    },
    position: {
      my: "center bottom",
      at: "center top"
    }
  });

  $(".llc").prop("title", "");

});
