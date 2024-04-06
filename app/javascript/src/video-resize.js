class VideoResize {
  constructor(sizeX, sizeY) {
    this.selector = '.video-container[data-resizable] iframe'
    this.enable = document.querySelectorAll(this.selector).length > 0
    this.sizeX = sizeX
    this.sizeY = sizeY
  }

  init() {
    if (this.enable) {
      this.createScriptTag();
      window.onYouTubeIframeAPIReady = this.apiReady(this.selector, this.onStateChangeCallback());
    }
  }

  createScriptTag() {
    let tag = document.createElement("script");
    tag.src = "https://www.youtube.com/iframe_api";
    let firstScriptTag = document.getElementsByTagName("script")[0];
    firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);
  }

  onStateChangeCallback() {
    const self = this
    return function(event) {
      if (event.data === YT.PlayerState.UNSTARTED) {
        event.target.setSize(self.sizeX, self.sizeY);
      }
    }
  }

  apiReady(selector, callback) {
    return function () {
      document.querySelectorAll(selector).forEach(function (vid) {
        new YT.Player(vid, {
          events: {
            'onStateChange': callback
          }
        });
      });
    }
  }
}

export default {
  init: (sizeX, sizeY) => {
    document.addEventListener('DOMContentLoaded', () => {
      const videoResize = new VideoResize(sizeX, sizeY);
      videoResize.init()
    });
  }
}
