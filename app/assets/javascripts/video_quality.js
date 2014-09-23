var tag = document.createElement('script');

tag.src = "https://www.youtube.com/iframe_api";
var firstScriptTag = document.getElementsByTagName('script')[0];
firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);

function onYouTubeIframeAPIReady() {
  $('.video-container iframe').each(
      function () {
        new YT.Player(this, {
          events: {
            'onReady': onPlayerReady
          }
        });
      });
}

function onPlayerReady(event) {
  event.target.setPlaybackQuality("hd720");
}
