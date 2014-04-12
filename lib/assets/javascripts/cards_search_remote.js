//= require suggest_over_combo

$(function () {
// Cards search form

    var searchForm = $('form.search');
    searchForm.on('ajax:success', function (e, data) {
        $("#search-results").html(data);
    });

});
