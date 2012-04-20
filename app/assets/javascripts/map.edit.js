// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery_ujs
//= require map.init
//= require suggest_over_combo

$(function () {

    function adjustSizes() {
        var clientHeight = $(window).height(),
            clientWidth = $(window).width(),
            upper = $('#header').outerHeight(true) + $('#new_q').outerHeight(),
            leftmost = $('ul.obs-list').outerWidth(true);
        $('ul.obs-list').height(clientHeight - upper - 2);
        $('div#googleMap').height(clientHeight - upper).width(clientWidth - leftmost)
            .css('top', upper).css('left', leftmost);
    }

    function searchForSpots() {
        data = form.serializeArray();
        $.get("/map/spots/search", data, function (data) {
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

    // Spot edit form

    var spotForm = $('.observ_form_container').detach();

    // Starting hardcore map stuff

    var theMap = $('#googleMap');

    theMap.gmap3({
        action:'init',
        options:{
            draggableCursor:'pointer'
        },
        events:{
            click:function(map, event) {
                theMap.gmap3({
                    action:'addInfoWindow',
                    latLng:event.latLng,
                    options:{
                        content:spotForm.html()
                    }
                });
            }
        }
    });

});