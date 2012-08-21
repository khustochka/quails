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
//= require map_init
//= require suggest_over_combo

$(function () {

    function adjustSizes() {
        var clientHeight = $(window).height(),
            clientWidth = $(window).width(),
            upper = $('#header').outerHeight(true) + $('form.search').outerHeight(),
            leftmost = $('ul.obs-list').outerWidth(true);
        $('ul.obs-list').height(clientHeight - upper - 2);
        $('div.mapContainer').height(clientHeight - upper).width(clientWidth - leftmost)
            .css('top', upper).css('left', leftmost);
    }

    function closeInfoWindows() {
        var infowindow = theMap.gmap3({action:'get', name:'infowindow'});
        if (infowindow) infowindow.close();
    }

    var spotsStore;

    function buildObservations(data) {

        observCollection = {};
        spotsStore = {};

        var hoverText;

        var marks = $(data).map(function () {
            observCollection[this.id] =
                $("<li>").data('obs_id', this.id).append(
                    $('<div>').html(this.species_str),
                    $('<div>').html(this.when_where_str)
                ).appendTo($('ul.obs-list'));

            hoverText = $('div:first', observCollection[this.id]).text();

            return($.map(this.spots, function (spot, i) {
                spotsStore[spot.id] = spot;
                return {
                    lat:spot.lat,
                    lng:spot.lng,
                    tag:spot.observation_id,
                    data:{id:spot.id},
                    options:{title:hoverText}
                }
            }));
        });

        $('#googleMap').gmap3(
            'clear',
            { action:'addMarkers',
                markers:marks,
                marker:DEFAULT_MARKER_OPTIONS
            },
            'autofit' // Zooms and moves to see all markers
        );
    }

    adjustSizes();

    $(window).resize(adjustSizes);

    var searchForm = $('form.search');

    /* Make search form remote */
    searchForm.attr('action', "/observations/search/with_spots");
    searchForm.data('remote', true);

    searchForm.on('ajax:beforeSend', function () {
        $('ul.obs-list').empty();
        //$('.observation_options').addClass('loading');
    });

    searchForm.on('ajax:success', function (e, data) {
        buildObservations(data);
    });

    searchForm.submit();

    // the Map

    var theMap = $('#googleMap'),
        observCollection;

    var GRAY_ICON = "http://maps.google.com/mapfiles/marker_white.png",
        RED_ICON = "http://maps.google.com/mapfiles/marker.png";
    // TODO: add shadow?

    var DEFAULT_MARKER_OPTIONS = {
        options:{
            draggable:true,
            icon:GRAY_ICON
        },
        events:{
            click:function (marker, event, data) {
                var newForm = spotForm.clone(),
                    wndContent,
                    selectedObs = $('li.selected_obs'),
                    spotData = spotsStore[data.id];

                closeInfoWindows();

                if (selectedObs.length == 0) {
                    observCollection[spotData.observation_id].click();
                    selectedObs = $('li.selected_obs');
                }

                if (selectedObs.data('obs_id') == spotData.observation_id)
                    $('#spot_id', newForm).val(data.id);

                $('#spot_exactness_' + spotData.exactness, newForm).attr('checked', true);
                $('#spot_memo', newForm).attr('value', spotData.memo);
                // It is public by default so I have to do something only in case it should be false
                // by I may have to update this logic if the default is changed
                if (!spotData.public) {
                    $('#spot_public', newForm).attr('checked', null);
                }

                $('#spot_lat', newForm).val(marker.position.lat());
                $('#spot_lng', newForm).val(marker.position.lng());
                $('#spot_zoom', newForm).val(spotData.zoom);
                $('#spot_observation_id', newForm).val(selectedObs.data('obs_id'));
                wndContent = newForm.html();

                theMap.gmap3({
                    action:'addInfoWindow',
                    anchor:marker,
                    options:{
                        content:wndContent
                    }
                });
            },
            dragstart:function (marker, event, data) {
                closeInfoWindows();
                var selected = $('li.selected_obs'),
                    spotData = spotsStore[data.id];
                if (selected.length == 0 || selected.data('obs_id') != spotData.observation_id) {
                    observCollection[spotData.observation_id].click();
                }
            },
            dragend:function (marker, event, data) {
                var spotData = spotsStore[data.id];
                $.post(
                    $('form', spotForm).attr('action'),
                    {spot:{
                        id:data.id,
                        lat:marker.getPosition().lat(),
                        lng:marker.getPosition().lng(),
                        // Change zoom only if it was increased
                        zoom:Math.max(spotData.zoom, marker.getMap().zoom)
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

        var activeMarkers = $('#googleMap').gmap3({
            action:'get',
            name:'marker',
            all:true,
            tag:$('.selected_obs').data('obs_id')
        });

        $.each(activeMarkers, function (i, marker) {
            marker.setIcon(GRAY_ICON);
            marker.setZIndex($(marker).data['OrigZIndex']);
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
            $(marker).data['OrigZIndex'] = marker.getZIndex();
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
                    $('#spot_exactness_1', newForm).attr('checked', true); // Check the "exact" value
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
            selectedObs = $('li.selected_obs'),
            markerOptions = jQuery.extend(true, {}, DEFAULT_MARKER_OPTIONS);
        // Add new marker only if spot_id was empty

        if ($('#spot_id', '#new_spot').val() == '') {
            markerOptions['data'] = {id:data.id};
            markerOptions['tag'] = selectedObs.data('obs_id');
            markerOptions.options.icon = RED_ICON;
            markerOptions.options.title = $('div:first', selectedObs).text();
            markerOptions.options.zIndex = google.maps.Marker.MAX_ZINDEX;
            theMap.gmap3({
                action:'addMarker',
                latLng:[data.lat, data.lng],
                marker:markerOptions
            });
        }

        // Store updated spot data
        spotsStore[data.id] = data;
        infowindow.close();
    });

});
