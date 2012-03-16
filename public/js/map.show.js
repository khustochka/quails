$(function () {

    var marks;

    $.get('/map/spots', function (data, textStatus, jqXHR) {
        marks = data;
        $('#googleMap').gmap3(
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