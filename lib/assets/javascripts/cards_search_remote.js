//= require suggest_over_combo

$(function () {
// Cards search form

    var searchForm = $('form.search');
    searchForm.on('ajax:success', function (e) {
        const [_, status, xhr] = e.detail;
        $("#search-results").html(xhr.response);
    });

});
