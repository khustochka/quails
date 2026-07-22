// Recovers images rendered with a direct storage URL (QUAILS_DIRECT_VARIANT_URLS)
// whose file has disappeared (e.g. variant regenerated under a new digest):
// swaps the src to the redirect route kept in data-fallback-src, which
// regenerates the variant if needed.

import Honeybadger from "@honeybadger-io/js";

function applyFallback(img) {
  const fallback = img.dataset.fallbackSrc;
  if (!fallback) return;
  delete img.dataset.fallbackSrc;
  // console.warn(`Direct image URL failed to load, swapping to the redirect route: ${img.currentSrc || img.src}`);
  // Honeybadger.notify("Direct image URL failed to load, swapped to the redirect route", {
  //   name: "ImageFallback",
  //   context: { src: img.currentSrc || img.src, fallback: fallback, page: window.location.href },
  // });
  img.src = fallback;
}

// error events do not bubble, but they do propagate in the capture phase
document.addEventListener(
  "error",
  (e) => {
    if (e.target instanceof HTMLImageElement) applyFallback(e.target);
  },
  true
);

// Sweep up images that failed before the listener was attached. Runs on load,
// not DOMContentLoaded: img.complete is also true for an image whose fetch has
// not started yet, which at DOMContentLoaded is every image below the fold.
window.addEventListener("load", () => {
  document.querySelectorAll("img[data-fallback-src]").forEach((img) => {
    if (img.complete && img.naturalWidth === 0) applyFallback(img);
  });
});
