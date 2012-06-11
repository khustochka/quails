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

    var marks,
        theMap = $('#googleMap');

    theMap.gmap3('init');

    $.get('/map/spots', function (data, textStatus, jqXHR) {
        marks = data;
        theMap.gmap3(
            { action:'addMarkers',
                markers:marks,
                radius:40,
                clusters:{
                    // This style will be used for clusters with more than 0 markers
                    0:{
                        content:'<div class="cluster">CLUSTER_COUNT</div>',
                        width:46,
                        height:28
                    }
                }
            }
        );
    });

});
