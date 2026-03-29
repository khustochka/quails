function initInstantSearch(container) {
  const dataUrl = container.dataset.instantSearchUrl;
  const resultSelector = container.dataset.resultContainer;
  const resultContainer = (resultSelector && document.querySelector(resultSelector)) ||
                          container.querySelector("[data-instant-search-results]") ||
                          container.nextElementSibling;
  let requestTimeout = null;

  container.addEventListener("input", (e) => {
    if (!e.target.matches("[data-instant-search-input]")) return;
    const value = e.target.value;
    if (requestTimeout) clearTimeout(requestTimeout);
    requestTimeout = setTimeout(() => {
      fetch(`${dataUrl}?term=${encodeURIComponent(value)}&instant_search=1`)
        .then(r => r.text())
        .then(html => { resultContainer.innerHTML = html; });
    }, 500);
  });
}

document.addEventListener("DOMContentLoaded", () => {
  document.querySelectorAll("[data-instant-search]").forEach(initInstantSearch);
});
