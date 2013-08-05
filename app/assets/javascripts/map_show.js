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
      theMap = $('#googleMap'), emptyOverlay;

  var bounds = {
    ukraine: new google.maps.LatLngBounds(
        new google.maps.LatLng(44.18, 21.92), new google.maps.LatLng(52.53, 41.13)
    ),
    usa: new google.maps.LatLngBounds(
        new google.maps.LatLng(36.66, -81.73), new google.maps.LatLng(45.02, -71.06)
    ) ,
    world: new google.maps.LatLngBounds(
        new google.maps.LatLng(36.66, -81.73), new google.maps.LatLng(52.53, 41.13)
    )
  };

  function fitToCountry(country) {
    theMap.gmap3("get").fitBounds(bounds[country]);
  }

  function newEmptyOverlay(map) {
    if (!emptyOverlay) {
      function Overlay() {
        this.onAdd = function () {
        };
        this.onRemove = function () {
        };
        this.draw = function () {
        };
        return google.maps.OverlayView.apply(this, []);
      }

      Overlay.prototype = google.maps.OverlayView.prototype;
      var emptyOverlay = new Overlay();
      emptyOverlay.setMap(map);
    }
    return emptyOverlay;
  }


  function adjustSizes() {
    var clientHeight = $(window).height(),
        clientWidth = $(window).width(),
        upper = $('#header').outerHeight(true),
        lower = $('div.footer:visible').outerHeight() || 0;
    $('div.mapContainer').height(clientHeight - upper - lower).width(clientWidth)
        .css('top', upper);
    var gmap = theMap.gmap3("get");
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
    var proj = newEmptyOverlay(theMap.gmap3("get")).getProjection(),
        px = proj.fromLatLngToContainerPixel(data.data.latLng),
        delta = theMap.height() - $(".gallery_window").height() - 20;
    if (px.y > delta) {
      theMap.gmap3("get").panBy(0, px.y - delta);
    }

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

  theMap.gmap3({
    map: {},
    panel: {
      options: {
        content: '<div class="map-panel">' +
            '<a class="pseudolink pan" href="#world">Весь мир</a> &nbsp; ' +
            '<a class="pseudolink pan" href="#ukraine">Украина</a> &nbsp; ' +
            '<a class="pseudolink pan" href="#usa">США</a>' +
            '</div>',
        top: true,
        left: 150
      }
    }
  });

  $.get('/map/photos', function (rdata, textStatus, jqXHR) {
    marks = [];
    var latLng;

    for (latLng in rdata) {
      marks.push({latLng: latLng.split(','), data: rdata[latLng]});
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
              calculator: function (vals) {
                var i, sum = 0;
                for (i in vals) {
                  sum = sum + vals[i].data.length;
                }
                return sum;
              },
              events: {
                click: showPhotos
              }
            }
          }
        }
    );
  });

  fitToCountry(window.location.hash.substring(1) || "world");

  $(".pan").click(function () {
    var country = this.hash.substring(1);
    fitToCountry(country);
  });

});
