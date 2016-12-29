Quails.features.pjaxSpinner =
  init: ->
    $(".main").on "pjax:send", ->
      $("html").addClass("progress")

    $(".main").on "pjax:complete", ->
      $("html").removeClass("progress")

    $(".main").on "pjax:timeout", (event) ->

      # Prevent default timeout redirection behavior
      event.preventDefault()
      return

    return
