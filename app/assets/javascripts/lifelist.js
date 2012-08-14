//= require jquery
//= require jquery_ujs
//= require jquery_pjax

$(function() {
    // default timeout is causing page reload on heavy pages, like lifelist
    $('.filter-list a, table#lifelist th a').pjax('.main', {timeout: false});

    $('.main').on('pjax:start', showSpinner);

    function showSpinner() {
      $("h1", this).append("<img src='/img/loading.gif'>");
    }
});
