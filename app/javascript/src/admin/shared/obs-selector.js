document.addEventListener("DOMContentLoaded", function () {
  const root = document.querySelector("[data-obs-selector]");
  if (!root) return;

  const currentObs = root.querySelector(".current-obs");
  const foundObs = root.querySelector(".found-obs");
  const selectedSection = root.querySelector(".selected-obs");
  const searchResults = root.querySelector(".search-results");
  const saveButton = document.getElementById("save_button");
  const originalObservations = currentObs.innerHTML;

  function refreshObservList() {
    if (currentObs.querySelectorAll("li").length === 0) {
      if (!selectedSection.querySelector("div.errors")) {
        const err = document.createElement("div");
        err.className = "errors";
        err.textContent = "None";
        selectedSection.appendChild(err);
      }
      if (saveButton) saveButton.disabled = true;
    } else {
      const err = selectedSection.querySelector("div.errors");
      if (err) err.remove();
      if (saveButton) saveButton.disabled = false;
    }
    updateFoundObsState();
  }

  function getSelectedCardId() {
    const first = currentObs.querySelector("li");
    if (!first) return null;
    return first.dataset.cardId;
  }

  function updateFoundObsState() {
    const selectedCardId = getSelectedCardId();
    foundObs.querySelectorAll("li").forEach(function (li) {
      if (selectedCardId !== null && li.dataset.cardId !== selectedCardId) {
        li.classList.add("incompatible");
        li.querySelector(".add").disabled = true;
      } else {
        li.classList.remove("incompatible");
        li.querySelector(".add").disabled = false;
      }
    });
  }

  function searchForObservations() {
    foundObs.innerHTML = "";
    searchResults.classList.add("loading");
    const inputs = root.querySelectorAll(".observation_search input[name], .observation_search select[name]");
    const params = new URLSearchParams();
    inputs.forEach(function (input) {
      if (input.name && input.value) params.append(input.name, input.value);
    });
    fetch("/observations/search?" + params.toString())
      .then(function (r) { return r.text(); })
      .then(function (html) {
        searchResults.classList.remove("loading");
        foundObs.innerHTML = html;
        // Remove items already selected
        const selectedIds = new Set();
        currentObs.querySelectorAll("input[name='obs[]']").forEach(function (input) {
          selectedIds.add(input.value);
        });
        foundObs.querySelectorAll("li").forEach(function (li) {
          const input = li.querySelector("input[name='obs[]']");
          if (input && selectedIds.has(input.value)) li.remove();
        });
        updateFoundObsState();
      });
  }

  // Click "+" to add observation from search results to selected
  foundObs.addEventListener("click", function (e) {
    const btn = e.target.closest(".add");
    if (!btn || btn.disabled) return;
    const li = btn.closest("li");
    currentObs.appendChild(li);
    refreshObservList();
  });

  // Click "×" to remove observation from selected
  currentObs.addEventListener("click", function (e) {
    const btn = e.target.closest(".remove");
    if (!btn) return;
    btn.closest("li").remove();
    refreshObservList();
  });

  const restoreLink = root.querySelector(".restore");
  if (restoreLink) {
    restoreLink.addEventListener("click", function () {
      currentObs.innerHTML = originalObservations;
      refreshObservList();
    });
  }

  root.querySelector(".obs_search_btn").addEventListener("click", searchForObservations);

  const form = root.closest("form.with_observations");
  if (form) {
    form.addEventListener("submit", function () {
      root.querySelectorAll(".observation_search input, .observation_search select, .observation_search button").forEach(function (el) {
        el.disabled = true;
      });
      foundObs.innerHTML = "";
    });
  }

  refreshObservList();
});
