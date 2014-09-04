#= require jquery-ui.addon
#= require suggest_over_combo

Quails.features.observDragger =
  init: ->

    refreshObservList = ->
      if $("li", current_obs).length is 0
        $("<div>",
          class: "errors"
        ).text("None").appendTo ".observation_list"
        $(".buttons input:submit").prop "disabled", true
      else
        $(".observation_list > div").remove()
        $(".buttons input:submit").prop "disabled", false
      return
    searchForObservations = ->
      found_obs.empty()
      $(".observation_options").addClass "loading"
      data = $.param($(".observation_search :input[name]"))
      found_obs.load "/observations/search", data, (data) ->
        $(".observation_options").removeClass "loading"
        $("li", found_obs).draggable revert: "invalid"
        return

      return
    insertNewObservation = (newObs) ->

      #newObs.draggable("destroy");
      newObs.removeAttr("style").appendTo current_obs
      refreshObservList()
      return
    current_obs = $(".current-obs")
    found_obs = $(".found-obs")
    originalObservations = current_obs.html()
    current_obs.on "click", ".remove", ->
      $(this).closest("li").remove()
      refreshObservList()
      return

    $(".restore").on "click", ->
      current_obs.html originalObservations
      refreshObservList()
      return


    # Search button click
    $(".obs_search_btn").click searchForObservations
    $(".observation_list").droppable
      accept: ".found-obs li"
      drop: (event, ui) ->
        first = $("li:first", current_obs)
        fdata = $("div:eq(1)", first).text().split(", ", 2).join()
        newObs = ui.draggable
        newdata = newObs.find("div:eq(1)").text().split(", ", 2).join()
        if first.length is 0 or newdata is fdata
          insertNewObservation newObs
        else
          $("<div class=\"confirm\" title=\"Overwrite observations?\">").append($("<p>").text("You are trying to add an observation with different date/locus from " + "existing. Do you want to remove old observations and add a new one?")).dialog
            modal: true
            closeOnEscape: false
            open: (event, ui) ->
              $(".ui-dialog-titlebar-close", ui.dialog).hide()
              return

            buttons:
              Overwrite: ->
                $(this).dialog "close"
                current_obs.empty()
                insertNewObservation newObs
                return

              Cancel: ->
                $(this).dialog "close"
                originalDrag = ui.helper.data("ui-draggable")

                # Revert mechanism taken from JQuery UI source
                newObs.animate originalDrag.originalPosition, parseInt(originalDrag.options.revertDuration, 10)
                return

        return

    $("form.with_observations").submit ->
      $(".observation_search").empty()
      found_obs.empty()
      return


    # Init
    refreshObservList()
    return
