Quails.features.videoQuality =
  init: ->

    tag = document.createElement("script")
    tag.src = "https://www.youtube.com/iframe_api"
    firstScriptTag = document.getElementsByTagName("script")[0]
    firstScriptTag.parentNode.insertBefore tag, firstScriptTag

    # Had to embed plain JS to access global value onYouTubeIframeAPIReady
    `onYouTubeIframeAPIReady = function () {
      $('.video-container iframe').each(
        function () {
          new YT.Player(this, {
            events: {
              'onReady': $.onPlayerReady
            }
          });
      });
    };`

    $.onPlayerReady = (event) ->
      event.target.setPlaybackQuality "hd720"
      return
