import consumer from "../../channels/consumer"
import { selectCombobox } from "../utils/select-combobox"

// Requests Birdnik preloads and imports, and shows their results as Birdnik pushes them.
// Preload pushes arriving while no preload is awaited do not replace the list, to keep unsaved locus selections.
// Responses without a JSON message (e.g. a proxy challenge page) and a lost cable connection are reported,
// since either way the results would never show up.
document.addEventListener("DOMContentLoaded", function () {
  const container = document.querySelector("[data-external-checklists]");
  if (!container) return;

  const preloadForm = document.querySelector("[data-external-checklists-preload]");
  const status = document.querySelector("[data-external-checklists-status]");
  const disconnectedMessage = "Live updates are disconnected. Reload the page to see preload and import results.";
  let awaitingPreload = false;
  let cableConnected = false;

  function showStatus(text, { busy = false } = {}) {
    status.textContent = text;
    if (busy) {
      const spinner = document.createElement("span");
      spinner.className = "fas fa-spinner fa-spin checklists-status-spinner";
      spinner.setAttribute("aria-hidden", "true");
      status.prepend(spinner);
    }
  }

  function responseMessage(e) {
    const message = e.detail[0]?.message;
    return typeof message === "string" ? message : null;
  }

  function enhanceLocusSelects() {
    container.querySelectorAll("select.locus_select").forEach(sel => selectCombobox(sel));
  }

  function replaceList(html) {
    container.innerHTML = html;
    enhanceLocusSelects();
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

  enhanceLocusSelects();

  consumer.subscriptions.create({ channel: "ExternalChecklistsChannel" }, {
    connected() {
      cableConnected = true;
    },

    disconnected() {
      cableConnected = false;
      showStatus(disconnectedMessage);
    },

    rejected() {
      cableConnected = false;
      showStatus(disconnectedMessage);
    },

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
    showStatus("Waiting for Birdnik to preload the checklists…", { busy: true });
  });

  preloadForm.addEventListener("ajax:success", function (e) {
    if (!responseMessage(e)) {
      awaitingPreload = false;
      showStatus("Unexpected response to the preload request. Reload the page and try again.");
    } else if (!cableConnected) {
      showStatus("Preload requested, but live updates are not connected. Reload the page in a minute to see the results.");
    }
  });

  preloadForm.addEventListener("ajax:error", function (e) {
    awaitingPreload = false;
    showStatus(responseMessage(e) || "Preload request failed.");
  });

  // The import form is re-rendered with the list, so its events are handled on the container.
  container.addEventListener("ajax:success", function (e) {
    if (!e.target.matches("[data-external-checklists-import]")) return;

    showStatus(responseMessage(e) || "Unexpected response to the import request. Reload the page and try again.");
  });

  container.addEventListener("ajax:error", function (e) {
    if (e.target.matches("[data-external-checklists-import]")) showStatus(responseMessage(e) || "Import request failed.");
  });
});
