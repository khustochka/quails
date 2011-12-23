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

    $('#googleMap').gmap3(
        { action:'init',
            options:{
                center:[48.2837, 31.62962],
                zoom:6,
                mapTypeId:google.maps.MapTypeId.HYBRID
            }
        }
    );

});