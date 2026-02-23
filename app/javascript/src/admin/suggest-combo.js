import { selectCombobox } from '../utils/select-combobox';

document.addEventListener('DOMContentLoaded', function () {
  document.querySelectorAll('select.suggest-combo').forEach(sel => selectCombobox(sel));
});
