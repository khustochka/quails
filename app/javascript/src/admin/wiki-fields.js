import Autocomplete, { highlight } from "../utils/autocomplete";
import { keypress } from "keypress.js";

document.addEventListener("DOMContentLoaded", function () {
  const textarea = document.querySelector("[data-wiki-field]");
  if (!textarea) return;

  const toolbar = document.createElement("div");
  toolbar.className = "edit_tools";
  textarea.parentNode.insertBefore(toolbar, textarea);

  function createButton(text, id) {
    const btn = document.createElement("button");
    btn.textContent = text;
    btn.id = id;
    btn.type = "button";
    toolbar.appendChild(btn);
    return btn;
  }

  const spBtn = createButton("{{species}}", "insert_sp_tag");
  const imgBtn = createButton("{{^image}}", "insert_img_tag");
  const videoBtn = createButton("{{&video}}", "insert_video_tag");
  const postBtn = createButton("{{#post}}", "insert_post_tag");

  function getSelectedText() {
    if (textarea.selectionStart || textarea.selectionStart === 0) {
      textarea.focus();
      return textarea.value.substring(textarea.selectionStart, textarea.selectionEnd);
    }
    return "";
  }

  function insertTags(tagOpen, tagClose, sampleText) {
    var selText = getSelectedText();
    var isSample = false;
    var textScroll = textarea.scrollTop;
    textarea.focus();
    var startPos = textarea.selectionStart;
    var endPos = textarea.selectionEnd;

    if (!selText) {
      selText = sampleText;
      isSample = true;
    } else if (selText.charAt(selText.length - 1) === " ") {
      selText = selText.substring(0, selText.length - 1);
      tagClose += " ";
    }

    textarea.value = textarea.value.substring(0, startPos) + tagOpen + selText + tagClose + textarea.value.substring(endPos);
    if (isSample) {
      textarea.selectionStart = startPos + tagOpen.length;
      textarea.selectionEnd = startPos + tagOpen.length + selText.length;
    } else {
      textarea.selectionStart = startPos + tagOpen.length + selText.length + tagClose.length;
      textarea.selectionEnd = textarea.selectionStart;
    }
    textarea.scrollTop = textScroll;
  }

  // Species dialog
  var dialog = null;
  var speciesInput = null;
  var ac = null;

  function closeSpeciesDialog() {
    if (!dialog) return;
    speciesInput.value = "";
    if (ac) ac._close();
    dialog.style.display = "none";
  }

  function openSpeciesSearch() {
    if (!dialog) {
      dialog = document.createElement("div");
      dialog.className = "insert_species_dialog ui-front";
      speciesInput = document.createElement("input");
      speciesInput.className = "species_wiki_input";
      dialog.appendChild(speciesInput);
      document.body.appendChild(dialog);

      speciesInput.addEventListener("blur", function () {
        setTimeout(function () {
          closeSpeciesDialog();
          textarea.focus();
        }, 150);
      });

      speciesInput.addEventListener("keydown", function (e) {
        if (e.key === "Escape") {
          closeSpeciesDialog();
          textarea.focus();
        }
      });

      ac = new Autocomplete(speciesInput, {
        source: function (term) {
          return fetch("/species/admin/search.json?term=" + encodeURIComponent(term))
            .then(function (r) { return r.json(); });
        },
        renderItem: function (li, item, term) {
          const a = document.createElement("a");
          a.innerHTML = highlight(item.name, term) + " <i class=\"sci_name\">" + highlight(item.label, term) + "</i>";
          li.appendChild(a);
        },
        onSelect: function (item) {
          if (item.name_sci) {
            closeSpeciesDialog();
            insertTags("{{", "|" + item.name_sci + "}}", item.name);
          }
        },
        debounce: 0,
        autoFocus: true,
        minLength: 2,
        dropdownClass: "wiki-species"
      });
    } else {
      dialog.style.display = "";
    }
    var selText = getSelectedText();
    speciesInput.value = selText;
    speciesInput.focus();
    if (selText && selText.length >= 2) ac._onInput();
  }

  spBtn.addEventListener("click", openSpeciesSearch);
  imgBtn.addEventListener("click", function () { insertTags("{{^", "}}", "image"); });
  videoBtn.addEventListener("click", function () { insertTags("{{&", "}}", "video"); });
  postBtn.addEventListener("click", function () { insertTags("{{#", "|}}", "post"); });

  // Keyboard shortcuts
  var kp = new keypress.Listener();
  kp.simple_combo("alt s", openSpeciesSearch);
  kp.simple_combo("alt p", function () { insertTags("{{#", "|}}", "post"); });
});
