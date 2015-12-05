Quails.features.justified =
  init: ->
    #    Quails.features.pjaxSpinner.define ->
    #      $("nav.pagination", this).append "<img src='/img/loading_small.gif'>"
    #      return

    @loadNewImages()

    $(document).on "pjax:complete", =>
      @loadNewImages()

    return

  loadNewImages: ->
    #$(".thumbnails img").attr("src", "")
    $('div.main').css("max-width", "100%")
    $.ajax
      url: "#{window.location.href}?justified=#{$(window).width() - 40}"
      dataType: "html"
      error: (jqXHR, textStatus, errorThrown) ->
        $('body').append "AJAX Error: #{textStatus}"
      success: (data, textStatus, jqXHR) ->
        $('div.thumbnails').replaceWith(data)
        $('div.thumbs_row').css("width", "100%")

