document.addEventListener("DOMContentLoaded", () => {
  const grid = document.querySelector(".video-grid");
  const overlay = document.querySelector("[data-video-overlay]");
  if (!grid || !overlay) return;

  const backdrop = overlay.querySelector(".video-overlay-backdrop");
  const closeBtn = overlay.querySelector(".video-overlay-close");
  let activeContent = null;

  function show(videoId) {
    const content = document.getElementById("overlay-" + videoId);
    if (!content) return;

    const playerArea = content.querySelector(".video-overlay-player");
    const url = playerArea.dataset.videoUrl;
    const title = playerArea.dataset.videoTitle;
    playerArea.innerHTML =
      "<iframe title=\"" + title + "\"" +
      " src=\"" + url + "\" frameborder=\"0\" allowfullscreen></iframe>";

    content.classList.add("active");
    overlay.classList.add("active");
    document.body.style.overflow = "hidden";
    activeContent = content;
  }

  function dismiss() {
    if (!activeContent) return;
    const playerArea = activeContent.querySelector(".video-overlay-player");
    playerArea.innerHTML = "";
    activeContent.classList.remove("active");
    activeContent = null;
    overlay.classList.remove("active");
    document.body.style.overflow = "";
  }

  function open(videoId) {
    show(videoId);
    history.pushState(null, "", "#" + videoId);
  }

  function close() {
    if (!activeContent) return;
    dismiss();
    history.back();
  }

  grid.addEventListener("click", (e) => {
    const item = e.target.closest("[data-video-id]");
    if (!item) return;
    e.preventDefault();
    open(item.dataset.videoId);
  });

  backdrop.addEventListener("click", close);
  closeBtn.addEventListener("click", close);

  document.addEventListener("keydown", (e) => {
    if (e.key === "Escape" && overlay.classList.contains("active")) {
      close();
    }
  });

  window.addEventListener("popstate", () => {
    dismiss();
    if (location.hash.length > 1) {
      show(location.hash.slice(1));
    }
  });

  // Open video from hash on page load
  if (location.hash.length > 1) {
    show(location.hash.slice(1));
  }
});
