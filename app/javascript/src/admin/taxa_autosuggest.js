import Autocomplete from '../autocomplete';

function initTaxonSuggestField(elements, onSelect) {
  var inputs = typeof elements === 'string'
    ? document.querySelectorAll(elements)
    : (elements instanceof Element ? [elements] : elements);
  Array.from(inputs).forEach(function (input) {
    new Autocomplete(input, {
      minLength: 2,
      debounce: 0,
      autoFocus: true,
      source(term) {
        return fetch('/taxa/search.json?term=' + encodeURIComponent(term))
          .then(r => r.json());
      },
      renderItem(li, item) {
        const a = document.createElement('a');
        a.innerHTML = item.value + ' <small class="tag tag_' + item.cat + '">' + item.cat + '</small>';
        li.appendChild(a);
      },
      onSelect: onSelect ? function (item) { onSelect(input, item); } : function (item) {
        input.value = item.value;
        input.nextElementSibling.value = item.id;
      }
    });
  });
}

export { initTaxonSuggestField };
