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

    function closeInfoWindows() {
        var infowindow = theMap.gmap3({action:'get', name:'infowindow'});
        if (infowindow) infowindow.close();
    }

    function buildObservations(data) {

        observCollection = {};

        var marks = $(data).map(function () {
            observCollection[this.id] =
                $("<li>").data('obs_id', this.id).append(
                    $('<div>').html(this.species_str),
                    $('<div>').html(this.when_where_str)
                ).appendTo($('ul.obs-list'));

            return($.map(this.spots, function (spot, i) {
                return {
                    lat:spot.lat,
                    lng:spot.lng,
                    tag:spot.observation_id,
                    data:spot
                }
            }));
        });

        $('#googleMap').gmap3(
            { action:'clear'
            },
            { action:'addMarkers',
                markers:marks,
                marker:DEFAULT_MARKER_OPTIONS
            }
        );
    }

    adjustSizes();

    $(window).resize(adjustSizes);

    var searchForm = $('form.search');

    /* Make search form remote */
    searchForm.attr('action', "/observations/with_spots");
    searchForm.data('remote', true);

    searchForm.on('ajax:beforeSend', function () {
        $('ul.obs-list').empty();
        //$('.observation_options').addClass('loading');
    });

    searchForm.on('ajax:success', function (e, data) {
        buildObservations(data);
    });

    // the Map

    var theMap = $('#googleMap'),
        activeMarkers = [],
        observCollection;

    var GRAY_ICON = "http://maps.google.com/mapfiles/marker_white.png",
        RED_ICON = "http://maps.google.com/mapfiles/marker.png";

    var DEFAULT_MARKER_OPTIONS = {
        options:{
            draggable:true,
            icon:GRAY_ICON
        },
        events:{
            click:function (marker, event, data) {
                alert(data);
            },
            dragstart:function (marker, event, data) {
                closeInfoWindows();
                var selected = $('li.selected_obs');
                if (selected.length == 0 || selected.data('obs_id') != data.observation_id) {
                    observCollection[data.observation_id].click();
                }
            },
            dragend:function (marker, event, data) {
                $.post(
                    $('form', spotForm).attr('action'),
                    {spot:{
                        id:data.id,
                        lat:marker.getPosition().lat(),
                        lng:marker.getPosition().lng(),
                        // Change zoom only if it was increased
                        zoom:Math.max(data.zoom, marker.getMap().zoom)
                    }}
                );
            }
        }
    };


    // Spot edit form

    var spotForm = $('.observ_form_container').detach();

    // Toggle selected observation

    $('.obs-list').on('click', 'li', function () {
        closeInfoWindows();

        $.each(activeMarkers, function (i, marker) {
            marker.setIcon(GRAY_ICON);
            marker.setZIndex(google.maps.Marker.MAX_ZINDEX - 1);
        });

        $('li.selected_obs').removeClass('selected_obs');
        $(this).addClass('selected_obs');

        activeMarkers = $('#googleMap').gmap3({
            action:'get',
            name:'marker',
            all:true,
            tag:$(this).data('obs_id')
        });

        $.each(activeMarkers, function (i, marker) {
            marker.setIcon(RED_ICON);
            marker.setZIndex(google.maps.Marker.MAX_ZINDEX);
        });
    });

    // Starting hardcore map stuff

    theMap.gmap3({
        action:'init',
        options:{
            draggableCursor:'pointer'
        },
        events:{
            click:function (map, event) {
                var newForm = spotForm.clone(),
                    wndContent,
                    selectedObs = $('li.selected_obs');

                closeInfoWindows();

                if (selectedObs.length == 0) wndContent = "<p>No observation selected</p>";
                else {
                    $('#spot_lat', newForm).val(event.latLng.lat());
                    $('#spot_lng', newForm).val(event.latLng.lng());
                    $('#spot_zoom', newForm).val(map.zoom);
                    $('#spot_observation_id', newForm).val(selectedObs.data('obs_id'));
                    wndContent = newForm.html();
                }
                theMap.gmap3({
                    action:'addInfoWindow',
                    latLng:event.latLng,
                    options:{
                        content:wndContent
                    }
                });
            }
        }
    });

    $(document).on('ajax:success', '#new_spot', function (e, data) {
        var infowindow = theMap.gmap3({action:'get', name:'infowindow'}),
        markerOptions = DEFAULT_MARKER_OPTIONS;
        markerOptions['data'] = data;
        markerOptions.options.icon = RED_ICON;
        theMap.gmap3({
            action:'addMarker',
            latLng:infowindow.getPosition(),
            marker:markerOptions
        });
        infowindow.close();
    });

});