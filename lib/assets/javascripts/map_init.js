//= require gmap3

$(function () {

    if (typeof google == 'object') {

        $().gmap3(
            'setDefault',
            {
                init: {
                    center: [48.2837, 31.62962],
                    zoom: 6,
                    mapTypeId: google.maps.MapTypeId.HYBRID,
                    mapTypeControlOptions: {
                        position: google.maps.ControlPosition.TOP_LEFT
                    },
                    streetViewControl: false,
                    panControlOptions: {
                        position: google.maps.ControlPosition.TOP_RIGHT
                    },
                    zoomControlOptions: {
                        position: google.maps.ControlPosition.TOP_RIGHT
                    }
                }
            }
        );
    }
});
