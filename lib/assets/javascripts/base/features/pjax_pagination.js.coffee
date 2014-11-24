Quails.features.pjaxPagination =
  init: ->
    $(".main").pjax "nav.pagination a"
    Quails.features.pjaxSpinner.define ->
      $("nav.pagination", this).append "<img src='/img/loading_small.gif'>"
      return

    return
