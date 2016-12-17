$(function () {
  // default timeout is causing page reload on heavy pages, like lifelist
  $('.main').pjax('.filter-list a:not(.advanced), table#lifelist th a');

  Quails.features.pjaxSpinner.define(function (event) {
    var link = $(event.relatedTarget);
    var row = $(link).parents('.filter-list');
    if (row.length < 1) row = $(link).parents('table#lifelist tr');
    row.append("<img src='/img/loading_small.gif' class='spinner-img'>");
  });

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
