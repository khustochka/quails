Quails.features.justified =
  init: ->
    #    Quails.features.pjaxSpinner.define ->
    #      $("nav.pagination", this).append "<img src='/img/loading_small.gif'>"
    #      return

    @loadNewImages()

    $(document).on "pjax:complete", =>
      @loadNewImages()

    $(window).on "resize", =>
      if @width != $(window).width()
        clearTimeout $.data(this, 'resizeTimer')
        $.data this, 'resizeTimer', setTimeout((=>
          @loadNewImages()
          return
        ), 1000)

    return

  loadNewImages: ->
    @refreshWidth()
    #$(".thumbnails img").attr("src", "")
    $('div.main').css("max-width", "100%")
    $.ajax
      url: "#{window.location.href}?justified=#{@width - 40}"
      dataType: "html"
      error: (jqXHR, textStatus, errorThrown) ->
        $('body').append "AJAX Error: #{textStatus}"
      success: (data, textStatus, jqXHR) ->
        $('div.thumbnails').replaceWith(data)
        $('div.thumbs_row').css("width", "100%")

  refreshWidth: ->
    @width = $(window).width()
