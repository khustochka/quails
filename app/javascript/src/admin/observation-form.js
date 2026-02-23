import { initTaxonSuggestField } from './taxa_autosuggest';

document.addEventListener('DOMContentLoaded', function () {
  const inputs = document.querySelectorAll('[data-taxon-autosuggest]');
  if (inputs.length > 0) initTaxonSuggestField(inputs);
});
