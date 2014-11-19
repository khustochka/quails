Quails.features.showcase =
  init: ->
    @slughashes = $('[data-slughash]').map(->
      $(this).data('slughash')).get()

    @createOverlays()

    @clickEvents()

    @processHash()

  clickEvents: ->
    $('[data-slughash] a[data-rel=self]').click (e) =>
      location.hash = $(e.target).closest('[data-slughash]').data('slughash')
      @processHash()
      return false

  processHash: ->
    hash = location.hash[1..-1]
    if hash == ""
      @closeOverlay
    else
      if $.inArray(hash, @slughashes) > -1
        @loadPage(hash)

  loadPage: (hash) ->
    @showOverlay()
    url = $('[data-slughash=' + hash + '] a[data-rel=self]:first').prop('href')
    $.ajax(url, { data: {showcase: true}, success: @showFullscreen})

  showFullscreen: (data, status) ->
    $('.image_overlay .main_inside').html(data)

  createOverlays: ->
    $('body').append($("<div>", {class: 'full_overlay'}))
    $('body').append($("<div>", {class: 'image_overlay'}))
    $('.image_overlay').append($("<div>", {class: 'main_inside'}))

  showOverlay: ->
    $('.full_overlay').show()
    $('.image_overlay').show()
        .position({my: 'top', at: 'top+20', of: window})
    $('.main_inside').css('height', window.innerHeight - 60 + "px")
    # Disable body scroll
    $("body").css({'overflow':'hidden'});

  closeOverlay: ->
    $('.full_overlay').hide()
    $('.image_overlay').hide()
    $('.image_overlay .main_inside').html("")
    $("body").css({'overflow':'auto'});

