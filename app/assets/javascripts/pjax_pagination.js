//= require jquery_pjax

$(function () {
  // default timeout is causing page reload on heavy pages, like lifelist
  $('.main').pjax('nav.pagination a');

  Quails.features.pjaxSpinner.define(function () {
    $("nav.pagination", this).append("<img src='/img/loading_small.gif'>");
  });
});
