Quails.features.videoResize =
  init: ->

    tag = document.createElement("script")
    tag.src = "https://www.youtube.com/iframe_api"
    firstScriptTag = document.getElementsByTagName("script")[0]
    firstScriptTag.parentNode.insertBefore tag, firstScriptTag

    # Had to embed plain JS to access global value onYouTubeIframeAPIReady
    `onYouTubeIframeAPIReady = this.apiReady`

    $.onStateChange = (event) ->
      if event.data == YT.PlayerState.UNSTARTED
        event.target.setSize 853, 480
      return

  apiReady: ->
    $('.video-container iframe').each ->
      new YT.Player(this, {
        events: {
          'onStateChange': $.onStateChange
        }
      })
