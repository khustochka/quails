function initVideoResize(sizeX, sizeY) {
  document.addEventListener("DOMContentLoaded", () => {
    const selector = ".video-container[data-resizable] iframe";
    const iframes = document.querySelectorAll(selector);
    if (iframes.length === 0) return;

    const tag = document.createElement("script");
    tag.src = "https://www.youtube.com/iframe_api";
    document.head.appendChild(tag);

    window.onYouTubeIframeAPIReady = () => {
      iframes.forEach(vid => {
        new YT.Player(vid, {
          events: {
            onStateChange(event) {
              if (event.data === YT.PlayerState.UNSTARTED) {
                event.target.setSize(sizeX, sizeY);
              }
            }
          }
        });
      });
    };
  });
}

export default { init: initVideoResize };
