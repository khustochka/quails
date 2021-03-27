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
//= require suggest_over_combo

$(function () {

  var theMap = $('#googleMap'),
      observCollection;

  function adjustSizes() {
    var clientHeight = $(window).height(),
        clientWidth = $(window).width(),
        upper = $('#header').outerHeight(true) + $('form.search').outerHeight(),
        leftmost = $('.map-side-panel').outerWidth(true);
    $('.map-side-panel').height(clientHeight - upper - 2);
    $('div.mapContainer').height(clientHeight - upper).width(clientWidth - leftmost)
        .css('top', upper).css('left', leftmost);
    try {
      var gmap = theMap.gmap3("get");
      if (typeof (gmap) !== 'undefined' && gmap !== null) google.maps.event.trigger(gmap, 'resize');
    } catch (e) {
    }
  }

  function closeInfoWindows() {
    var infowindow = theMap.gmap3({get: {name: 'infowindow'}});
    if (infowindow) infowindow.close();
  }

  var spotsStore,
      defaultPublicity = true;

  function buildObservations(data) {

    observCollection = {};
    spotsStore = {};

    var hoverText, el;

    var marks = $(data).map(function () {
      el = $('li[data-obs-id=' + this.id + ']', 'ul.obs-list');
      el.toggleClass('is_mapped', el.data('obs-count') > 0);


      hoverText = $('div:first', el).text();

      observCollection[this.id] = el;

      return ($.map(this.spots, function (spot, i) {
        spotsStore[spot.id] = spot;
        return {
          lat: spot.lat,
          lng: spot.lng,
          tag: spot.observation_id,
          data: {id: spot.id},
          options: {title: hoverText}
        }
      }));
    });

    try {
      theMap.gmap3({clear: {name: ['marker', 'infowindow']}});
    } catch (e) {
    }

    if (data.length > 0) {

      if (marks.length > 0) {

        var markerOptions = jQuery.extend(true, {}, DEFAULT_MARKER_OPTIONS);
        markerOptions.values = marks;

        try {
          theMap.gmap3({
                marker: markerOptions
              },
              'autofit' // Zooms and moves to see all markers
          );
        } catch (e) {
        }
      } else {
        var loc_id = $('#q_locus_id').val();
        if (loc_id.length > 0) {
          $.get('/loci/' + loc_id + '.json', function (data) {
            var lat = data['lat'], lon = data['lon'];
            if (lat != null && lon != null) {
              try {
                theMap.gmap3("get").setCenter(new google.maps.LatLng(lat, lon));
                theMap.gmap3("get").setZoom(13);
              } catch (e) {
              }
            }

          });
        }
      }
    }
  }

  function destroy_link(spot_id) {
    return $("<a href='/spots/" + spot_id + "' " +
        "class='destroy' " +
        "data-confirm='Spot will be REMOVED!' " +
        "data-method='delete' " +
        "rel='nofollow' " +
        "data-remote='true'>Destroy</a>"
    )
  }

  adjustSizes();

  $(window).resize(adjustSizes);

  var searchForm = $('form.search');

  searchForm.on('ajax:beforeSend', function () {
    $('ul.obs-list').empty();
    //$('.observation_options').addClass('loading');
  });

  searchForm.on('ajax:success', function (e, data) {
    $('ul.obs-list').html(data.html);
    buildObservations(data.json);
  });

  searchForm.submit();

  // the Map

  var GRAY_ICON = "https://maps.google.com/mapfiles/marker_white.png",
      RED_ICON = "https://maps.google.com/mapfiles/marker.png";
  // TODO: add shadow?

  var DEFAULT_MARKER_OPTIONS = {
    options: {
      draggable: true,
      icon: GRAY_ICON
    },
    events: {
      click: function (marker, event, data) {
        var newForm = spotForm.clone(),
            wndContent,
            selectedObs = $('li.selected_obs'),
            spot_id = data.data.id,
            spotData = spotsStore[spot_id];

        theLastMarker = marker;

        closeInfoWindows();

        if (selectedObs.length == 0) {
          observCollection[spotData.observation_id].click();
          selectedObs = $('li.selected_obs');
        }

        if (selectedObs.data('obs-id') == spotData.observation_id) {
          $('#spot_id', newForm).val(spot_id);
          destroy_link(spot_id).appendTo($('.buttons', newForm));
        }

        $('#spot_exactness_' + spotData.exactness, newForm).attr('checked', true);
        $('#spot_memo', newForm).attr('value', spotData.memo);
        if (!spotData.public) $('#spot_public', newForm).attr('checked', null);
        else $('#spot_public', newForm).attr('checked', 'checked');

        $('#spot_lat', newForm).val(marker.position.lat());
        $('#spot_lng', newForm).val(marker.position.lng());
        $('#spot_zoom', newForm).val(spotData.zoom);
        $('#spot_observation_id', newForm).val(selectedObs.data('obs-id'));
        wndContent = newForm.html();

        theMap.gmap3({
          infowindow: {
            anchor: marker,
            options: {
              content: wndContent
            }
          }
        });
      },
      dragstart: function (marker, event, data) {
        closeInfoWindows();
        var selected = $('li.selected_obs'),
            spotData = spotsStore[data.data.id];
        if (selected.length == 0 || selected.data('obs-id') != spotData.observation_id) {
          observCollection[spotData.observation_id].click();
        }
      },
      dragend: function (marker, event, data) {
        var data_id = data.data.id,
            spotData = spotsStore[data_id];
        $.post(
            $('form', spotForm).attr('action'),
            {
              spot: {
                id: data_id,
                lat: marker.getPosition().lat(),
                lng: marker.getPosition().lng(),
                // Change zoom only if it was increased
                zoom: Math.max(spotData.zoom, marker.getMap().zoom)
              }
            }
        );
      }
    }
  };

  // Spot edit form

  var spotForm = $('.spot_form_container').detach();

  // Toggle selected observation

  $('.obs-list').on('click', 'li', function () {
    closeInfoWindows();

    var activeMarkers = theMap.gmap3({
      get: {
        name: 'marker',
        all: true,
        tag: $('.selected_obs').data('obs-id') || undefined
      }
    });

    $.each(activeMarkers, function (i, marker) {
      marker.setIcon(GRAY_ICON);
      marker.setZIndex($(marker).data['OrigZIndex']);
    });

    $('li.selected_obs').removeClass('selected_obs');
    $(this).addClass('selected_obs');

    activeMarkers = theMap.gmap3({
      get: {
        name: 'marker',
        all: true,
        tag: $(this).data('obs-id')
      }
    });

    $.each(activeMarkers, function (i, marker) {
      marker.setIcon(RED_ICON);
      $(marker).data['OrigZIndex'] = marker.getZIndex();
      marker.setZIndex(google.maps.Marker.MAX_ZINDEX);
    });
  });

  // Starting hardcore map stuff
  try {
    theMap.gmap3({
      panel: {
        options: {
          content: '<div class="map-panel">' +
              '<span class="pseudolink load_kml">Load KML</span> &nbsp; ' +
              '<span class="pseudolink clear_kml">clear KML</span>' +
              (typeof (card_kml) !== "undefined" && card_kml != "" ? ' &nbsp; <span class="pseudolink card_kml"><b>Card KML</b></span>' : "") +
              '</div>',
          top: true,
          left: 150
        }
      },
      map: {
        options: {
          draggableCursor: 'pointer',
          center: [48.2837, 31.62962],
          zoom: 6
        },
        events: {
          click: function (map, event) {
            var newForm = spotForm.clone(),
                wndContent,
                selectedObs = $('li.selected_obs');

            closeInfoWindows();

            if (selectedObs.length == 0) wndContent = "<p>No observation selected</p>";
            else {
              $('#spot_lat', newForm).val(event.latLng.lat());
              $('#spot_lng', newForm).val(event.latLng.lng());
              $('#spot_zoom', newForm).val(map.zoom);
              $('#spot_exactness_1', newForm).attr('checked', true); // Check the "exact" value
              $('#spot_observation_id', newForm).val(selectedObs.data('obs-id'));
              if (defaultPublicity) $('#spot_public', newForm).attr('checked', 'checked');
              else $('#spot_public', newForm).attr('checked', null);
              wndContent = newForm.html();
            }
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
  } catch (e) {
  }

  // Change default state of `public`
  $(document).on('change', '#spot_public', function () {
    defaultPublicity = $(this).is(':checked');
  });

  $(document).on('ajax:success', '#new_spot', function (e, data) {
    var infowindow = theMap.gmap3({get: {name: 'infowindow'}}),
        selectedObs = $('li.selected_obs'),
        markerOptions = jQuery.extend(true, {}, DEFAULT_MARKER_OPTIONS);
    // Add new marker only if spot_id was empty

    if ($('#spot_id', '#new_spot').val() == '') {
      markerOptions['data'] = {id: data.id};
      markerOptions['tag'] = selectedObs.data('obs-id');
      markerOptions.options.icon = RED_ICON;
      markerOptions.options.title = $('div:first', selectedObs).text();
      markerOptions.options.zIndex = google.maps.Marker.MAX_ZINDEX;
      markerOptions.latLng = [data.lat, data.lng];
      theMap.gmap3({
        marker: markerOptions
      });
    }

    selectedObs.addClass('is_mapped');
    selectedObs.data('obs-count', selectedObs.data('obs-count') + 1);

    // Store updated spot data
    spotsStore[data.id] = data;
    infowindow.close();
  });

  $(document).on('ajax:error', '#new_spot', function (e, data) {
    alert("Error submitting form");
  });

  // Destroy
  $(document).on('ajax:success', '#new_spot .destroy', function (e, data) {
    theLastMarker.setMap(null);
    closeInfoWindows();

    var selectedObs = $('li.selected_obs');

    selectedObs.data('obs-count', selectedObs.data('obs-count') - 1);

    selectedObs.toggleClass('is_mapped', selectedObs.data('obs-count') > 0);
    e.stopPropagation();
  });

  var kmls = [];

  function loadKML(kml_url) {
    if (kml_url)
      theMap.gmap3({
        kmllayer: {
          options: {
            url: kml_url,
            opts: {
              clickable: false
            }
          },
          callback: function (kml) {
            kmls.push(kml);
          }
        }
      });
  }

  // Load KML

  if (typeof (card_kml) !== "undefined" && card_kml != "") loadKML(card_kml);

  $(".load_kml").click(function () {
    var kml_url = prompt("Enter KML url:");
    loadKML(kml_url);
  });

  $(".card_kml").click(function () {
    loadKML(card_kml);
  });

  $(".clear_kml").click(function () {
    for (i in kmls) kmls[i].setMap(null);
    kmls = [];
  });


});
