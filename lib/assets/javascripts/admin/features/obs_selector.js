Quails.features.obsSelector = {
  init: function () {
    var current_obs, found_obs, originalObservations, refreshObservList, searchForObservations, getSelectedCardId, updateFoundObsState;

    current_obs = $(".current-obs");
    found_obs = $(".found-obs");
    originalObservations = current_obs.html();

    refreshObservList = function () {
      if ($("li", current_obs).length === 0) {
        $("<div>", {
          "class": "errors"
        }).text("None").appendTo(".selected-obs");
        $("#save_button").prop("disabled", true);
      } else {
        $(".selected-obs > div.errors").remove();
        $("#save_button").prop("disabled", false);
      }
      updateFoundObsState();
    };

    getSelectedCardId = function () {
      var first = $("li:first", current_obs);
      if (first.length === 0) return null;
      return first.data("card-id");
    };

    updateFoundObsState = function () {
      var selectedCardId = getSelectedCardId();
      $("li", found_obs).each(function () {
        var $li = $(this);
        if (selectedCardId !== null && $li.data("card-id") !== selectedCardId) {
          $li.addClass("incompatible");
          $li.find(".add").prop("disabled", true);
        } else {
          $li.removeClass("incompatible");
          $li.find(".add").prop("disabled", false);
        }
      });
    };

    searchForObservations = function () {
      var data;
      found_obs.empty();
      $(".search-results").addClass("loading");
      data = $.param($(".observation_search :input[name]"));
      found_obs.load("/observations/search", data, function () {
        $(".search-results").removeClass("loading");
        // Remove items already selected
        $("li", current_obs).each(function () {
          var id = $(this).find("input[name='obs[]']").val();
          $("li", found_obs).each(function () {
            if ($(this).find("input[name='obs[]']").val() === id) {
              $(this).remove();
            }
          });
        });
        updateFoundObsState();
      });
    };

    // Click "+" to add observation from search results to selected
    found_obs.on("click", ".add", function () {
      var $btn = $(this);
      if ($btn.prop("disabled")) return;
      var $li = $btn.closest("li");
      $li.appendTo(current_obs);
      refreshObservList();
    });

    // Click "×" to remove observation from selected
    current_obs.on("click", ".remove", function () {
      $(this).closest("li").remove();
      refreshObservList();
    });

    $(".restore").on("click", function () {
      current_obs.html(originalObservations);
      refreshObservList();
    });

    $(".obs_search_btn").click(searchForObservations);

    $("form.with_observations").submit(function () {
      $("input, select, button", ".observation_search").prop("disabled", true);
      found_obs.empty();
    });

    refreshObservList();
  }
};
