//= require jquery_pjax
//= require pjax_spinner

$(function () {
  // default timeout is causing page reload on heavy pages, like lifelist
  $('.main').pjax('nav.pagination a');

  showSpinner(function () {
    $("nav.pagination", this).append("<img src='/img/loading_small.gif'>");
  });
});
