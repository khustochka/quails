Quails.features.showcase =
  init: ->
    @slughashes = $('[data-slughash]').map(->
      $(this).data('slughash')).get()

    @gallery = {}

    @collectImages()

    @createOverlays()

    @clickEvents()

    @processHash()

  Image: class
    constructor: (@slug) ->

    loadImage: ->
      url = $('[data-slughash=' + this.slug + '] a[data-rel=self]:first').prop('href')
      $.ajax(url, { data: {showcase: true}, success: @showImage})
      return false

    showImage: (data, status) ->
      $('.image_overlay .main_inside').html(data)
      return false

  collectImages: ->
    _self = @
    _prev = false
    $('[data-slugs]').each ->
      $.each $(this).data("slugs"), ->
        newImg = new _self.Image(this)
        _self.gallery[this] = newImg
        if (_prev)
          _prev.next = newImg
          newImg.prev = _prev
        _prev = newImg

  clickEvents: ->
    $('[data-slughash] a[data-rel=self]').click (e) =>
      location.hash = $(e.target).closest('[data-slughash]').data('slughash')
      @processHash()
      return false

    $(document).on 'click', '.close_button', =>
      @removeHash()
      @processHash()
      return false

  processHash: ->
    hash = location.hash[1..-1]
    if $.inArray(hash, @slughashes) > -1
      @loadPage(hash)
    else
      @closeOverlay()

  loadPage: (hash) ->
    @showOverlay()
    @gallery[hash].loadImage()

  createOverlays: ->
    $('body').append($("<div>", {class: 'full_overlay'}))
    $('body').append($("<div>", {class: 'image_overlay'}))
    $('.image_overlay').append($("<div>", {class: 'main_inside'}))
    $('.image_overlay').append($("<div>", {class: 'close_button', text: "[X]"}))
    $('.image_overlay').append($("<div>", {class: 'prev_button', text: "[<]"}))
    $('.image_overlay').append($("<div>", {class: 'next_button', text: "[>]"}))

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

  removeHash: ->
    scrollV = undefined
    scrollH = undefined
    loc = window.location
    if "pushState" of history
      history.pushState "", document.title, loc.pathname + loc.search
    else

      # Prevent scrolling by storing the page's current scroll offset
      scrollV = document.body.scrollTop
      scrollH = document.body.scrollLeft
      loc.hash = ""

      # Restore the scroll offset, should be flicker free
      document.body.scrollTop = scrollV
      document.body.scrollLeft = scrollH
    return
