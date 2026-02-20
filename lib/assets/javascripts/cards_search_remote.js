//= require suggest_over_combo

$(function () {
// Cards search form

    var searchForm = document.querySelector('form.search');
    if (searchForm) searchForm.addEventListener('ajax:success', function (e) {
        $("#search-results").html(e.detail[0].body.innerHTML);
    });

});
