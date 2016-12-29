Quails.features.pjaxPagination =
  init: ->
    $(".main").pjax "nav.pagination a"
    Quails.features.pjaxSpinner.init()
    return
