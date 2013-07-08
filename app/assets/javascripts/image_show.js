//= require jquery_pjax
//= require pjax_spinner

$(function () {

  // Not used for now
  function resizeTable() {
    $('.image_nav').width($('.image_canvas').width());
  }

  // default timeout is causing page reload on heavy pages, like lifelist
  $('.main').pjax('a.img_prev_next');

  showSpinner(function (event) {
    var link = $(event.relatedTarget);
    link.replaceWith("<img src='/img/loading_small.gif'>");
  });
});
