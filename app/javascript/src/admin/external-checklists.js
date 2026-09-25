import consumer from "../../channels/consumer"
import { selectCombobox } from "../utils/select-combobox"

// Requests Birdnik preloads and imports, and shows their results as Birdnik pushes them.
// Preload pushes arriving while no preload is awaited do not replace the list, to keep unsaved locus selections.
document.addEventListener("DOMContentLoaded", function () {
  const container = document.querySelector("[data-external-checklists]");
  if (!container) return;

  const preloadForm = document.querySelector("[data-external-checklists-preload]");
  const status = document.querySelector("[data-external-checklists-status]");
  let awaitingPreload = false;

  function showStatus(text) {
    status.textContent = text;
  }

  function replaceList(html) {
    container.innerHTML = html;
    container.querySelectorAll("select.locus_select").forEach(sel => selectCombobox(sel));
    const paramName = document.querySelector("meta[name=csrf-param]")?.content;
    const tokenInput = paramName && container.querySelector(`input[name="${paramName}"]`);
    if (tokenInput) tokenInput.value = document.querySelector("meta[name=csrf-token]").content;
  }

  function updateRow({ id, status_html, card_url }) {
    const row = container.querySelector(`[data-external-checklist-id="${id}"]`);
    if (!row) return;

    row.querySelector("[data-external-checklist-status]").innerHTML = status_html;

    if (card_url) {
      const link = document.createElement("a");
      link.href = card_url;
      link.textContent = "Card";
      row.querySelector("[data-external-checklist-locus]").replaceChildren(link);
    }
  }

  consumer.subscriptions.create({ channel: "ExternalChecklistsChannel" }, {
    received(data) {
      if (data.checklist) {
        updateRow(data.checklist);
      } else if (data.error) {
        if (awaitingPreload) showStatus(`Preload failed: ${data.error}`);
        awaitingPreload = false;
      } else if (awaitingPreload) {
        replaceList(data.html);
        showStatus(`Preload finished: ${data.upserted} new or updated checklists.`);
        awaitingPreload = false;
      } else {
        showStatus("New checklists arrived. Reload the page to see them.");
      }
    }
  });

  // Set on send, not on success: Birdnik may push before the request's response arrives.
  preloadForm.addEventListener("ajax:send", function () {
    awaitingPreload = true;
    showStatus("Waiting for Birdnik to preload the checklists…");
  });

  preloadForm.addEventListener("ajax:error", function (e) {
    awaitingPreload = false;
    showStatus(e.detail[0]?.message || "Preload request failed.");
  });

  // The import form is re-rendered with the list, so its events are handled on the container.
  container.addEventListener("ajax:success", function (e) {
    if (e.target.matches("[data-external-checklists-import]")) showStatus(e.detail[0].message);
  });

  container.addEventListener("ajax:error", function (e) {
    if (e.target.matches("[data-external-checklists-import]")) showStatus(e.detail[0]?.message || "Import request failed.");
  });
});
