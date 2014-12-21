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
      theMap = $('#googleMap'), emptyOverlay,
      photo_strip_url = $(".gallery_window").data('strip-url');

  var bounds = {
    ukraine: new google.maps.LatLngBounds(
        new google.maps.LatLng(44.3864630, 22.13715890), new google.maps.LatLng(52.379581, 40.22858090)
    ),
    usa: new google.maps.LatLngBounds(
        new google.maps.LatLng(36.66, -81.73), new google.maps.LatLng(45.02, -71.06)
    ),
    europe: new google.maps.LatLngBounds(
        new google.maps.LatLng(44.3864630, -2), new google.maps.LatLng(58, 40.22858090)
    ),
    north_america: new google.maps.LatLngBounds(
        new google.maps.LatLng(38, -98), new google.maps.LatLng(50.5, -71.06)
    ),
    world: new google.maps.LatLngBounds(
        new google.maps.LatLng(36.66, -98), new google.maps.LatLng(52.379581, 40.22858090)
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
        upper = $('#header').outerHeight(true)
            + ($('.map-panel').css("position") == 'static' ? $('.map-panel').outerHeight(true) : 0),
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

    $.ajax(photo_strip_url,
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

//  theMap.gmap3({
//    map: {},
//    panel: {
//      options: {
//        content: $(".map-panel").detach(),
//        top: true,
//        left: 150
//      }
//    }
//  });

  theMap.gmap3({
    panel: {
      options: {
        content: $(".gray-panel").detach(),
        top: true,
        left: 350
      }
    }
  });

  $.get('/map/media', function (rdata, textStatus, jqXHR) {
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
    window.history.replaceState('Object', 'Title', this.hash);
    return false;
  });

  //if (google.maps.version.substr(0, 4) == '3.17') {
  //  $(".mapContainer").append($("<div>", {class: 'error-overlay'}));
  //  $(".error-overlay").
  //      append($("<p>",
  //          {text: 'We are sorry, the map is not working properly now. We are working to fix this issue.'}));
  //  var textNode = document.createTextNode("Извините, карта временно не работает. Мы трудимся над решением этой проблемы.");
  //  $(".error-overlay p").append($("<br>")).append(textNode);
  //  $(".error-overlay").
  //      attr("style",
  //      "position: absolute; height: 100%; width: 100%; top: 0; left: 0; " +
  //      "background-color: grey; opacity: 0.8; ");
  //  $(".error-overlay p").attr("style",
  //      "text-align: center; position: relative; top: 36px; " +
  //      "color: black; font-size: 26px; font-weight: bold;");
  //}


});
