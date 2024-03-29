//= require map_init

$(function () {

  var theMap = $('#googleMap'),
      activeMarkers,
      marker_options,
      firstObserv = $('.obs-list li input').val();

  var mapContainer = $(".mapContainer"),
      patchUrl = mapContainer.data("patch-url"),
      mediaType = mapContainer.data("media-type"),
      maxZoom = mapContainer.data("max-zoom"),
      selectedSpot = mapContainer.data("selected-spot"),
      locusCoords = mapContainer.data("locus-coords"),
      locusLatLng;

  if (locusCoords["lat"] && locusCoords["lon"] && typeof google === 'object') {
    locusLatLng = new google.maps.LatLng(locusCoords["lat"], locusCoords["lon"])
  } else
    locusLatLng = null;

  var marksData = mapContainer.data("marks"),
    marks = $.map(marksData, function (el) {
      el.tag = el.id;
      el.data = {id: el.id};
      return el;
    });

  function closeInfoWindows() {
    var infowindow = theMap.gmap3({get: {name: 'infowindow'}});
    if (infowindow) infowindow.close();
  }

  function adjustSizes() {
    var clientHeight = $(window).height(),
        clientWidth = $(window).width(),
        upper = $('#header').outerHeight(true),
        leftmost = $('.map-side-panel').outerWidth(true);
    $('.map-side-panel').height(clientHeight - upper - 2);
    $('div.mapContainer').height(clientHeight - upper).width(clientWidth - leftmost)
        .css('top', upper).css('left', leftmost);
  }

  var GRAY_ICON = "https://maps.google.com/mapfiles/marker_white.png",
      RED_ICON = "https://maps.google.com/mapfiles/marker.png";

  function bindImageToMarker(marker, data) {
    var payload = {};
    payload[mediaType] = {'spot_id': data.id};

    $.post(patchUrl, payload, function (data2) {

      var activeMarker = theMap.gmap3({
        get: {
          name: 'marker',
          first: true,
          tag: selectedSpot
        }
      });

      activeMarker.setIcon(GRAY_ICON);
      activeMarker.setZIndex($(marker).data['OrigZIndex']);

      selectedSpot = data.id;

      marker.setIcon(RED_ICON);
      $(marker).data['OrigZIndex'] = marker.getZIndex();
      marker.setZIndex(google.maps.Marker.MAX_ZINDEX);
    });
  }

  var DEFAULT_MARKER_OPTIONS = {
    options: {
      draggable: false,
      icon: GRAY_ICON
    },
    events: {
      click: function (marker, event, data) {
        closeInfoWindows();
        bindImageToMarker(marker, data.data);
      }
    }
  };

  // Spot edit form

  var spotForm = $('.spot_form_container').detach();

  // The Map

  adjustSizes();

  $(window).resize(adjustSizes);

  if (window.mapEnabled && typeof google === "object") {

    theMap.gmap3({
      map: {
        options: {
          draggableCursor: 'pointer'
        },
        events: {
          click: function (map, event) {
            var newForm = spotForm.clone(),
                wndContent;

            closeInfoWindows();
            $('#spot_lat', newForm).val(event.latLng.lat());
            $('#spot_lng', newForm).val(event.latLng.lng());
            $('#spot_zoom', newForm).val(map.zoom);
            $('#spot_exactness_1', newForm).attr('checked', true); // Check the "exact" value
            // TODO: create spots for all image's observations
            $('#spot_observation_id', newForm).val(firstObserv);
            wndContent = newForm.html();

            theMap.gmap3({
              infowindow: {
                latLng: event.latLng,
                options: {
                  content: wndContent
                }
              }
            });
          }
        }
      }
    });

  }

  $(document).on('ajax:success', '#new_spot', function (e, data) {
    var infowindow = theMap.gmap3({get: {name: 'infowindow'}}),

        markerOptions = jQuery.extend(true, {}, DEFAULT_MARKER_OPTIONS);

    markerOptions['data'] = {id: data.id};
    markerOptions['tag'] = data.id;
    markerOptions.latLng = [data.lat, data.lng];
    theMap.gmap3({
      marker: markerOptions
    });

    infowindow.close();

    // Simulate click

    var addedMarker = theMap.gmap3({
      get: {
        name: 'marker',
        first: true,
        tag: data.id
      }
    });

    bindImageToMarker(addedMarker, {id: data.id});
  });

  $(document).on('ajax:error', '#new_spot', function (e, data) {
    alert("Error submitting form");
  });

  marker_options = $.extend(true, {}, DEFAULT_MARKER_OPTIONS);
  marker_options.values = marks;


  if (window.mapEnabled && typeof google === "object") {
    if (marks.length > 0) {
      theMap.gmap3(
          {marker: marker_options},
          {autofit: {"maxZoom": maxZoom}} // Zooms and moves to see all markers
      )
    }
    else if (typeof(locusLatLng) !== 'undefined' && locusLatLng) {
      theMap.gmap3("get").setCenter(locusLatLng);
      theMap.gmap3("get").setZoom(13);
    }
  }

  if (selectedSpot && typeof google === "object") {

    activeMarkers = theMap.gmap3({
      get: {
        name: 'marker',
        all: true,
        tag: selectedSpot
      }
    });

    $.each(activeMarkers, function (i, marker) {
      marker.setIcon(RED_ICON);
      $(marker).data['OrigZIndex'] = marker.getZIndex();
      marker.setZIndex(google.maps.Marker.MAX_ZINDEX);
    });
  }

});
