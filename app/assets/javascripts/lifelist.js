//= require jquery_ujs
//= require jquery_pjax

$(function () {
    // default timeout is causing page reload on heavy pages, like lifelist
    $('.filter-list a, table#lifelist th a').pjax('.main', {timeout:false});

    $('.main').on('pjax:start', showSpinner);

    function showSpinner(event) {
        var link = $(event.relatedTarget);
        var row = $(link).parents('.filter-list');
        if (row.length < 1) row = $(link).parents('table#lifelist tr');
        row.append("<img src='/img/loading_small.gif'>");
    }
});
