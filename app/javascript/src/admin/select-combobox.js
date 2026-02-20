import Autocomplete, { highlight } from '../autocomplete';

// Replaces a <select> with a text input + autocomplete dropdown.
// Returns an object with selectByText(text) for programmatic selection.
export function selectCombobox(select) {
  const options = Array.from(select.options).filter(o => o.value != null);
  const minLength = options.length > 150 ? 2 : 1;

  const input = document.createElement('input');
  input.type = 'text';
  input.id = select.id;
  const selected = select.options[select.selectedIndex];
  if (selected) input.value = selected.text;

  select.removeAttribute('id');
  select.style.display = 'none';
  select.insertAdjacentElement('afterend', input);

  function filterOptions(term) {
    const re1 = new RegExp('^' + term.replace(/[.*+?^${}()|[\]\\]/g, '\\$&'), 'i');
    const re2 = new RegExp('[ \\-/]' + term.replace(/[.*+?^${}()|[\]\\]/g, '\\$&'), 'i');
    const first = options.filter(o => re1.test(o.text));
    const second = options.filter(o => re2.test(o.text) && !re1.test(o.text));
    return [...first, ...second].map(o => ({ label: o.text, value: o.text, option: o }));
  }

  const ac = new Autocomplete(input, {
    minLength,
    autoFocus: true,
    debounce: 0,
    autoWidth: true,
    source: term => Promise.resolve(filterOptions(term)),
    renderItem(li, item, term) {
      const a = document.createElement('a');
      a.innerHTML = highlight(item.label, term);
      li.appendChild(a);
    },
    onSelect(item) {
      input.value = item.value;
      item.option.selected = true;
    },
  });

  // On blur, clear input if text doesn't match any option
  input.addEventListener('blur', () => {
    const match = options.find(o => o.text.toLowerCase() === input.value.toLowerCase());
    if (input.value && !match) {
      input.value = '';
      select.value = '';
    }
  });

  return {
    selectByText(text) {
      const item = filterOptions(text)[0];
      if (item) {
        input.value = item.value;
        item.option.selected = true;
      }
    },
    get input() { return input; },
  };
}
