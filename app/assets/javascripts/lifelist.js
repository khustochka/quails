$(function () {
  // default timeout is causing page reload on heavy pages, like lifelist
  $('.main').pjax('.filter-list a:not(.advanced), table#lifelist th a');

  Quails.features.pjaxSpinner.init();

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
