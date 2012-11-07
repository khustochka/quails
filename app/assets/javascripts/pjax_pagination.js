//= require jquery_ujs
//= require jquery_pjax

$(function() {
    // default timeout is causing page reload on heavy pages, like lifelist
    $('nav.pagination a').pjax('.main', {timeout: false});

    $('.main').on('pjax:start', showSpinner);

    function showSpinner() {
      $("nav.pagination", this).append("<img src='/img/loading_small.gif'>");
    }
});
