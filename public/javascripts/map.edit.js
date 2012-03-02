$(function () {

    function adjustSizes() {
        var clientHeight = $(window).height(),
            upper = $('#header').outerHeight(true) + $('#new_q').outerHeight();
        $('ul.obs-list').height(clientHeight - upper - 2);
        $('div#googleMap').height(clientHeight - upper);
        $('div#googleMap').width($(window).width() - 381);
    }

    function searchForSpots() {
        data = form.serializeArray();
        $.get("/map/search", data, function (data) {
            marks = data;
            $('#googleMap').gmap3(
                { action:'clear'
                },
                { action:'addMarkers',
                    markers:marks
                }
            );
        });
    }

    function buildObservations(data) {
        $(data).each(function () {
            $("<li>").append(
                $('<div>').html(this.species_str),
                $('<div>').html(this.when_where_str)
            )
            .appendTo($('ul.obs-list'));
        });
    }

    adjustSizes();

    $(window).resize(adjustSizes);

    var form = $('form.search');

    /* Make form remote */
    form.attr('action', "/observations/search");
    form.data('remote', true);

    form.on('ajax:beforeSend', function () {
        $('ul.obs-list').empty();
        //$('.observation_options').addClass('loading');
    });

    form.on('ajax:success', function (e, data) {
        buildObservations(data);
        searchForSpots();
    });

});