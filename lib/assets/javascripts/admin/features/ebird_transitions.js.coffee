Quails.features.ebirdTransitions =
  init: ->
    $(document).on "ajax:beforeSend", ".ebird-trans", ->
      $(this).closest(".status-line").append "<img src='/img/loading_small.gif'>"
      return

    $(document).on "ajax:success", ".ebird-trans", (e, data) ->
      row = $(this).closest(".status-line")
      $(row).html data.status_line
      return
