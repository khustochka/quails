import { selectCombobox } from './select-combobox';

document.addEventListener('DOMContentLoaded', function () {
  document.querySelectorAll('select.suggest-combo').forEach(sel => selectCombobox(sel));
});
