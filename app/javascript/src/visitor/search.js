import Autocomplete from '../utils/autocomplete';

function escapeRegex(str) {
  return str.replace(/[-[\]{}()*+?.,\\^$|#\s]/g, "\\$&");
}

function highlight(text, termRegex) {
  return text.replace(termRegex, "<em>$1</em>");
}

function initSearch(root) {
  const input = root.querySelector("#cse-query-box");
  if (!input) return;

  const form = input.closest("form");
  const searchUrl = root.dataset.searchUrl;
  const fallbackText = root.dataset.fallbackText;

  let termRegex = /(?!)/; // never matches by default

  new Autocomplete(input, {
    minLength: 0,
    dropdownClass: "ac-search-dropdown",

    source(term) {
      termRegex = new RegExp("(?!<^| |-)(" + escapeRegex(term) + ")", "i");
      const url = searchUrl + (searchUrl.includes("?") ? "&" : "?") + "term=" + encodeURIComponent(term);
      return fetch(url, { headers: { Accept: "application/json" } }).then(r => r.json());
    },

    renderItem(li, item) {
      const a = document.createElement("a");
      const b = document.createElement("b");
      b.innerHTML = highlight(item.name, termRegex);
      const i = document.createElement("i");
      i.className = "sci_name";
      i.innerHTML = highlight(item.label, termRegex);
      a.append(b, "\n", i);
      li.appendChild(a);
    },

    renderFallback(li) {
      const a = document.createElement("a");
      a.className = "fallback_link";
      a.textContent = fallbackText;
      li.appendChild(a);
    },

    onSelect(item) {
      window.location.href = item.url;
    },

    onFallback() {
      form.submit();
    }
  });
}

document.addEventListener("DOMContentLoaded", function () {
  // app layout: data attrs on #cse-wrapper
  const wrapper = document.getElementById("cse-wrapper");
  if (wrapper) initSearch(wrapper);

  // app2 layout: data attrs on .search-section
  const section = document.querySelector(".search-section[data-search-url]");
  if (section) initSearch(section);
});
