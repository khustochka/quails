import { initTaxonSuggestField } from './taxa_autosuggest';
import { selectCombobox } from '../utils/select-combobox';
import { inlineDatepicker } from '../utils/inline-datepicker';

document.addEventListener('DOMContentLoaded', function () {
  if (!document.querySelector('form[data-card-form]')) return;

  let lastRowNum, sampleRowHtml, tmplRegex;

  function initObservationRows() {
    const rows = document.querySelectorAll('.obs-row');
    lastRowNum = rows.length - 1;
    sampleRowHtml = rows[rows.length - 1].outerHTML;
    tmplRegex = new RegExp("(_|\\[)" + lastRowNum + "(_|\\])", "g");
    rows[rows.length - 1].remove();
  }

  function initDatepicker() {
    const datefield = document.getElementById('card_observ_date');
    datefield.type = 'hidden';
    datefield.parentElement.style.display = 'none';
    const wrapper = document.createElement('div');
    wrapper.className = 'inline_date';
    const container = document.createElement('div');
    wrapper.appendChild(container);
    document.querySelector('form.simple_form').prepend(wrapper);
    inlineDatepicker(container, datefield, { firstDay: 1 });
  }

  function initLocusAutocomplete() {
    const select = document.querySelector('select#card_locus_id');
    const combo = selectCombobox(select);
    combo.input.required = true;
    document.querySelectorAll('.fast_locus').forEach(function (el) {
      el.addEventListener('click', function () {
        combo.selectByText(this.textContent);
      });
    });
  }

  function addNewRow() {
    lastRowNum++;
    const rowHtml = sampleRowHtml.replace(tmplRegex, '$1' + lastRowNum + '$2');
    const tmp = document.createElement('div');
    tmp.innerHTML = rowHtml;
    const row = tmp.firstElementChild;
    document.querySelector('.obs-block').appendChild(row);
    initTaxonSuggestField(row.querySelector('[data-taxon-autosuggest]'));
    return document.querySelector('.obs-row:last-child');
  }

  function initAddRows() {
    document.getElementById('add-row').addEventListener('click', function () {
      addNewRow();
      window.scrollTo(0, document.body.scrollHeight);
    });
  }

  function initRemoveAndDestroy() {
    document.querySelector('form.simple_form').addEventListener('click', function (e) {
      if (e.target.closest('.remove')) {
        e.target.closest('.obs-row').remove();
      }
    });
    document.querySelectorAll('a.destroy').forEach(function (a) {
      a.dataset.remote = 'true';
      a.dataset.type = 'json';
    });
    document.addEventListener('ajax:success', function (e) {
      if (e.target.matches('a.destroy')) {
        const row = e.target.closest('.obs-row');
        if (row.nextElementSibling) row.nextElementSibling.remove();
        row.remove();
      }
    });
    document.addEventListener('ajax:error', function (e) {
      if (e.target.matches('a.destroy')) alert('Error removing observation');
    });
  }

  function initFastSpeciesLinks() {
    document.querySelectorAll('.fast-sp-link').forEach(function (el) {
      el.addEventListener('click', function (e) {
        e.preventDefault();
        const row = addNewRow();
        row.querySelector('[data-taxon-autosuggest]').value = this.dataset.label;
        row.querySelector('[data-taxon-autosuggest]').nextElementSibling.value = this.dataset.taxonId;
      });
    });
  }

  function initQuickAdd() {
    initTaxonSuggestField(document.getElementById('species-quick-add'), function (input, item) {
      const row = addNewRow();
      row.querySelector('[data-taxon-autosuggest]').value = item.value;
      row.querySelector('[data-taxon-autosuggest]').nextElementSibling.value = item.id;
      input.value = '';
      window.scrollTo(0, document.body.scrollHeight);
    });
    document.getElementById('species-quick-add').addEventListener('keydown', function (e) {
      if (e.keyCode === 13 && !e.ctrlKey) {
        e.preventDefault();
      } else if (e.keyCode === 13 && e.ctrlKey) {
        document.querySelector('.simple_form').submit();
      }
    });
  }

  function initMarkAsVoice() {
    const kp = new window.keypress.Listener();
    kp.simple_combo('alt v', function () {
      const focused = document.activeElement;
      let row = focused.closest('.obs-row');
      if (!row && focused.id === 'species-quick-add') {
        row = document.querySelector('.obs-row:last-child');
      }
      if (!row) return;
      const checkbox = row.querySelector('div.card_observations_voice input.boolean');
      if (checkbox) checkbox.checked = !checkbox.checked;
    });
  }

  function initExtractorAndMover() {
    document.querySelector('.extractor')?.addEventListener('click', function (e) {
      e.preventDefault();
      window.location.href = this.href + '?' + new URLSearchParams(
        [...document.querySelectorAll('input[name="obs[]"]:checked')].map(i => ['obs[]', i.value])
      );
    });
    document.querySelector('.mover')?.addEventListener('click', function (e) {
      e.preventDefault();
      window.location.href = this.href + '?' + new URLSearchParams(
        [...document.querySelectorAll('input[name="obs[]"]:checked')].map(i => ['obs[]', i.value])
      );
    });
  }

  initObservationRows();
  initDatepicker();
  initLocusAutocomplete();
  initAddRows();
  initRemoveAndDestroy();
  initFastSpeciesLinks();
  initQuickAdd();
  initTaxonSuggestField('[data-taxon-autosuggest]');
  initMarkAsVoice();
  initExtractorAndMover();
});
