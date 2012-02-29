$(function () {

    function adjustSizes() {
        var clientHeight = $(window).height(),
            upper = $('#header').outerHeight(true) + $('#new_q').outerHeight();
        $('ul.obs-list').height(clientHeight - upper - 1);
        $('div#googleMap').height(clientHeight - upper);
        $('div#googleMap').width($(window).width() - 381);
    }

    function searchForObservations() {
        $('ul.obs-list').empty();
        //$('.observation_options').addClass('loading');
        var data = $("input#q_observ_date_eq, select#q_locus_id_eq, select#q_species_id_eq," +
            "input#q_mine_eq_, input#q_mine_eq_true, input#q_mine_eq_false").serializeArray();
        $.get("/observations/search", data, function (data) {
            //$('.observation_options').removeClass('loading');
            buildObservations(data);
        });
    }

    function buildObservations(data) {
        $(data).each(function () {
            $("<li>")
                .append($('<span>').append(
                $('<div>').html(this.species_str),
                $('<div>').html(this.when_where_str))
            )
            .appendTo($('ul.obs-list'));
        });
    }

    adjustSizes();

    $(window).resize(adjustSizes);

    $('form.search').submit(function () {
        searchForObservations();
        return false; // Prevent submission
    });

});