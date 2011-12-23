$(function () {

    var marks;

    $.get('/map/spots', function (data, textStatus, jqXHR) {
        marks = data;
        $('#googleMap').gmap3(
            { action:'addMarkers',
                markers:marks
            }
        );
    });

    $('#googleMap').gmap3(
        { action:'init',
            options:{
                center:[50.43, 30.52],
                zoom:6,
                mapTypeId:google.maps.MapTypeId.HYBRID
            }
        }
    );

});