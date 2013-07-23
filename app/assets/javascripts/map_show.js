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
//= require map_init

$(function () {

  var marks,
      theMap = $('#googleMap');

  function adjustSizes() {
    var clientHeight = $(window).height(),
        clientWidth = $(window).width(),
        upper = $('#header').outerHeight(true),
        lower = $('div.footer:visible').outerHeight();
    $('div.mapContainer').height(clientHeight - upper - lower).width(clientWidth)
        .css('top', upper);
  }

  function showPhotos(cluster, event, data) {
    var image_ids = $.map(data.markers, function(x) {
      return x.data
    });
    $(".gallery_window").hide();
    $.ajax('photos/strip',
        {
          method: 'POST',
          data: JSON.stringify(image_ids),
          processData: false,
          contentType: "application/json; charset=utf-8",
          success: function(body) {
            $(".gallery_window").html(body)
                .css('bottom', $('div.footer:visible').outerHeight() + "px")
                .show();
          }
        });
  }

  adjustSizes();

  $(window).resize(adjustSizes);

  theMap.gmap3('init');

  $.get('/map/photos', function (data, textStatus, jqXHR) {
    marks = data;
    theMap.gmap3(
        { action: 'addMarkers',
          markers: marks,
          radius: 40,
          clusters: {
            // This style will be used for clusters with more than 0 markers
            0: {
              content: '<div class="marker-cluster marker-cluster-small"><div><span>CLUSTER_COUNT</span></div></div>',
              width: 30,
              height: 30
            },
            10: {
              content: '<div class="marker-cluster marker-cluster-medium"><div><span>CLUSTER_COUNT</span></div></div>',
              width: 35,
              height: 35
            },
            100: {
              content: '<div class="marker-cluster marker-cluster-large"><div><span>CLUSTER_COUNT</span></div></div>',
              width: 40,
              height: 40
            }
          },
          cluster: {
            events: {
              click: showPhotos
            }
          }
        },
        'autofit' // Zooms and moves to see all markers
    );
  });

});
