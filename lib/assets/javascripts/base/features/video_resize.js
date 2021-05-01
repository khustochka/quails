Quails.features.videoResize = {
  init: function () {
    var firstScriptTag, tag;
    tag = document.createElement("script");
    tag.src = "https://www.youtube.com/iframe_api";
    firstScriptTag = document.getElementsByTagName("script")[0];
    firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);
    onYouTubeIframeAPIReady = this.apiReady;
    return $.onStateChange = function (event) {
      if (event.data === YT.PlayerState.UNSTARTED) {
        event.target.setSize(853, 480);
      }
    };
  },
  apiReady: function () {
    return $('.video-container iframe').each(function () {
      return new YT.Player(this, {
        events: {
          'onStateChange': $.onStateChange
        }
      });
    });
  }
};
