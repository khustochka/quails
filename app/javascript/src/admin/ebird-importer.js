import consumer from "../../channels/consumer"
import { selectCombobox } from './select-combobox';

document.addEventListener('DOMContentLoaded', function () {

  function refreshComboboxes() {
    document.querySelectorAll("select.locus_select").forEach(sel => selectCombobox(sel));
  }

  refreshComboboxes();

  const form = document.getElementById("ebird_refresh_form");
  const container = document.querySelector(".preloads-container");

  if (form) form.addEventListener("ajax:success", function () {
    consumer.subscriptions.create({ channel: "EBirdImportsChannel" }, {
      received(data) {
        container.innerHTML = data;
        this.unsubscribe();
        refreshComboboxes();
        const paramName = document.querySelector('meta[name=csrf-param]').content;
        const csrfToken = document.querySelector('meta[name=csrf-token]').content;
        container.querySelector("input[name=" + paramName + "]").value = csrfToken;
      }
    });
    container.innerHTML = "<p><i class=\"fas fa-spinner fa-spin\"></i> Please wait, refreshing the checklists</p>";
  });
});
