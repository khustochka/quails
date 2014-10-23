Quails.features.pjaxSpinner =
  init: ->
    return

  define: (spinnerFunction) ->
    $(".main").on "pjax:send", spinnerFunction

    # No need to hide spinner on pjax:complete - main content will be overwritten
    $(".main").on "pjax:timeout", (event) ->

      # Prevent default timeout redirection behavior
      event.preventDefault()
      return

    return
