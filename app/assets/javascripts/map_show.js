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
// TODO: move json3 into ie_fix with html5shiv ?
//= require json3
//= require map_init

$(function () {

  var marks,
      template = '<div class="marker-cluster marker-cluster-SIZE"><span>CLUSTER_COUNT</span></div>',
      theMap = $('#googleMap');


  function adjustSizes() {
    var clientHeight = $(window).height(),
        clientWidth = $(window).width(),
        upper = $('#header').outerHeight(true),
        lower = $('div.footer:visible').outerHeight() || 0;
    $('div.mapContainer').height(clientHeight - upper - lower).width(clientWidth)
        .css('top', upper);
    var gmap = theMap.gmap3('get');
    if (typeof(gmap) !== 'undefined' && gmap !== null) google.maps.event.trigger(gmap, 'resize');
    if ($(".gallery_window:visible").length > 0) {
      $(".gallery_window").css('bottom', lower + "px");
    }

  }

  function showPhotos(cluster, event, data) {
    var image_ids = $.map(data.data.markers, function (x) {
      return x.data
    }), lower = $('div.footer:visible').outerHeight() || 0;
    $(".gallery_window")
        .css('bottom', lower + "px")
        .show();
    $(".gallery_container").html("").scrollLeft(0).addClass('loading');
    $(".marker-cluster.active-cluster").removeClass("active-cluster");
    $(".marker-cluster", cluster.main.getDOMElement()).addClass("active-cluster");
    $.ajax('photos/strip',
        {
          method: 'POST',
          data: JSON.stringify(image_ids),
          processData: false,
          contentType: "application/json; charset=utf-8",
          success: function (body) {
            $(".gallery_container").removeClass('loading').html(body);
          },
          error: function (xhr, text, error) {
            $(".gallery_container").removeClass('loading').html("<h2>Error :(</h2>");
          }
        });
  }

  adjustSizes();

  $(window).resize(adjustSizes);

  $("span.close").click(function () {
    $(".marker-cluster.active-cluster").removeClass("active-cluster");
    $(".gallery_window").hide();
  });

  theMap.gmap3('map');

  $.get('/map/photos', function (rdata, textStatus, jqXHR) {
    marks = [];
    var m;

    for (var i = 0; i < rdata.length; i++) {
      m = rdata[i];
      marks.push({lat: m[0], lng: m[1], data: m[2]});
    }

    theMap.gmap3({
          marker: {
            values: marks,
            cluster: {
              force: true,
              radius: 40,
              // This style will be used for clusters with more than 0 markers
              0: {
                content: template.replace('SIZE', 'small'),
                width: 25,
                height: 25
              },
              10: {
                content: template.replace('SIZE', 'medium'),
                width: 30,
                height: 30
              },
              100: {
                content: template.replace('SIZE', 'large'),
                width: 35,
                height: 35
              },
              events: {
                click: showPhotos
              }
            }
          }
        },
        'autofit' // Zooms and moves to see all markers
    );
  });

});
