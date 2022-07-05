//= require map_init

$(function () {

    var marks,
        template = '<div class="marker-cluster marker-cluster-SIZE"><span>CLUSTER_COUNT</span></div>',
        theMap = $('#googleMap');


    function adjustSizes() {
        var clientHeight = $(window).height(),
            clientWidth = $(window).width(),
            upper = $('#header').outerHeight(true)
                + ($('.map-panel').css("position") == 'static' ? $('.map-panel').outerHeight(true) : 0),
            lower = $('div.footer:visible').outerHeight() || 0;
        $('div.mapContainer').height(clientHeight - upper - lower).width(clientWidth)
            .css('top', upper);
        var gmap = theMap.gmap3("get");
        if (typeof(gmap) !== 'undefined' && gmap !== null) google.maps.event.trigger(gmap, 'resize');

    }

    adjustSizes();

    $(window).resize(adjustSizes);

    if (window.mapEnabled) {
        theMap.gmap3();

        $.get('/map/loci', function (rdata, textStatus, jqXHR) {
            marks = [];
            var latLng;

            for (latLng in rdata) {
                marks.push({latLng: rdata[latLng], data: rdata[latLng]});
            }

            theMap.gmap3({
                  marker: {
                      values: marks,
                      // cluster: {
                      //     force: true,
                      //     radius: 40,
                      //     // This style will be used for clusters with more than 0 markers
                      //     0: {
                      //         content: template.replace('SIZE', 'small'),
                      //         width: 25,
                      //         height: 25
                      //     },
                      //     10: {
                      //         content: template.replace('SIZE', 'medium'),
                      //         width: 30,
                      //         height: 30
                      //     },
                      //     100: {
                      //         content: template.replace('SIZE', 'large'),
                      //         width: 35,
                      //         height: 35
                      //     },
                      //     calculator: function (vals) {
                      //         var i, sum = 0;
                      //         for (i in vals) {
                      //             sum = sum + vals[i].data.length;
                      //         }
                      //         return sum;
                      //     }
                      // }
                  }
              }
            );
        });
    }
});
