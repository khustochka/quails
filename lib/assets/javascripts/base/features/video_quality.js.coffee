Quails.features.videoQuality =
  init: ->

    tag = document.createElement("script")
    tag.src = "https://www.youtube.com/iframe_api"
    firstScriptTag = document.getElementsByTagName("script")[0]
    firstScriptTag.parentNode.insertBefore tag, firstScriptTag

    # Had to embed plain JS to access global value onYouTubeIframeAPIReady
    `onYouTubeIframeAPIReady = this.apiReady`

    $.onPlayerReady = (event) ->
      event.target.setPlaybackQuality "hd720"
      return

    $.onStateChange = (event) ->
      if event.data == YT.PlayerState.UNSTARTED
        event.target.setSize 853, 480
      return

  apiReady: ->
    $('.video-container iframe').each ->
      new YT.Player(this, {
        events: {
          'onReady': $.onPlayerReady,
          'onStateChange': $.onStateChange
        }
      })
