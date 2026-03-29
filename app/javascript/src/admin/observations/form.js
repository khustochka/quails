import { initTaxonSuggestField } from '../shared/taxa-autosuggest';

document.addEventListener('DOMContentLoaded', function () {
  const inputs = document.querySelectorAll('[data-taxon-autosuggest]');
  if (inputs.length > 0) initTaxonSuggestField(inputs);
});
