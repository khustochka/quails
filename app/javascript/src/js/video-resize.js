class VideoResize {
  constructor() {
    this.selector = '.video-container[data-resizable] iframe'
    this.enable = document.querySelectorAll(this.selector).length > 0;
  }

  init() {
    if (this.enable) {
      this.createScriptTag();
      window.onYouTubeIframeAPIReady = this.apiReady(this.selector, this.onStateChange);
    }
  }

  createScriptTag() {
    let tag = document.createElement("script");
    tag.src = "https://www.youtube.com/iframe_api";
    let firstScriptTag = document.getElementsByTagName("script")[0];
    firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);
  }

  onStateChange(event) {
    if (event.data === YT.PlayerState.UNSTARTED) {
      event.target.setSize(853, 480);
    }
  };

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
  init: () => {
    document.addEventListener('DOMContentLoaded', () => {
      const videoResize = new VideoResize();
      videoResize.init()
    });
  }
}
