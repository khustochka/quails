//= require jquery
//= require jquery_ujs
//= require jquery_pjax

$(function() {
    // default timeout is causing page reload on heavy pages, like lifelist
    $('.filter-list a, table#lifelist th a').pjax('[data-pjax-container]', {timeout: false});

    $(document)
        .on('pjax:start', '.main', showSpinner)
        .on('pjax:end', '.main', hideSpinner);

    function showSpinner() {
      $("h1", this).append("<img src='/img/loading.gif'>");
    }

    function hideSpinner() {
    }
});
