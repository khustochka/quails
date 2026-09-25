import consumer from "../../channels/consumer"
import { selectCombobox } from "../utils/select-combobox"

// Requests a Birdnik preload and replaces the checklist list when Birdnik pushes the result.
// Pushes arriving while no preload is awaited do not replace the list, to keep unsaved locus selections.
document.addEventListener("DOMContentLoaded", function () {
  const container = document.querySelector("[data-external-checklists]");
  if (!container) return;

  const form = document.querySelector("[data-external-checklists-preload]");
  const status = document.querySelector("[data-external-checklists-status]");
  let awaiting = false;

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

  consumer.subscriptions.create({ channel: "ExternalChecklistsChannel" }, {
    received(data) {
      if (data.error) {
        if (awaiting) showStatus(`Preload failed: ${data.error}`);
        awaiting = false;
      } else if (awaiting) {
        replaceList(data.html);
        showStatus(`Preload finished: ${data.upserted} new or updated checklists.`);
        awaiting = false;
      } else {
        showStatus("New checklists arrived. Reload the page to see them.");
      }
    }
  });

  // Set on send, not on success: Birdnik may push before the request's response arrives.
  form.addEventListener("ajax:send", function () {
    awaiting = true;
    showStatus("Waiting for Birdnik to preload the checklists…");
  });

  form.addEventListener("ajax:error", function (e) {
    awaiting = false;
    showStatus(e.detail[0]?.message || "Preload request failed.");
  });
});
