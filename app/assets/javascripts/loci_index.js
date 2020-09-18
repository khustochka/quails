$(function () {

  $(document).tooltip({
    items: ".full_name_icon",
    content: function () {
      return $(this).data("title");
    },
    position: {
      my: "center bottom",
      at: "center top"
    }
  });

  $(".full_name_icon").prop("title", "");

});
