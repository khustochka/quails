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
        activeMarkers;

    var GRAY_ICON = "http://maps.google.com/mapfiles/marker_white.png",
        RED_ICON = "http://maps.google.com/mapfiles/marker.png";
    // TODO: add shadow?

    var DEFAULT_MARKER_OPTIONS = {
        options:{
            draggable:true,
            icon:GRAY_ICON
        }
    };

    marks = $.map(marks, function (el) {
        el.tag = el.id;
        return el;
    });

    theMap.width('1024px');
    theMap.height('600px');

    theMap.gmap3('init');

    theMap.gmap3(
        { action:'addMarkers',
            markers:marks,
            options:DEFAULT_MARKER_OPTIONS
        },
        'autofit' // Zooms and moves to see all markers
    );

//    if (image_spot) {
//
//        activeMarkers = $('#googleMap').gmap3({
//            action:'get',
//            name:'marker',
//            all:true,
//            tag:image_spot
//        });
//
//        $.each(activeMarkers, function (i, marker) {
//            marker.setIcon(RED_ICON);
//            $(marker).data['OrigZIndex'] = marker.getZIndex();
//            marker.setZIndex(google.maps.Marker.MAX_ZINDEX);
//        });
//    }
});
