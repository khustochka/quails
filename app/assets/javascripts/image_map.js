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

$(function () {

    var theMap = $('#googleMap'),
        activeMarkers,
        firstObserv = $('.obs-list li input').val();

    function closeInfoWindows() {
        var infowindow = theMap.gmap3({action:'get', name:'infowindow'});
        if (infowindow) infowindow.close();
    }

    var GRAY_ICON = "http://maps.google.com/mapfiles/marker_white.png",
        RED_ICON = "http://maps.google.com/mapfiles/marker.png";

    function bindImageToMarker(marker, data) {

        $.post(patch_url, {'image':{'spot_id':data.id}}, function (data2) {

            var activeMarker = $('#googleMap').gmap3({
                action:'get',
                name:'marker',
                first:true,
                tag:image_spot
            });

            activeMarker.setIcon(GRAY_ICON);
            activeMarker.setZIndex($(marker).data['OrigZIndex']);

            image_spot = data.id;

            marker.setIcon(RED_ICON);
            $(marker).data['OrigZIndex'] = marker.getZIndex();
            marker.setZIndex(google.maps.Marker.MAX_ZINDEX);
        });
    }

    var DEFAULT_MARKER_OPTIONS = {
        options:{
            draggable:false,
            icon:GRAY_ICON
        },
        events:{
            click:function (marker, event, data) {
                closeInfoWindows();
                bindImageToMarker(marker, data);
            }
        }
    };

    marks = $.map(marks, function (el) {
        el.tag = el.id;
        el.data = {id:el.id};
        return el;
    });

    // Spot edit form

    var spotForm = $('.spot_form_container').detach();

    // The Map

    theMap.width('1024px');
    theMap.height('600px');

    theMap.gmap3({
        action:'init',
        options:{
            draggableCursor:'pointer'
        },
        events:{
            click:function (map, event) {
                var newForm = spotForm.clone(),
                    wndContent;

                closeInfoWindows();
                $('#spot_lat', newForm).val(event.latLng.lat());
                $('#spot_lng', newForm).val(event.latLng.lng());
                $('#spot_zoom', newForm).val(map.zoom);
                $('#spot_exactness_1', newForm).attr('checked', true); // Check the "exact" value
                // TODO: create spots for all image's observations
                $('#spot_observation_id', newForm).val(firstObserv);
                wndContent = newForm.html();

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

            markerOptions = jQuery.extend(true, {}, DEFAULT_MARKER_OPTIONS);

            markerOptions['data'] = {id:data.id};
            markerOptions['tag'] = data.id;
            theMap.gmap3({
                action:'addMarker',
                latLng:[data.lat, data.lng],
                marker:markerOptions
            });

        infowindow.close();

        // Simulate click

        var addedMarker = $('#googleMap').gmap3({
            action:'get',
            name:'marker',
            first:true,
            tag:data.id
        });

        bindImageToMarker(addedMarker, {id: data.id});
    });

    $(document).on('ajax:error', '#new_spot', function (e, data) {
        alert("Error submitting form");
    });

    theMap.gmap3(
        { action:'addMarkers',
            markers:marks,
            marker:DEFAULT_MARKER_OPTIONS
        },
        'autofit' // Zooms and moves to see all markers
    );

    if (image_spot) {

        activeMarkers = $('#googleMap').gmap3({
            action:'get',
            name:'marker',
            all:true,
            tag:image_spot
        });

        $.each(activeMarkers, function (i, marker) {
            marker.setIcon(RED_ICON);
            $(marker).data['OrigZIndex'] = marker.getZIndex();
            marker.setZIndex(google.maps.Marker.MAX_ZINDEX);
        });
    }
});
