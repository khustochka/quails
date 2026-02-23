//= require jquery-ui.addon

Quails.features.observDragger = {
  init: function () {
    var current_obs, found_obs, insertNewObservation, originalObservations, refreshObservList, searchForObservations;
    refreshObservList = function () {
      if ($("li", current_obs).length === 0) {
        $("<div>", {
          "class": "errors"
        }).text("None").appendTo(".observation_list");
        $(".buttons input:submit").prop("disabled", true);
      } else {
        $(".observation_list > div").remove();
        $(".buttons input:submit").prop("disabled", false);
      }
    };
    searchForObservations = function () {
      var data;
      found_obs.empty();
      $(".observation_options").addClass("loading");
      data = $.param($(".observation_search :input[name]"));
      found_obs.load("/observations/search", data, function (data) {
        $(".observation_options").removeClass("loading");
        $("li", found_obs).draggable({
          revert: "invalid"
        });
      });
    };
    insertNewObservation = function (newObs) {
      newObs.removeAttr("style").appendTo(current_obs);
      refreshObservList();
    };
    current_obs = $(".current-obs");
    found_obs = $(".found-obs");
    originalObservations = current_obs.html();
    current_obs.on("click", ".remove", function () {
      $(this).closest("li").remove();
      refreshObservList();
    });
    $(".restore").on("click", function () {
      current_obs.html(originalObservations);
      refreshObservList();
    });
    $(".obs_search_btn").click(searchForObservations);
    $(".observation_list").droppable({
      accept: ".found-obs li",
      drop: function (event, ui) {
        var fdata, first, newObs, newdata;
        first = $("li:first", current_obs);
        fdata = $("div:eq(1)", first).text().split(", ", 2).join();
        newObs = ui.draggable;
        newdata = newObs.find("div:eq(1)").text().split(", ", 2).join();
        if (first.length === 0 || newdata === fdata) {
          insertNewObservation(newObs);
        } else {
          $("<div class=\"confirm\" title=\"Overwrite observations?\">").append($("<p>").text("You are trying to add an observation with different date/locus from " + "existing. Do you want to remove old observations and add a new one?")).dialog({
            modal: true,
            closeOnEscape: false,
            open: function (event, ui) {
              $(".ui-dialog-titlebar-close", ui.dialog).hide();
            },
            buttons: {
              Overwrite: function () {
                $(this).dialog("close");
                current_obs.empty();
                insertNewObservation(newObs);
              },
              Cancel: function () {
                var originalDrag;
                $(this).dialog("close");
                originalDrag = ui.helper.data("ui-draggable");
                newObs.animate(originalDrag.originalPosition, parseInt(originalDrag.options.revertDuration, 10));
              }
            }
          });
        }
      }
    });
    $("form.with_observations").submit(function () {
      $("input, select, button", ".observation_search").prop('disabled', true);
      found_obs.empty();
    });
    refreshObservList();
  }
};

